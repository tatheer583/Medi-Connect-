import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect_mobile/src/app.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/services/notification_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Appwrite SDK
  try {
    AppwriteService().initialize();
  } catch (e) {
    debugPrint('Appwrite initialization error: $e');
  }

  // Initialize local notifications
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
}
