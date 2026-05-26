import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(authServiceProvider).userId ?? '';
      final docs = await DatabaseService().getPatientAppointments(userId);
      setState(() {
        _appointments = docs.map((d) => d.data).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelAppointment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Appointment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService().updateAppointmentStatus(id, 'cancelled');
        if (mounted) {
          AppToast.show(context, 'Appointment cancelled', type: ToastType.info);
          _loadAppointments();
        }
      } catch (e) {
        if (mounted) AppToast.show(context, 'Failed to cancel', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Appointments')),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [ShimmerCard(), ShimmerCard(), ShimmerCard()]),
            )
          : _appointments.isEmpty
              ? EmptyState(
                  icon: Icons.calendar_today_rounded,
                  title: 'No Appointments',
                  subtitle: 'Book your first appointment with a doctor',
                  actionLabel: 'Find a Doctor',
                  onAction: () => Navigator.pop(context),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appointments.length,
                    itemBuilder: (context, i) {
                      final apt = _appointments[i];
                      return _AppointmentCard(
                        appointment: apt,
                        onCancel: apt['status'] == 'pending' || apt['status'] == 'confirmed'
                            ? () => _cancelAppointment(apt['\$id'] ?? '')
                            : null,
                      );
                    },
                  ),
                ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onCancel;

  const _AppointmentCard({required this.appointment, this.onCancel});

  Color _statusColor(String status) => switch (status) {
        'confirmed' => AppColors.success,
        'pending' => AppColors.warning,
        'completed' => AppColors.primary,
        'cancelled' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  IconData _statusIcon(String status) => switch (status) {
        'confirmed' => Icons.check_circle_rounded,
        'pending' => Icons.pending_rounded,
        'completed' => Icons.task_alt_rounded,
        'cancelled' => Icons.cancel_rounded,
        _ => Icons.info_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'] ?? 'pending';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctorName'] ?? 'Doctor',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      appointment['specialty'] ?? '',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(status), size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(appointment['date'] ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(appointment['timeSlot'] ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text('PKR ${appointment['fee'] ?? '0'}',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel Appointment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
