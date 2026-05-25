import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface AppNotification {
  id: string;
  type: 'appointment_reminder' | 'medicine_reminder' | 'lab_result' | 'message' | 'system';
  title: string;
  body: string;
  isRead: boolean;
  createdAt: string; // ISO string for Redux serialization
}

interface NotificationState {
  notifications: AppNotification[];
  unreadCount: number;
  fcmToken: string | null;
}

const initialState: NotificationState = {
  notifications: [],
  unreadCount: 0,
  fcmToken: null,
};

const notificationSlice = createSlice({
  name: 'notifications',
  initialState,
  reducers: {
    setNotifications(state, action: PayloadAction<AppNotification[]>) {
      state.notifications = action.payload;
      state.unreadCount = action.payload.filter((n) => !n.isRead).length;
    },
    addNotification(state, action: PayloadAction<AppNotification>) {
      state.notifications.unshift(action.payload);
      if (!action.payload.isRead) {
        state.unreadCount += 1;
      }
    },
    markAsRead(state, action: PayloadAction<string>) {
      const notification = state.notifications.find(
        (n) => n.id === action.payload,
      );
      if (notification && !notification.isRead) {
        notification.isRead = true;
        state.unreadCount = Math.max(0, state.unreadCount - 1);
      }
    },
    markAllAsRead(state) {
      state.notifications.forEach((n) => {
        n.isRead = true;
      });
      state.unreadCount = 0;
    },
    setFcmToken(state, action: PayloadAction<string>) {
      state.fcmToken = action.payload;
    },
  },
});

export const {
  setNotifications,
  addNotification,
  markAsRead,
  markAllAsRead,
  setFcmToken,
} = notificationSlice.actions;

export default notificationSlice.reducer;
