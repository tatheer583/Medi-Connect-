/**
 * MediConnectSmart - Root Application Component
 *
 * Sets up:
 *  - Redux store provider
 *  - i18next localization
 *  - React Native Paper theme provider
 *  - Navigation container (via AppNavigator)
 *  - Firebase Cloud Messaging listener
 */

import React, { useEffect } from 'react';
import { StatusBar, useColorScheme } from 'react-native';
import { Provider as ReduxProvider, useDispatch } from 'react-redux';
import { Provider as PaperProvider, MD3LightTheme, MD3DarkTheme } from 'react-native-paper';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import messaging from '@react-native-firebase/messaging';

// i18n must be imported before any component that uses translations
import './src/i18n';

import { store, AppDispatch } from './src/store';
import { setFcmToken, addNotification } from './src/store/slices/notificationSlice';
import AppNavigator from './src/navigation/AppNavigator';

// ─── FCM Setup ───────────────────────────────────────────────

function FcmSetup(): null {
  const dispatch = useDispatch<AppDispatch>();

  useEffect(() => {
    // Request notification permissions (iOS)
    messaging()
      .requestPermission()
      .then((authStatus) => {
        const enabled =
          authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
          authStatus === messaging.AuthorizationStatus.PROVISIONAL;

        if (enabled) {
          // Get and store the FCM token
          messaging()
            .getToken()
            .then((token) => {
              dispatch(setFcmToken(token));
            })
            .catch(() => {
              // Token retrieval failed — non-critical, app continues
            });
        }
      })
      .catch(() => {
        // Permission request failed — non-critical
      });

    // Handle foreground messages
    const unsubscribeForeground = messaging().onMessage(async (remoteMessage) => {
      const { notification, data } = remoteMessage;
      if (notification) {
        dispatch(
          addNotification({
            id: remoteMessage.messageId ?? Date.now().toString(),
            type: (data?.type as 'appointment_reminder' | 'medicine_reminder' | 'lab_result' | 'message' | 'system') ?? 'system',
            title: notification.title ?? '',
            body: notification.body ?? '',
            isRead: false,
            createdAt: new Date().toISOString(),
          }),
        );
      }
    });

    // Handle token refresh
    const unsubscribeTokenRefresh = messaging().onTokenRefresh((token) => {
      dispatch(setFcmToken(token));
    });

    return () => {
      unsubscribeForeground();
      unsubscribeTokenRefresh();
    };
  }, [dispatch]);

  return null;
}

// ─── App ─────────────────────────────────────────────────────

export default function App(): React.JSX.Element {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const paperTheme = isDark ? MD3DarkTheme : MD3LightTheme;

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <ReduxProvider store={store}>
        <PaperProvider theme={paperTheme}>
          <StatusBar
            barStyle={isDark ? 'light-content' : 'dark-content'}
            backgroundColor={isDark ? '#000' : '#fff'}
          />
          {/* FCM setup runs inside Redux provider so it can dispatch */}
          <FcmSetup />
          <AppNavigator />
        </PaperProvider>
      </ReduxProvider>
    </GestureHandlerRootView>
  );
}
