import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediconnect_mobile/src/services/ai_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class AiSummaryWidget extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AiSummaryWidget({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AiSummaryWidget> createState() => _AiSummaryWidgetState();
}

class _AiSummaryWidgetState extends State<AiSummaryWidget> {
  String? _summary;
  bool _loading = false;
  bool _expanded = false;

  Future<void> _generateSummary() async {
    setState(() {
      _loading = true;
      _expanded = true;
    });

    try {
      // Fetch patient data from Appwrite
      final appointments =
          await DatabaseService().getPatientAppointments(widget.patientId);
      final prescriptions =
          await DatabaseService().getPatientPrescriptions(widget.patientId);
      final labResults =
          await DatabaseService().getPatientLabResults(widget.patientId);

      final pastApts = appointments
          .take(5)
          .map((d) =>
              '${d.data['date']} with ${d.data['doctorName']} (${d.data['status']})')
          .toList();

      final medicines = prescriptions.isNotEmpty
          ? (prescriptions.first.data['medicines'] as List<dynamic>? ?? [])
              .map((m) => m.toString().split('|').first)
              .toList()
          : <String>[];

      final labs = labResults
          .take(3)
          .map((d) => '${d.data['testName']} on ${d.data['uploadedAt']?.toString().substring(0, 10)}')
          .toList();

      final summary = await AiService().generatePatientSummary(
        patientName: widget.patientName,
        pastAppointments: pastApts.cast<String>(),
        currentMedicines: medicines.cast<String>(),
        labResults: labs.cast<String>(),
      );

      if (mounted) setState(() => _summary = summary);
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Failed to generate summary', type: ToastType.error);
        setState(() => _expanded = false);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header button
          InkWell(
            onTap: _loading ? null : _generateSummary,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Pre-Appointment Summary',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        Text(
                          'Powered by Claude AI',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _summary == null ? 'Generate' : 'Refresh',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Summary text
          if (_expanded && _summary != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _summary!,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.6),
              ),
            ),

          if (_expanded && _loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerLine(double.infinity),
                    const SizedBox(height: 8),
                    _shimmerLine(double.infinity),
                    const SizedBox(height: 8),
                    _shimmerLine(200),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shimmerLine(double width) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
