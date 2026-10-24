import 'package:appwrite/appwrite.dart';

/// Global Appwrite client — single source of truth for project configuration.
///
/// These are public client-side values (safe to hardcode): endpoint + project.
/// Keep secrets (API keys) server-side or compile-time only.
class AppwriteConfig {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '6adbaf74001f1772ff9b';
  static const String databaseId = 'mediconnect_db';

  /// Builds a direct view URL for a file in Appwrite Storage so it can be
  /// opened in a browser (web) or viewer (mobile).
  static String fileViewUrl(String bucketId, String fileId) =>
      '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
}

final Client client = Client()
    .setProject(AppwriteConfig.projectId)
    .setEndpoint(AppwriteConfig.endpoint);
