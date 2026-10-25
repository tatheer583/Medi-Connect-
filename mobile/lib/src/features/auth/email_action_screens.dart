import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_input.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/gradient_button.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

/// Screens that complete Appwrite email actions (verification, password
/// recovery). The emailed links land on `/verify-email?userId=…&secret=…`
/// and `/reset-password?userId=…&secret=…` inside the deployed web app.

class VerifyEmailScreen extends StatefulWidget {
  final String? userId;
  final String? secret;

  const VerifyEmailScreen({super.key, this.userId, this.secret});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = true;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _complete();
  }

  Future<void> _complete() async {
    final userId = widget.userId;
    final secret = widget.secret;
    if (userId == null || userId.isEmpty || secret == null || secret.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'This verification link is missing its token. '
            'Request a new email from your profile page.';
      });
      return;
    }
    try {
      await AppwriteService().verifyEmail(userId, secret);
      if (!mounted) return;
      setState(() => _success = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _loading
                      ? Icons.hourglass_top_rounded
                      : _success
                          ? Icons.mark_email_read_rounded
                          : Icons.error_outline_rounded,
                  size: 80,
                  color: _loading
                      ? AppColors.primary
                      : _success
                          ? AppColors.success
                          : AppColors.error,
                ).animate().scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 24),
                Text(
                  _loading
                      ? 'Verifying your email…'
                      : _success
                          ? 'Email Verified!'
                          : 'Verification Failed',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                if (_success)
                  Text(
                    'Your email address is confirmed. Enjoy full access to '
                    'MediConnect.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                const SizedBox(height: 32),
                if (!_loading)
                  GradientButton(
                    label: _success ? 'Continue' : 'Back to Sign In',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/login'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String? userId;
  final String? secret;

  const ResetPasswordScreen({super.key, this.userId, this.secret});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AppwriteService().completePasswordReset(
        widget.userId!,
        widget.secret!,
        _passwordCtrl.text,
      );
      if (!mounted) return;
      AppToast.show(context,
          'Password updated — sign in with your new password.',
          type: ToastType.success);
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final missingToken = widget.userId == null ||
        widget.userId!.isEmpty ||
        widget.secret == null ||
        widget.secret!.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.lock_reset_rounded,
                    size: 72, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Set a New Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  missingToken
                      ? 'This reset link is missing its token. Please request '
                          'a new reset email from the sign-in screen.'
                      : 'Choose a strong password for your MediConnect account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                if (!missingToken) ...[
                  AppInput(
                    controller: _passwordCtrl,
                    label: 'New Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscure,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _confirmCtrl,
                    label: 'Confirm New Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscure,
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: 'Update Password',
                    icon: Icons.check_rounded,
                    onPressed: _handleReset,
                    isLoading: _isLoading,
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
