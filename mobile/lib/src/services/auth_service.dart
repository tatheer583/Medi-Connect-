import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';

part 'auth_service.g.dart';

// Single source of truth for UserRole — used across the whole app
enum UserRole { patient, doctor, clinic }

class UserState {
  final String? userId;
  final String? email;
  final String? name;
  final UserRole role;
  final bool isAuthenticated;

  const UserState({
    this.userId,
    this.email,
    this.name,
    required this.role,
    this.isAuthenticated = false,
  });

  UserState copyWith({
    String? userId,
    String? email,
    String? name,
    UserRole? role,
    bool? isAuthenticated,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

@riverpod
class AuthService extends _$AuthService {
  @override
  UserState build() {
    return const UserState(role: UserRole.patient, isAuthenticated: false);
  }

  /// Called after successful Appwrite login — stores real user ID
  void login(String email, UserRole role, {String? userId, String? name}) {
    state = UserState(
      userId: userId,
      email: email,
      name: name,
      role: role,
      isAuthenticated: true,
    );
  }

  /// Called on logout — clears Appwrite session + local prefs
  Future<void> logout() async {
    final appwrite = AppwriteService();
    appwrite.initialize();
    await appwrite.logout();
    state = const UserState(role: UserRole.patient, isAuthenticated: false);
  }

  /// Restore session from SharedPreferences on app start
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('appwrite_session');
    final roleString = prefs.getString('user_role');
    final email = prefs.getString('user_email');
    final userId = prefs.getString('appwrite_user_id');
    final name = prefs.getString('user_name');

    if (sessionId != null && roleString != null) {
      final role = UserRole.values.firstWhere(
        (e) => e.name == roleString,
        orElse: () => UserRole.patient,
      );
      state = UserState(
        userId: userId,
        email: email,
        name: name,
        role: role,
        isAuthenticated: true,
      );
    }
  }
}
