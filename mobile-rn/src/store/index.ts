import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import appointmentReducer from './slices/appointmentSlice';
import notificationReducer from './slices/notificationSlice';

// ─── Store ───────────────────────────────────────────────────

export const store = configureStore({
  reducer: {
    auth: authReducer,
    appointments: appointmentReducer,
    notifications: notificationReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        // Ignore Date objects in these paths (they are serialized as ISO strings on the wire)
        ignoredActionPaths: ['payload.createdAt', 'payload.updatedAt', 'payload.scheduledTime'],
        ignoredPaths: [
          'auth.user.createdAt',
          'auth.user.updatedAt',
          'auth.user.lastLoginAt',
        ],
      },
    }),
});

// ─── Types ───────────────────────────────────────────────────

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
