import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('appwrite_session');
      final roleString = prefs.getString('user_role');

      if (sessionId != null && roleString != null) {
        final appwrite = AppwriteService();
        appwrite.initialize();
        final hasSession = await appwrite.hasSession();
        if (hasSession && mounted) {
          context.go('/dashboard');
          return;
        }
      }
    } catch (_) {}

    if (mounted) context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBlueDiag),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.6, 0.6), duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 28),

                Text(
                  'MediConnect',
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms),

                const SizedBox(height: 8),

                Text(
                  'Smart Healthcare at Your Fingertips',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms),

                const SizedBox(height: 80),

                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
