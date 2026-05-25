import axios, {
  AxiosError,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

import { API_BASE_URL, API_TIMEOUT, AUTH_ENDPOINTS } from '../constants/api';
import { AuthResponse } from '../types';

// ─── Storage Keys ────────────────────────────────────────────

const STORAGE_KEYS = {
  ACCESS_TOKEN: '@mediconnect/access_token',
  REFRESH_TOKEN: '@mediconnect/refresh_token',
} as const;

// ─── Token Helpers ───────────────────────────────────────────

export const tokenStorage = {
  async getAccessToken(): Promise<string | null> {
    return AsyncStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  },
  async getRefreshToken(): Promise<string | null> {
    return AsyncStorage.getItem(STORAGE_KEYS.REFRESH_TOKEN);
  },
  async setTokens(accessToken: string, refreshToken: string): Promise<void> {
    await Promise.all([
      AsyncStorage.setItem(STORAGE_KEYS.ACCESS_TOKEN, accessToken),
      AsyncStorage.setItem(STORAGE_KEYS.REFRESH_TOKEN, refreshToken),
    ]);
  },
  async clearTokens(): Promise<void> {
    await Promise.all([
      AsyncStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN),
      AsyncStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN),
    ]);
  },
};

// ─── Axios Instance ──────────────────────────────────────────

const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

// ─── Request Interceptor ─────────────────────────────────────

apiClient.interceptors.request.use(
  async (config: InternalAxiosRequestConfig): Promise<InternalAxiosRequestConfig> => {
    const token = await tokenStorage.getAccessToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => Promise.reject(error),
);

// ─── Response Interceptor (token refresh) ────────────────────

let isRefreshing = false;
let failedQueue: Array<{
  resolve: (value: string) => void;
  reject: (reason?: unknown) => void;
}> = [];

function processQueue(error: AxiosError | null, token: string | null = null): void {
  failedQueue.forEach(({ resolve, reject }) => {
    if (error) {
      reject(error);
    } else if (token) {
      resolve(token);
    }
  });
  failedQueue = [];
}

apiClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as AxiosRequestConfig & { _retry?: boolean };

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        // Queue the request until the token refresh completes
        return new Promise<string>((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            if (originalRequest.headers) {
              originalRequest.headers.Authorization = `Bearer ${token}`;
            }
            return apiClient(originalRequest);
          })
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const refreshToken = await tokenStorage.getRefreshToken();
        if (!refreshToken) {
          throw new Error('No refresh token available');
        }

        const response = await axios.post<AuthResponse>(
          `${API_BASE_URL}${AUTH_ENDPOINTS.REFRESH_TOKEN}`,
          { refreshToken },
        );

        const { accessToken, refreshToken: newRefreshToken } = response.data;
        await tokenStorage.setTokens(accessToken, newRefreshToken);

        processQueue(null, accessToken);

        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        }
        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError as AxiosError, null);
        await tokenStorage.clearTokens();
        // Emit an event or dispatch a Redux action to redirect to login
        // This is handled by the app's auth state listener
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  },
);

export default apiClient;
