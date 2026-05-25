// ============================================================
// API constants for MediConnectSmart
// ============================================================

/**
 * Base URL for the backend API.
 * Override via environment variable in production builds.
 */
export const API_BASE_URL =
  process.env.API_BASE_URL ?? 'http://localhost:3000/api/v1';

/** Default request timeout in milliseconds */
export const API_TIMEOUT = 30_000;

// ─── Auth Endpoints ──────────────────────────────────────────
export const AUTH_ENDPOINTS = {
  LOGIN: '/auth/login',
  REGISTER: '/auth/register',
  LOGOUT: '/auth/logout',
  REFRESH_TOKEN: '/auth/refresh',
  VERIFY_MFA: '/auth/mfa/verify',
  SEND_MFA: '/auth/mfa/send',
  FORGOT_PASSWORD: '/auth/forgot-password',
  RESET_PASSWORD: '/auth/reset-password',
} as const;

// ─── User Endpoints ──────────────────────────────────────────
export const USER_ENDPOINTS = {
  PROFILE: '/users/profile',
  UPDATE_PROFILE: '/users/profile',
  CHANGE_PASSWORD: '/users/change-password',
  PREFERENCES: '/users/preferences',
} as const;

// ─── Doctor Endpoints ────────────────────────────────────────
export const DOCTOR_ENDPOINTS = {
  LIST: '/doctors',
  DETAIL: (id: string) => `/doctors/${id}`,
  SCHEDULE: (id: string) => `/doctors/${id}/schedule`,
  AVAILABILITY: (id: string) => `/doctors/${id}/availability`,
  PATIENTS: (id: string) => `/doctors/${id}/patients`,
} as const;

// ─── Patient Endpoints ───────────────────────────────────────
export const PATIENT_ENDPOINTS = {
  HEALTH_CARD: (id: string) => `/patients/${id}/health-card`,
  UPDATE_HEALTH_CARD: (id: string) => `/patients/${id}/health-card`,
  MEDICAL_HISTORY: (id: string) => `/patients/${id}/medical-history`,
} as const;

// ─── Appointment Endpoints ───────────────────────────────────
export const APPOINTMENT_ENDPOINTS = {
  LIST: '/appointments',
  CREATE: '/appointments',
  DETAIL: (id: string) => `/appointments/${id}`,
  RESCHEDULE: (id: string) => `/appointments/${id}/reschedule`,
  CANCEL: (id: string) => `/appointments/${id}/cancel`,
  UPCOMING: '/appointments/upcoming',
} as const;

// ─── Prescription Endpoints ──────────────────────────────────
export const PRESCRIPTION_ENDPOINTS = {
  LIST: '/prescriptions',
  CREATE: '/prescriptions',
  DETAIL: (id: string) => `/prescriptions/${id}`,
  PATIENT: (patientId: string) => `/prescriptions/patient/${patientId}`,
  UPDATE_STATUS: (id: string) => `/prescriptions/${id}/status`,
} as const;

// ─── Clinical Record Endpoints ───────────────────────────────
export const CLINICAL_RECORD_ENDPOINTS = {
  LIST: '/clinical-records',
  CREATE: '/clinical-records',
  DETAIL: (id: string) => `/clinical-records/${id}`,
  PATIENT: (patientId: string) => `/clinical-records/patient/${patientId}`,
} as const;

// ─── Chat Endpoints ──────────────────────────────────────────
export const CHAT_ENDPOINTS = {
  CONVERSATIONS: '/chat/conversations',
  MESSAGES: (conversationId: string) => `/chat/conversations/${conversationId}/messages`,
  SEND: '/chat/messages',
  MARK_READ: (messageId: string) => `/chat/messages/${messageId}/read`,
  UNREAD_COUNT: '/chat/unread-count',
} as const;

// ─── Lab Result Endpoints ────────────────────────────────────
export const LAB_RESULT_ENDPOINTS = {
  LIST: '/lab-results',
  UPLOAD: '/lab-results/upload',
  DETAIL: (id: string) => `/lab-results/${id}`,
  PATIENT: (patientId: string) => `/lab-results/patient/${patientId}`,
} as const;

// ─── Notification Endpoints ──────────────────────────────────
export const NOTIFICATION_ENDPOINTS = {
  LIST: '/notifications',
  MARK_READ: (id: string) => `/notifications/${id}/read`,
  MARK_ALL_READ: '/notifications/read-all',
  PREFERENCES: '/notifications/preferences',
  FCM_TOKEN: '/notifications/fcm-token',
} as const;

// ─── AI Endpoints ────────────────────────────────────────────
export const AI_ENDPOINTS = {
  APPOINTMENT_SUMMARY: (appointmentId: string) =>
    `/ai/appointments/${appointmentId}/summary`,
  MEDICINE_REMINDERS: (prescriptionId: string) =>
    `/ai/prescriptions/${prescriptionId}/reminders`,
  TRANSLATE: '/ai/translate',
} as const;
