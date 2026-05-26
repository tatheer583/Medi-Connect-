import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect_mobile/src/app.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Appwrite SDK
  AppwriteService().initialize();

  // Initialize local notifications
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: MediConnectApp(),
    ),
  );
}
