import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBlueDiag),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Header
                Text(
                  'Welcome to',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ).animate().fadeIn(duration: 500.ms),

                Text(
                  'MediConnect',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                const SizedBox(height: 8),

                Text(
                  'Choose your role to get started',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 48),

                // Role cards
                _RoleCard(
                  role: UserRole.patient,
                  icon: Icons.person_rounded,
                  title: 'Patient',
                  subtitle: 'Book appointments & track health',
                  delay: 300,
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: UserRole.doctor,
                  icon: Icons.medical_services_rounded,
                  title: 'Doctor',
                  subtitle: 'Manage patients & prescriptions',
                  delay: 450,
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: UserRole.clinic,
                  icon: Icons.business_rounded,
                  title: 'Clinic',
                  subtitle: 'Manage clinic & appointments',
                  delay: 600,
                ),

                const Spacer(),

                Text(
                  'MediConnect Smart v1.0',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  Future<void> _onTap() async {
    setState(() => _pressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _pressed = false);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', widget.role.name);

    if (mounted) {
      context.pushNamed('login', extra: widget.role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay), duration: 500.ms)
        .slideX(begin: 0.3, end: 0, delay: Duration(milliseconds: widget.delay), duration: 500.ms);
  }
}
