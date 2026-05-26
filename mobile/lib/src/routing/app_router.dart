import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/features/auth/splash_screen.dart';
import 'package:mediconnect_mobile/src/features/auth/role_selection_screen.dart';
import 'package:mediconnect_mobile/src/features/auth/login_screen.dart';
import 'package:mediconnect_mobile/src/features/auth/register_screen.dart';
import 'package:mediconnect_mobile/src/features/auth/otp_verification_screen.dart';
import 'package:mediconnect_mobile/src/features/dashboard/dashboard_screen.dart';
import 'package:mediconnect_mobile/src/features/appointments/doctor_search_screen.dart';
import 'package:mediconnect_mobile/src/features/appointments/booking_screen.dart';
import 'package:mediconnect_mobile/src/features/appointments/appointments_screen.dart';
import 'package:mediconnect_mobile/src/features/prescriptions/prescription_editor_screen.dart';
import 'package:mediconnect_mobile/src/features/prescriptions/prescription_view_screen.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_list_screen.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_room_screen.dart';
import 'package:mediconnect_mobile/src/features/dashboard/lab_results_screen.dart';
import 'package:mediconnect_mobile/src/features/reminders/reminders_screen.dart';

part 'app_router.g.dart';

enum AppRoute {
  splash,
  roleSelection,
  login,
  register,
  otp,
  dashboard,
  doctorSearch,
  booking,
  appointments,
  prescriptionEditor,
  prescriptionView,
  chatList,
  chatRoom,
  labResults,
  reminders,
}

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: AppRoute.roleSelection.name,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => LoginScreen(role: state.extra as UserRole?),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (context, state) => RegisterScreen(role: state.extra as UserRole?),
      ),
      GoRoute(
        path: '/otp',
        name: AppRoute.otp.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OtpVerificationScreen(
            email: data['email'] as String,
            role: data['role'] as UserRole,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: AppRoute.dashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/search',
        name: AppRoute.doctorSearch.name,
        builder: (context, state) => const DoctorSearchScreen(),
      ),
      GoRoute(
        path: '/booking',
        name: AppRoute.booking.name,
        builder: (context, state) {
          final doctor = (state.extra as Map<String, String>?) ??
              {'name': 'Dr. Ahmed Raza', 'specialty': 'Cardiologist', 'fee': '2000', 'rating': '4.9'};
          return BookingScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/appointments',
        name: AppRoute.appointments.name,
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/prescription-editor',
        name: AppRoute.prescriptionEditor.name,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, String>) {
            return PrescriptionEditorScreen(
              patientName: extra['name'] ?? 'Patient',
              patientId: extra['id'],
            );
          }
          return PrescriptionEditorScreen(
            patientName: extra as String? ?? 'Patient',
          );
        },
      ),
      GoRoute(
        path: '/prescription-view',
        name: AppRoute.prescriptionView.name,
        builder: (context, state) => const PrescriptionViewScreen(),
      ),
      GoRoute(
        path: '/chat-list',
        name: AppRoute.chatList.name,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat-room',
        name: AppRoute.chatRoom.name,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, String>) {
            return ChatRoomScreen(
              otherUserName: extra['name'] ?? 'User',
              otherUserId: extra['id'] ?? 'unknown',
            );
          }
          return ChatRoomScreen(otherUserName: extra as String? ?? 'User');
        },
      ),
      GoRoute(
        path: '/lab-results',
        name: AppRoute.labResults.name,
        builder: (context, state) => const LabResultsScreen(),
      ),
      GoRoute(
        path: '/reminders',
        name: AppRoute.reminders.name,
        builder: (context, state) => const RemindersScreen(),
      ),
    ],
  );
}
