import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_list_screen.dart';
import 'package:mediconnect_mobile/src/features/prescriptions/ai_summary_widget.dart';
import 'package:mediconnect_mobile/src/features/profile/profile_screen.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authServiceProvider);
    final isDoctor = userState.role == UserRole.doctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(userState),
      bottomNavigationBar: _buildBottomNav(isDoctor),
    );
  }

  Widget _buildBody(UserState userState) {
    final isDoctor = userState.role == UserRole.doctor;
    switch (_selectedIndex) {
      case 1:
        return const ChatListScreen();
      case 2:
        return const ProfileScreen();
      default:
        return isDoctor
            ? _DoctorDashboardBody(userState: userState)
            : _PatientDashboardBody(userState: userState);
    }
  }

  Widget _buildBottomNav(bool isDoctor) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      backgroundColor: Colors.white,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      items: isDoctor
          ? const [
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Schedule'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Messages'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ]
          : const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Messages'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Days from today until an ISO date (yyyy-MM-dd); negative when past.
int _daysUntil(dynamic rawDate) {
  final d = DateTime.tryParse(rawDate?.toString() ?? '');
  if (d == null) return 0;
  final today = DateTime.now();
  return DateTime(d.year, d.month, d.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
}

bool _isUpcoming(Map<String, dynamic> appt) {
  final status = appt['status']?.toString() ?? 'pending';
  if (status == 'cancelled' || status == 'completed') return false;
  return _daysUntil(appt['date']) >= 0;
}

/// Formats ISO dates (yyyy-MM-dd) for display, passing anything else through.
String _fmtApptDate(dynamic rawDate) {
  final s = rawDate?.toString() ?? '';
  if (s.isEmpty) return '';
  final d = DateTime.tryParse(s);
  if (d == null) return s;
  return DateFormat('dd MMM yyyy').format(d);
}

// ─── Patient Dashboard ────────────────────────────────────────────────────────

class _PatientDashboardBody extends ConsumerStatefulWidget {
  final UserState userState;
  const _PatientDashboardBody({required this.userState});

  @override
  ConsumerState<_PatientDashboardBody> createState() => _PatientDashboardBodyState();
}

class _PatientDashboardBodyState extends ConsumerState<_PatientDashboardBody> {
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _reminders = [];
  int _prescriptionCount = 0;
  bool _loadingAppts = true;
  bool _loadingReminders = true;

  /// null = still checking, true/false = verification state.
  bool? _emailVerified;
  bool _bannerHidden = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadVerificationState();
  }

  Future<void> _loadVerificationState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('verify_banner_dismissed') ?? false) return;
    final verified = await AppwriteService().isEmailVerified();
    if (mounted) {
      setState(() {
        _emailVerified = verified;
        _bannerHidden = verified;
      });
    }
  }

  Future<void> _dismissVerifyBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('verify_banner_dismissed', true);
    if (mounted) setState(() => _bannerHidden = true);
  }

  Future<void> _resendVerification() async {
    try {
      await AppwriteService().sendEmailVerification();
      if (!mounted) return;
      AppToast.show(context, 'Verification email sent — check your inbox',
          type: ToastType.success);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, e.toString().replaceFirst('Exception: ', ''),
          type: ToastType.error);
    }
  }

  Future<void> _loadData() async {
    final userId = widget.userState.userId ?? '';
    if (userId.isEmpty) {
      setState(() { _loadingAppts = false; _loadingReminders = false; });
      return;
    }
    _loadAppointments(userId);
    _loadReminders(userId);
    _loadPrescriptionCount(userId);
  }

  Future<void> _loadAppointments(String userId) async {
    try {
      final docs = await DatabaseService().getPatientAppointments(userId);
      if (mounted) {
        setState(() {
          _appointments = docs
              .map((d) => {'\$id': d.$id, ...d.data})
              .toList();
          _loadingAppts = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load appointments: $e');
      if (mounted) setState(() => _loadingAppts = false);
    }
  }

  Future<void> _loadReminders(String userId) async {
    try {
      final docs = await DatabaseService().getUserReminders(userId);
      if (mounted) {
        setState(() {
          _reminders = docs.map((d) => {...d.data, '\$id': d.$id}).toList();
          _loadingReminders = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load reminders: $e');
      if (mounted) setState(() => _loadingReminders = false);
    }
  }

  Future<void> _loadPrescriptionCount(String userId) async {
    try {
      final docs = await DatabaseService().getPatientPrescriptions(userId);
      if (mounted) setState(() => _prescriptionCount = docs.length);
    } catch (_) {}
  }

  /// First upcoming (pending/confirmed, today or later) — shown as hero.
  Map<String, dynamic>? get _nextAppointment {
    final upcoming = _appointments.where(_isUpcoming).toList()
      ..sort((a, b) =>
          (a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? ''));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userState.name ??
        widget.userState.email?.split('@').first ??
        'Patient';
    final upcoming =
        _appointments.where(_isUpcoming).toList();
    final activeReminders =
        _reminders.where((r) => r['active'] as bool? ?? true).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, name, upcoming.length, activeReminders.length)),

          // Email verification banner — real Appwrite account state.
          if (!_bannerHidden && _emailVerified == false)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _VerifyEmailBanner(
                  onResend: _resendVerification,
                  onDismiss: _dismissVerifyBanner,
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

          // Next appointment hero
          SliverToBoxAdapter(child: _buildNextAppointmentHero()),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildQuickActions(context),
            ),
          ),

          // Appointments section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              title: 'Upcoming Appointments',
              actionLabel: 'See All',
              onAction: () => context.pushNamed(AppRoute.appointments.name),
            ),
          ),
          SliverToBoxAdapter(child: _buildAppointmentsSection(upcoming)),

          // Reminders section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              title: 'Medicine Reminders',
              actionLabel: 'Manage',
              onAction: () => context.pushNamed(AppRoute.reminders.name),
            ),
          ),
          SliverToBoxAdapter(child: _buildRemindersSection(activeReminders)),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, int apptCount, int reminderCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.gradientBlueDiag,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_timeGreeting()}, $name 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'How are you feeling today?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed(AppRoute.reminders.name),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildStatChip(Icons.calendar_today_outlined, '$apptCount', 'Appointments'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.receipt_long_outlined, '$_prescriptionCount', 'Prescriptions'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.medication_outlined, '$reminderCount', 'Reminders'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutQuad).slideY(begin: -0.1);
  }

  /// Highlighted card for the nearest upcoming appointment.
  Widget _buildNextAppointmentHero() {
    final appt = _nextAppointment;
    if (appt == null && !_loadingAppts) return const SizedBox.shrink();

    if (_loadingAppts) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ShimmerCard(),
      );
    }

    final days = _daysUntil(appt!['date']);
    final whenText = days == 0
        ? 'Today'
        : days == 1
            ? 'Tomorrow'
            : 'In $days days';
    final date = DateTime.tryParse(appt['date']?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => context.pushNamed(AppRoute.appointments.name),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.gradientBlue,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Date badge
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      date != null ? DateFormat('dd').format(date) : '—',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    Text(
                      date != null ? DateFormat('MMM').format(date) : '',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appt['doctorName']?.toString() ?? 'Doctor',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            whenText,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appt['specialty'] ?? ''} • ${appt['timeSlot'] ?? ''}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.08);
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.search_rounded, 'label': 'Find Doctor', 'color': AppColors.primary, 'route': AppRoute.doctorSearch.name},
      {'icon': Icons.receipt_long_outlined, 'label': 'Prescriptions', 'color': AppColors.accent, 'route': AppRoute.prescriptionView.name},
      {'icon': Icons.science_outlined, 'label': 'Lab Results', 'color': const Color(0xFF9C27B0), 'route': AppRoute.labResults.name},
      {'icon': Icons.alarm_rounded, 'label': 'Reminders', 'color': const Color(0xFFF57C00), 'route': AppRoute.reminders.name},
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: actions.map((a) {
        final color = a['color'] as Color;
        return GestureDetector(
          onTap: () => context.pushNamed(a['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(a['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  a['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required String actionLabel, required VoidCallback onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection(List<Map<String, dynamic>> upcoming) {
    if (_loadingAppts) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [ShimmerCard(), SizedBox(height: 8), ShimmerCard()]),
      );
    }
    if (upcoming.isEmpty) {
      return _EmptyCard(
        icon: Icons.calendar_today_outlined,
        message: 'No upcoming appointments',
        actionLabel: 'Book Now',
        onAction: () => context.pushNamed(AppRoute.doctorSearch.name),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: upcoming.length,
      itemBuilder: (_, i) => _AppointmentCard(appt: upcoming[i])
          .animate(delay: (i * 100).ms)
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildRemindersSection(List<Map<String, dynamic>> activeReminders) {
    if (_loadingReminders) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [ShimmerCard(), SizedBox(height: 8)]),
      );
    }
    if (activeReminders.isEmpty) {
      return _EmptyCard(
        icon: Icons.medication_outlined,
        message: 'No medicine reminders set',
        actionLabel: 'Add Reminder',
        onAction: () => context.pushNamed(AppRoute.reminders.name),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: activeReminders.take(3).length,
      itemBuilder: (_, i) => _ReminderCard(reminder: activeReminders[i])
          .animate(delay: (i * 100).ms)
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, curve: Curves.easeOutQuad),
    );
  }
}

/// Amber banner prompting the user to confirm their email address.
class _VerifyEmailBanner extends StatelessWidget {
  final VoidCallback onResend;
  final VoidCallback onDismiss;
  const _VerifyEmailBanner({required this.onResend, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mark_email_unread_outlined,
              color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Please verify your email address to secure your account.',
              style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                  height: 1.3),
            ),
          ),
          TextButton(
            onPressed: onResend,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Resend',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

// ─── Doctor Dashboard ────────────────────────────────────────────────────────

class _DoctorDashboardBody extends ConsumerStatefulWidget {
  final UserState userState;
  const _DoctorDashboardBody({required this.userState});

  @override
  ConsumerState<_DoctorDashboardBody> createState() => _DoctorDashboardBodyState();
}

class _DoctorDashboardBodyState extends ConsumerState<_DoctorDashboardBody> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;

  /// null = loading, else the doctor's current directory availability.
  bool? _available;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final userId = widget.userState.userId ?? '';
    if (userId.isEmpty) return;
    final row = await DatabaseService().getDoctorByUserId(userId);
    if (mounted) {
      setState(() => _available = row?.data['available'] as bool? ?? true);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    final userId = widget.userState.userId ?? '';
    if (userId.isEmpty) return;
    // Optimistic update; revert on failure.
    setState(() => _available = value);
    try {
      await DatabaseService().setDoctorAvailability(userId, available: value);
      if (!mounted) return;
      AppToast.show(
        context,
        value
            ? 'You are now visible to patients'
            : 'You are hidden from new bookings',
        type: ToastType.info,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _available = !value);
      AppToast.show(context, e.toString().replaceFirst('Exception: ', ''),
          type: ToastType.error);
    }
  }

  Future<void> _loadAppointments() async {
    final userId = widget.userState.userId ?? '';
    if (userId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final name = widget.userState.name;
    try {
      // Fall through: doctors-row → user id → display name.
      final docs = await DatabaseService().getDoctorSchedule(userId, name);
      if (mounted) {
        setState(() {
          _appointments = docs
              .map((d) => {'\$id': d.$id, ...d.data})
              .toList()
            ..sort((a, b) =>
                (a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? ''));
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load doctor schedule: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userState.name ??
        widget.userState.email?.split('@').first ??
        'Doctor';
    final upcoming = _appointments.where(_isUpcoming).toList();
    final todayCount =
        upcoming.where((a) => _daysUntil(a['date']) == 0).length;
    final pendingCount =
        upcoming.where((a) => (a['status']?.toString() ?? '') == 'pending').length;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadAppointments();
        await _loadAvailability();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientBlueDiag,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dr. $name',
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('${_timeGreeting()} — here is your queue',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                      // Availability toggle — controls visibility in the
                      // patient directory in real time.
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _available == false
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _available == null ? '…' : (_available! ? 'Available' : 'Hidden'),
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: 22,
                                  child: Switch(
                                    value: _available ?? true,
                                    activeColor: AppColors.accent,
                                    inactiveThumbColor: Colors.white70,
                                    inactiveTrackColor: Colors.white24,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: _available == null
                                        ? null
                                        : _toggleAvailability,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDoctorStat('$todayCount', "Today's patients"),
                      const SizedBox(width: 12),
                      _buildDoctorStat('$pendingCount', 'Pending requests'),
                      const SizedBox(width: 12),
                      _buildDoctorStat('${upcoming.length}', 'Total upcoming'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Upcoming Appointments',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),
          ),

          _loading
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: const [ShimmerCard(), SizedBox(height: 8), ShimmerCard()]),
                  ),
                )
              : upcoming.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy_outlined, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text('No upcoming appointments',
                                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: _DoctorAppointmentCard(
                            appt: upcoming[i],
                            isToday: _daysUntil(upcoming[i]['date']) == 0,
                            onStart: () => context.pushNamed(
                              AppRoute.prescriptionEditor.name,
                              extra: {
                                'name': upcoming[i]['patientName'] ?? 'Patient',
                                'id': upcoming[i]['patientId'] ?? '',
                              },
                            ),
                          ).animate(delay: (i * 100).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1, curve: Curves.easeOutQuad),
                        ),
                        childCount: upcoming.length,
                      ),
                    ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDoctorStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Cards ─────────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  const _AppointmentCard({required this.appt});

  @override
  Widget build(BuildContext context) {
    final status = appt['status'] as String? ?? 'pending';
    final statusColor = status == 'confirmed'
        ? AppColors.success
        : status == 'completed'
            ? AppColors.textSecondary
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt['doctorName'] as String? ?? 'Doctor',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  '${appt['specialty'] ?? ''} • ${_fmtApptDate(appt['date'])} • ${appt['timeSlot'] ?? ''}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  final bool isToday;
  final VoidCallback onStart;
  const _DoctorAppointmentCard({
    required this.appt,
    required this.isToday,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isToday
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
                : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appt['patientName'] as String? ?? 'Patient',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Today',
                                style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${appt['timeSlot'] ?? ''} • ${_fmtApptDate(appt['date'])}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onStart,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Start', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AiSummaryWidget(
          patientId: appt['patientId']?.toString() ?? '',
          patientName: appt['patientName']?.toString() ?? 'Patient',
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final taken = reminder['takenToday'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (taken ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              taken ? Icons.check_circle_rounded : Icons.medication_rounded,
              color: taken ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['medicineName'] as String? ?? '',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  '${reminder['dosage'] ?? ''} • ${reminder['time'] ?? ''}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (taken ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              taken ? 'Taken' : 'Pending',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: taken ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  const _EmptyCard({required this.icon, required this.message, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13))),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
