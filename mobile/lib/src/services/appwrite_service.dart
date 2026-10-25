import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
// Prefixed: the instance getter `client` below would otherwise shadow the
// global and turn `_client = client` inside initialize() into recursion.
import 'package:mediconnect_mobile/src/config/appwrite_client.dart' as cfg;
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client _client;
  late Account _account;
  late Databases _databases;

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    // Single source of truth: src/config/appwrite_client.dart
    _client = cfg.client;
    _account = Account(_client);
    _databases = Databases(_client);

    _isInitialized = true;
  }

  Client get client {
    _ensureInitialized();
    return _client;
  }

  Account get account {
    _ensureInitialized();
    return _account;
  }

  Databases get databases {
    _ensureInitialized();
    return _databases;
  }

  /// Guarantees the SDK objects exist before use so a partial init can never
  /// surface as LateInitializationError.
  void _ensureInitialized() {
    if (!_isInitialized) initialize();
  }

  // ─── Session management ───────────────────────────────────────────────────

  Future<bool> hasSession() async {
    try {
      await account.getSession(sessionId: 'current');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveSession(String sessionId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appwrite_session', sessionId);
    await prefs.setString('appwrite_user_id', userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('appwrite_session');
    await prefs.remove('appwrite_user_id');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
  }

  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('appwrite_session');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('appwrite_user_id');
  }

  // ─── Auth methods ─────────────────────────────────────────────────────────

  /// Signs the given credentials in and returns the account. Web keeps the
  /// Appwrite session in a shared cookie; when one is already active,
  /// Appwrite refuses to open a second session — in that case the stale
  /// session is replaced by the credentials the user just entered.
  Future<models.User> _establishSessionFor(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await saveSession(session.$id, session.userId);
    } on AppwriteException catch (e) {
      final active = (e.type ?? '').contains('session_already_exist') ||
          (e.message ?? '').toLowerCase().contains('session is active');
      if (!active) rethrow;
      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {}
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await saveSession(session.$id, session.userId);
    }
    return await _account.get();
  }

  Future<models.User> login(String email, String password) async {
    try {
      return await _establishSessionFor(email, password);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Signs in the fresh account (replacing any stale session cookie).
      await _establishSessionFor(email, password);

      // Persist a profile the rest of the app can read (role-aware views).
      try {
        await databases.createDocument(
          databaseId: AppwriteDB.databaseId,
          collectionId: AppwriteDB.users,
          documentId: ID.unique(),
          data: {
            'userId': user.$id,
            'email': email,
            'role': role,
            'fullName': name,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        debugPrint('Profile save skipped (collection may be missing): $e');
      }

      // Cache identity locally so screens stay hydrated across restarts.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
    } catch (e) {
      throw _mapException(e);
    }
  }

  /// Sets a new display name on the Appwrite account and locally.
  Future<void> updateName(String name) async {
    try {
      await account.updateName(name: name);
    } catch (e) {
      throw _mapException(e);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (_) {
      // Ignore errors during logout
    }
    await clearSession();
  }

  Future<models.User> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      throw _mapException(e);
    }
  }

  /// True when the signed-in account has confirmed its email address.
  /// Returns false (not an exception) when there is no session.
  Future<bool> isEmailVerified() async {
    try {
      final user = await _account.get();
      return user.emailVerification;
    } catch (_) {
      return false;
    }
  }

  /// Completes email verification from the deep-linked /verify-email route
  /// (userId + secret arrive as query parameters on the emailed link).
  Future<void> verifyEmail(String userId, String secret) async {
    try {
      await _account.updateVerification(
        userId: userId,
        secret: secret,
      );
    } catch (e) {
      throw _mapException(e);
    }
  }

  /// Sends the Appwrite verification email — a real email with a real
  /// secret that deep-links back into the web app's /verify-email route.
  Future<void> sendEmailVerification() async {
    try {
      await _account.createVerification(url: cfg.AppwriteConfig.emailVerifyUrl);
    } catch (e) {
      throw _mapException(e);
    }
  }

  /// Requests a one-time 6-digit sign-in code. Appwrite emails the code to
  /// the user (even if no account exists yet — unknown emails are refused
  /// at verify time) and returns the token's userId, which the OTP screen
  /// needs to complete sign-in via [verifyEmailOtp].
  Future<String> requestEmailOtp(String email) async {
    try {
      final token = await _account.createEmailToken(
        userId: ID.unique(),
        email: email,
      );
      return token.userId;
    } catch (e) {
      throw _mapException(e);
    }
  }

  /// Completes email-code sign-in: exchanges the emailed code for a
  /// session and returns the account.
  Future<models.User> verifyEmailOtp(String userId, String code) async {
    try {
      final session = await _account.createSession(
        userId: userId,
        secret: code,
      );
      await saveSession(session.$id, session.userId);
      return await _account.get();
    } catch (e) {
      throw _mapException(e);
    }
  }

  /// Completes the reset started by [requestPasswordReset]: swaps the
  /// emailed secret for a brand-new password.
  Future<void> completePasswordReset(
    String userId,
    String secret,
    String newPassword,
  ) async {
    try {
      await _account.updateRecovery(
        userId: userId,
        secret: secret,
        password: newPassword,
      );
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> requestPasswordReset(String email, {String? redirectTo}) async {
    try {
      // Prefer the caller's web origin when given; otherwise deep-link to
      // the deployed web app's /reset-password route.
      await _account.createRecovery(
        email: email,
        url: redirectTo ?? cfg.AppwriteConfig.emailResetUrl,
      );
    } catch (e) {
      throw _mapException(e);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Exception _mapException(dynamic e) {
    if (e is AppwriteException) {
      return Exception(e.message ?? 'An error occurred');
    }
    return Exception(e.toString());
  }
}
