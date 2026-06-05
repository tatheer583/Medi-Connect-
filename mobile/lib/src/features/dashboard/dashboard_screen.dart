import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_list_screen.dart';
import 'package:mediconnect_mobile/src/features/profile/profile_screen.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

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
  bool _loadingAppts = true;
  bool _loadingReminders = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = widget.userState.userId ?? '';
    if (userId.isEmpty) {
      setState(() { _loadingAppts = false; _loadingReminders = false; });
      return;
    }
    _loadAppointments(userId);
    _loadReminders(userId);
  }

  Future<void> _loadAppointments(String userId) async {
    try {
      final docs = await DatabaseService().getPatientAppointments(userId);
      if (mounted) {
        setState(() {
          _appointments = docs.take(3).map((d) => d.data).toList();
          _loadingAppts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAppts = false);
    }
  }

  Future<void> _loadReminders(String userId) async {
    try {
      final docs = await DatabaseService().getUserReminders(userId);
      if (mounted) {
        setState(() {
          _reminders = docs.take(3).map((d) => {...d.data, '\$id': d.$id}).toList();
          _loadingReminders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingReminders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userState.name ??
        widget.userState.email?.split('@').first ??
        'Patient';

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Gradient header
          SliverToBoxAdapter(child: _buildHeader(context, name)),

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
          SliverToBoxAdapter(child: _buildAppointmentsSection()),

          // Reminders section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              title: 'Medicine Reminders',
              actionLabel: 'Manage',
              onAction: () => context.pushNamed(AppRoute.reminders.name),
            ),
          ),
          SliverToBoxAdapter(child: _buildRemindersSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
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
              _buildStatChip(Icons.calendar_today_outlined, '${_appointments.length}', 'Appointments'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.medication_outlined, '${_reminders.length}', 'Reminders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.search_rounded, 'label': 'Find Doctor', 'color': AppColors.primary, 'route': AppRoute.doctorSearch.name},
      {'icon': Icons.medication_outlined, 'label': 'Prescriptions', 'color': AppColors.accent, 'route': AppRoute.prescriptionView.name},
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
    );
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

  Widget _buildAppointmentsSection() {
    if (_loadingAppts) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [ShimmerCard(), SizedBox(height: 8), ShimmerCard()]),
      );
    }
    if (_appointments.isEmpty) {
      return _EmptyCard(
        icon: Icons.calendar_today_outlined,
        message: 'No upcoming appointments',
        actionLabel: 'Book Now',
        onAction: () {},
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _appointments.length,
      itemBuilder: (_, i) => _AppointmentCard(appt: _appointments[i]),
    );
  }

  Widget _buildRemindersSection() {
    if (_loadingReminders) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [ShimmerCard(), SizedBox(height: 8)]),
      );
    }
    if (_reminders.isEmpty) {
      return _EmptyCard(
        icon: Icons.medication_outlined,
        message: 'No medicine reminders set',
        actionLabel: 'Add Reminder',
        onAction: () {},
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _reminders.length,
      itemBuilder: (_, i) => _ReminderCard(reminder: _reminders[i]),
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

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final doctorId = widget.userState.userId ?? '';
    if (doctorId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final docs = await DatabaseService().getDoctorAppointments(doctorId);
      if (mounted) {
        setState(() {
          _appointments = docs.map((d) => {...d.data, '\$id': d.$id}).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userState.name ??
        widget.userState.email?.split('@').first ??
        'Doctor';

    return RefreshIndicator(
      onRefresh: _loadAppointments,
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. $name',
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("Today's Schedule", style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('${_appointments.length}',
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Patients', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text("Today's Appointments",
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
              : _appointments.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy_outlined, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text('No appointments today',
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
                            appt: _appointments[i],
                            onStart: () => context.pushNamed(
                              AppRoute.prescriptionEditor.name,
                              extra: {
                                'name': _appointments[i]['patientName'] ?? 'Patient',
                                'id': _appointments[i]['patientId'] ?? '',
                              },
                            ),
                          ),
                        ),
                        childCount: _appointments.length,
                      ),
                    ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
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
                  '${appt['specialty'] ?? ''} • ${appt['date'] ?? ''}',
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
  final VoidCallback onStart;
  const _DoctorAppointmentCard({required this.appt, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  appt['patientName'] as String? ?? 'Patient',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  appt['timeSlot'] as String? ?? appt['date'] as String? ?? '',
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
