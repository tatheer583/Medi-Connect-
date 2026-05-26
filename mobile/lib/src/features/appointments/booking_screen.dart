import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/services/notification_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/gradient_button.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Map<String, String> doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  bool _isBooking = false;

  final List<String> _allSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];

  // Slots already booked (would come from DB in production)
  final List<String> _bookedSlots = ['09:30 AM', '11:00 AM', '03:00 PM'];

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) return;

    setState(() => _isBooking = true);

    try {
      final userState = ref.read(authServiceProvider);
      final userId = userState.userId ?? 'unknown';
      final userName = userState.email?.split('@').first ?? 'Patient';
      final dateStr = DateFormat('dd MMM yyyy').format(_selectedDate);
      final slot = _selectedSlot!;

      await DatabaseService().createAppointment(
        patientId: userId,
        patientName: userName,
        doctorId: widget.doctor['id'] ?? widget.doctor['name'] ?? 'doc',
        doctorName: widget.doctor['name'] ?? 'Doctor',
        specialty: widget.doctor['specialty'] ?? '',
        date: dateStr,
        timeSlot: slot,
        fee: widget.doctor['fee'] ?? '0',
      );

      // Show local notification confirmation
      await NotificationService().showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Appointment Booked',
        body:
            'Your appointment with ${widget.doctor['name']} on $dateStr at $slot is confirmed.',
      );

      if (!mounted) return;
      AppToast.show(
        context,
        'Appointment booked for $dateStr at $slot',
        type: ToastType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        'Booking failed: ${e.toString().replaceFirst('Exception: ', '')}',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Doctor card
            _DoctorInfoCard(doctor: widget.doctor),

            const SizedBox(height: 8),

            // Date picker
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Select Date',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            _DatePicker(
              selectedDate: _selectedDate,
              onDateSelected: (d) => setState(() {
                _selectedDate = d;
                _selectedSlot = null;
              }),
            ),

            const SizedBox(height: 16),

            // Time slots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Available Slots',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _allSlots.map((slot) {
                  final isBooked = _bookedSlots.contains(slot);
                  final isSelected = _selectedSlot == slot;
                  return _TimeSlotChip(
                    slot: slot,
                    isBooked: isBooked,
                    isSelected: isSelected,
                    onTap: isBooked
                        ? null
                        : () => setState(() => _selectedSlot = slot),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientButton(
                label: 'Confirm Booking',
                icon: Icons.check_circle_rounded,
                isLoading: _isBooking,
                onPressed: _selectedSlot == null ? null : _confirmBooking,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DoctorInfoCard extends StatelessWidget {
  final Map<String, String> doctor;
  const _DoctorInfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'] ?? 'Doctor',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                Text(doctor['specialty'] ?? '',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(doctor['rating'] ?? '4.9',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    const Icon(Icons.payments_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('PKR ${doctor['fee'] ?? '2000'}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const _DatePicker({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, i) {
          final date = DateTime.now().add(Duration(days: i + 1));
          final isSelected = selectedDate.day == date.day &&
              selectedDate.month == date.month;
          final isWeekend = date.weekday == 6 || date.weekday == 7;

          return GestureDetector(
            onTap: isWeekend ? null : () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.gradientBlue : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white70
                          : isWeekend
                              ? AppColors.textHint
                              : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isWeekend
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String slot;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.slot,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.gradientBlue : null,
          color: isSelected
              ? null
              : isBooked
                  ? AppColors.divider
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.divider,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          slot,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isBooked
                    ? AppColors.textHint
                    : AppColors.textPrimary,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
