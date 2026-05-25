import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mediconnect_mobile/src/features/auth/login_screen.dart';
import 'package:mediconnect_mobile/src/features/auth/register_screen.dart';
import 'package:mediconnect_mobile/src/features/auth/onboarding_screen.dart';
import 'package:mediconnect_mobile/src/features/dashboard/dashboard_screen.dart';
import 'package:mediconnect_mobile/src/features/appointments/doctor_search_screen.dart';
import 'package:mediconnect_mobile/src/features/appointments/booking_screen.dart';
import 'package:mediconnect_mobile/src/features/prescriptions/prescription_editor_screen.dart';
import 'package:mediconnect_mobile/src/features/prescriptions/prescription_view_screen.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_list_screen.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_room_screen.dart';
import 'package:mediconnect_mobile/src/features/dashboard/lab_results_screen.dart';

part 'app_router.g.dart';

enum AppRoute {
  onboarding,
  login,
  register,
  dashboard,
  doctorSearch,
  booking,
  prescriptionEditor,
  prescriptionView,
  chatList,
  chatRoom,
  labResults,
}

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
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
          final doctor = (state.extra as Map<String, String>?) ?? {
            'name': 'Dr. Ahmed Raza',
            'specialty': 'Cardiologist',
            'fee': '2000',
            'rating': '4.9'
          };
          return BookingScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/prescription-editor',
        name: AppRoute.prescriptionEditor.name,
        builder: (context, state) {
          final patientName = (state.extra as String?) ?? 'Fatima Khan';
          return PrescriptionEditorScreen(patientName: patientName);
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
          final name = state.extra as String;
          return ChatRoomScreen(otherUserName: name);
        },
      ),
      GoRoute(
        path: '/lab-results',
        name: AppRoute.labResults.name,
        builder: (context, state) => const LabResultsScreen(),
      ),
    ],
  );
}
