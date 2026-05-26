import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/services/pdf_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/gradient_button.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class PrescriptionEditorScreen extends ConsumerStatefulWidget {
  final String patientName;
  final String? patientId;

  const PrescriptionEditorScreen({
    super.key,
    required this.patientName,
    this.patientId,
  });

  @override
  ConsumerState<PrescriptionEditorScreen> createState() =>
      _PrescriptionEditorScreenState();
}

class _PrescriptionEditorScreenState
    extends ConsumerState<PrescriptionEditorScreen> {
  final _diagnosisCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final List<Map<String, String>> _medicines = [];
  bool _isSaving = false;
  bool _isGeneratingPdf = false;

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  void _addMedicine() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
            Text('Add Medicine',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _field(nameCtrl, 'Medicine Name', Icons.medication_rounded),
            const SizedBox(height: 12),
            _field(dosageCtrl, 'Dosage (e.g. 500mg)', Icons.scale_rounded),
            const SizedBox(height: 12),
            _field(freqCtrl, 'Frequency (e.g. 1-0-1)', Icons.repeat_rounded),
            const SizedBox(height: 12),
            _field(durationCtrl, 'Duration (e.g. 7 days)',
                Icons.calendar_today_rounded),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Add Medicine',
              icon: Icons.add_rounded,
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                setState(() {
                  _medicines.add({
                    'name': nameCtrl.text.trim(),
                    'dosage': dosageCtrl.text.trim(),
                    'frequency': freqCtrl.text.trim(),
                    'duration': durationCtrl.text.trim(),
                  });
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _savePrescription() async {
    if (_diagnosisCtrl.text.trim().isEmpty) {
      AppToast.show(context, 'Please enter a diagnosis', type: ToastType.warning);
      return;
    }
    if (_medicines.isEmpty) {
      AppToast.show(context, 'Add at least one medicine', type: ToastType.warning);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userState = ref.read(authServiceProvider);
      await DatabaseService().createPrescription(
        doctorId: userState.userId ?? '',
        doctorName: userState.email?.split('@').first ?? 'Doctor',
        patientId: widget.patientId ?? 'unknown',
        patientName: widget.patientName,
        diagnosis: _diagnosisCtrl.text.trim(),
        medicines: _medicines,
        instructions: _instructionsCtrl.text.trim(),
      );

      if (!mounted) return;
      AppToast.show(context, 'Prescription saved successfully', type: ToastType.success);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, 'Failed to save: ${e.toString().replaceFirst('Exception: ', '')}',
          type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_diagnosisCtrl.text.trim().isEmpty || _medicines.isEmpty) {
      AppToast.show(context, 'Fill in diagnosis and medicines first',
          type: ToastType.warning);
      return;
    }

    setState(() => _isGeneratingPdf = true);

    try {
      final userState = ref.read(authServiceProvider);
      final doctorName = userState.email?.split('@').first ?? 'Doctor';
      final date = DateFormat('dd MMM yyyy').format(DateTime.now());

      final file = await PdfService().generatePrescriptionPdf(
        doctorName: doctorName,
        doctorLicense: 'PMDC-12345',
        patientName: widget.patientName,
        diagnosis: _diagnosisCtrl.text.trim(),
        medicines: _medicines,
        instructions: _instructionsCtrl.text.trim(),
        date: date,
      );

      await PdfService().printOrShare(file);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, 'PDF generation failed', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rx: ${widget.patientName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Generate PDF',
            onPressed: _isGeneratingPdf ? null : _generatePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Diagnosis
            _SectionCard(
              title: 'Diagnosis',
              icon: Icons.medical_information_rounded,
              child: TextField(
                controller: _diagnosisCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter diagnosis details...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textHint),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.inputFill,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Medicines
            _SectionCard(
              title: 'Medicines',
              icon: Icons.medication_rounded,
              trailing: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                ),
                onPressed: _addMedicine,
              ),
              child: _medicines.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text('No medicines added yet',
                            style: GoogleFonts.inter(color: AppColors.textHint)),
                      ),
                    )
                  : Column(
                      children: _medicines.asMap().entries.map((entry) {
                        final i = entry.key;
                        final med = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(med['name'] ?? '',
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    Text(
                                        '${med['dosage']} • ${med['frequency']} • ${med['duration']}',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error, size: 20),
                                onPressed: () =>
                                    setState(() => _medicines.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 16),

            // Instructions
            _SectionCard(
              title: 'Instructions',
              icon: Icons.notes_rounded,
              child: TextField(
                controller: _instructionsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Special instructions for patient...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textHint),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.inputFill,
                ),
              ),
            ),

            const SizedBox(height: 24),

            GradientButton(
              label: 'Save & Issue Prescription',
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              onPressed: _savePrescription,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
