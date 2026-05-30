import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global Appwrite client
final Client client = Client()
    .setProject(dotenv.env['APPWRITE_PROJECT_ID'] ?? '')
    .setEndpoint(dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1');
