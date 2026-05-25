import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

enum UserRole { doctor, patient }

class UserState {
  final String? userId;
  final UserRole role;
  final bool isAuthenticated;

  UserState({this.userId, required this.role, this.isAuthenticated = false});
}

@riverpod
class AuthService extends _$AuthService {
  @override
  UserState build() {
    // Initial mock state: Patient
    return UserState(role: UserRole.patient, isAuthenticated: false);
  }

  void login(UserRole role) {
    state = UserState(userId: 'mock-uid', role: role, isAuthenticated: true);
  }

  void logout() {
    state = UserState(role: UserRole.patient, isAuthenticated: false);
  }

  void toggleRole() {
    final newRole = state.role == UserRole.patient ? UserRole.doctor : UserRole.patient;
    state = UserState(userId: state.userId, role: newRole, isAuthenticated: state.isAuthenticated);
  }
}
