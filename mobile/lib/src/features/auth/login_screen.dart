import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_input.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/gradient_button.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole? role;
  const LoginScreen({super.key, this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final appwrite = AppwriteService();
      appwrite.initialize();
      final user = await appwrite.login(_emailCtrl.text.trim(), _passwordCtrl.text);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email);

      if (!mounted) return;
      ref.read(authServiceProvider.notifier).login(user.email, widget.role ?? UserRole.patient);
      AppToast.show(context, 'Welcome back!', type: ToastType.success);
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppToast.show(
        context,
        msg.toLowerCase().contains('invalid') ? 'Invalid email or password' : msg,
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role ?? UserRole.patient;
    final roleLabel = role.name[0].toUpperCase() + role.name.substring(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top gradient header
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientBlueDiag,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                        onPressed: () => context.go('/role-selection'),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_hospital_rounded,
                                size: 36, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'MediConnect',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Sign in as $roleLabel',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Form card
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, delay: 200.ms),

                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 28),

                      AppInput(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0, delay: 350.ms),

                      const SizedBox(height: 16),

                      AppInput(
                        controller: _passwordCtrl,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          return null;
                        },
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, delay: 400.ms),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 450.ms),

                      const SizedBox(height: 8),

                      GradientButton(
                        label: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        icon: Icons.login_rounded,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0, delay: 500.ms),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.pushNamed('register', extra: widget.role),
                            child: Text(
                              'Register',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
