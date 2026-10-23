import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect_mobile/src/app.dart';
import 'package:mediconnect_mobile/src/config/app_config.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/services/ai_service.dart';
import 'package:mediconnect_mobile/src/services/notification_service.dart';

void main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Appwrite SDK
      try {
        AppwriteService().initialize();
      } catch (e) {
        debugPrint('Appwrite initialization error: $e');
      }

      // Initialize AI service with compile-time key:
      // flutter run/build --dart-define=OPENAI_API_KEY=sk-...
      AiService.initialize(AppConfig.openAiApiKey);

      // Initialize local notifications (no-op on web)
      try {
        await NotificationService().initialize();
      } catch (e) {
        debugPrint('Notification service initialization error: $e');
      }

      runApp(
        const ProviderScope(
          child: MediConnectApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught app error: $error\n$stack');
    },
  );
}
