import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client _client;
  late Account _account;
  late Databases _databases;

  // Hardcoded for production — these are public client-side values
  static const String _endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String _projectId = '6a14834f003c65073c46';

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    _client = Client()
        .setEndpoint(_endpoint)
        .setProject(_projectId);

    _account = Account(_client);
    _databases = Databases(_client);

    _isInitialized = true;
  }

  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;

  // ─── Session management ───────────────────────────────────────────────────

  Future<bool> hasSession() async {
    try {
      await _account.getSession(sessionId: 'current');
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

  Future<models.User> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await saveSession(session.$id, session.userId);
      return await _account.get();
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
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      await saveSession(session.$id, user.$id);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
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

  Future<void> verifyEmail(String userId, String secret, String code) async {
    try {
      await _account.updateEmailVerification(
        userId: userId,
        secret: secret,
      );
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'https://mediconnect.app/reset-password',
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
