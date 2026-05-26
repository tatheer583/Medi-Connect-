import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/services/notification_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';
import 'package:mediconnect_mobile/src/shared/widgets/gradient_button.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(authServiceProvider).userId ?? '';
      final docs = await DatabaseService().getUserReminders(userId);
      setState(() {
        _reminders = docs.map((d) => {...d.data, '\$id': d.$id}).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addReminder() async {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Medicine Reminder',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: const Icon(Icons.medication_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageCtrl,
                decoration: InputDecoration(
                  labelText: 'Dosage (e.g. 500mg)',
                  prefixIcon: const Icon(Icons.scale_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        selectedTime.format(ctx),
                        style: GoogleFonts.inter(
                            fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Set Reminder',
                icon: Icons.alarm_add_rounded,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);

                  try {
                    final userId =
                        ref.read(authServiceProvider).userId ?? '';
                    final timeStr =
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                    final doc = await DatabaseService().createReminder(
                      userId: userId,
                      medicineName: nameCtrl.text.trim(),
                      dosage: dosageCtrl.text.trim(),
                      time: selectedTime.format(context),
                      active: true,
                    );

                    // Schedule local notification
                    final reminderId =
                        doc.$id.hashCode.abs() % 100000;
                    await NotificationService().scheduleMedicineReminder(
                      id: reminderId,
                      medicineName: nameCtrl.text.trim(),
                      dosage: dosageCtrl.text.trim(),
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                    );

                    if (mounted) {
                      AppToast.show(context, 'Reminder set for $timeStr',
                          type: ToastType.success);
                      _loadReminders();
                    }
                  } catch (e) {
                    if (mounted) {
                      AppToast.show(context, 'Failed to set reminder',
                          type: ToastType.error);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTaken(Map<String, dynamic> reminder) async {
    try {
      final newValue = !(reminder['takenToday'] as bool? ?? false);
      await DatabaseService().updateReminder(
        reminder['\$id'] as String,
        {'takenToday': newValue},
      );
      if (mounted) {
        AppToast.show(
          context,
          newValue ? 'Marked as taken ✓' : 'Marked as skipped',
          type: newValue ? ToastType.success : ToastType.info,
        );
        _loadReminders();
      }
    } catch (_) {}
  }

  Future<void> _deleteReminder(String id) async {
    try {
      await DatabaseService().deleteReminder(id);
      await NotificationService().cancelReminder(id.hashCode.abs() % 100000);
      if (mounted) {
        AppToast.show(context, 'Reminder deleted', type: ToastType.info);
        _loadReminders();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Medicine Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Add Reminder'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  children: [ShimmerCard(), ShimmerCard(), ShimmerCard()]),
            )
          : _reminders.isEmpty
              ? EmptyState(
                  icon: Icons.alarm_rounded,
                  title: 'No Reminders',
                  subtitle: 'Add medicine reminders to stay on track',
                  actionLabel: 'Add Reminder',
                  onAction: _addReminder,
                )
              : RefreshIndicator(
                  onRefresh: _loadReminders,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _reminders.length,
                    itemBuilder: (context, i) {
                      final r = _reminders[i];
                      final taken = r['takenToday'] as bool? ?? false;
                      return _ReminderCard(
                        reminder: r,
                        taken: taken,
                        onToggle: () => _toggleTaken(r),
                        onDelete: () =>
                            _deleteReminder(r['\$id'] as String),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final bool taken;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.taken,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: taken
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                taken
                    ? Icons.check_circle_rounded
                    : Icons.medication_rounded,
                color: taken ? AppColors.success : AppColors.warning,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['medicineName'] ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                Text(
                  '${reminder['dosage'] ?? ''} • ${reminder['time'] ?? ''}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: taken
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
