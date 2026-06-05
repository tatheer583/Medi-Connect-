import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_input.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/gradient_button.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole? role;
  const RegisterScreen({super.key, this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  int _step = 0; // 0 = personal, 1 = credentials
  bool _isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  void _evalStrength(String p) {
    double s = 0;
    if (p.length >= 8) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) s += 0.25;
    setState(() {
      _passwordStrength = s;
      if (s <= 0.25) { _strengthLabel = 'Weak'; _strengthColor = AppColors.error; }
      else if (s <= 0.5) { _strengthLabel = 'Fair'; _strengthColor = AppColors.warning; }
      else if (s <= 0.75) { _strengthLabel = 'Good'; _strengthColor = Colors.amber; }
      else { _strengthLabel = 'Strong'; _strengthColor = AppColors.success; }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final appwrite = AppwriteService();
      appwrite.initialize();
      final role = widget.role ?? UserRole.patient;

      await appwrite.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _nameCtrl.text.trim(),
        role.name,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role.name);
      await prefs.setString('user_email', _emailCtrl.text.trim());
      await prefs.setString('user_name', _nameCtrl.text.trim());

      if (mounted) {
        AppToast.show(context, 'Account created! Please verify your email.', type: ToastType.success);
        context.pushNamed('otp', extra: {
          'email': _emailCtrl.text.trim(),
          'role': role,
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppToast.show(
        context,
        msg.contains('409') ? 'Email already registered' : msg,
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role ?? UserRole.patient;
    final isDoctor = role == UserRole.doctor;
    final isClinic = role == UserRole.clinic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientBlueDiag,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Register as ${role.name[0].toUpperCase()}${role.name.substring(1)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Progress bar
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _step >= 1
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Step ${_step + 1} of 2 — ${_step == 0 ? 'Personal Info' : 'Set Password'}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_step == 0) ...[
                        AppInput(
                          controller: _nameCtrl,
                          label: isClinic ? 'Clinic Name' : 'Full Name',
                          prefixIcon: isClinic ? Icons.business_rounded : Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0),
                        const SizedBox(height: 16),
                        AppInput(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: 0.2, end: 0, delay: 100.ms),
                        if (isDoctor) ...[
                          const SizedBox(height: 16),
                          AppInput(
                            controller: _licenseCtrl,
                            label: 'PMDC License Number',
                            prefixIcon: Icons.badge_outlined,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'License is required' : null,
                          ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideX(begin: 0.2, end: 0, delay: 200.ms),
                        ],
                        const SizedBox(height: 32),
                        GradientButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            if (_nameCtrl.text.trim().isEmpty) {
                              AppToast.show(context, 'Please enter your name', type: ToastType.warning);
                              return;
                            }
                            if (!_emailCtrl.text.contains('@')) {
                              AppToast.show(context, 'Enter a valid email', type: ToastType.warning);
                              return;
                            }
                            setState(() => _step = 1);
                          },
                        ).animate().fadeIn(delay: 300.ms),
                      ] else ...[
                        // Password
                        AppInput(
                          controller: _passwordCtrl,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          onChanged: _evalStrength,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 8) return 'Minimum 8 characters';
                            return null;
                          },
                        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0),

                        if (_passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: AppColors.divider,
                                    valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _strengthLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _strengthColor,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        AppInput(
                          controller: _confirmCtrl,
                          label: 'Confirm Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm password';
                            if (v != _passwordCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: 0.2, end: 0, delay: 100.ms),

                        const SizedBox(height: 32),

                        GradientButton(
                          label: 'Create Account',
                          icon: Icons.check_rounded,
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: () => setState(() => _step = 0),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back'),
                        ).animate().fadeIn(delay: 300.ms),
                      ],

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                              style: GoogleFonts.inter(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text('Sign In',
                                style: GoogleFonts.inter(
                                    color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
