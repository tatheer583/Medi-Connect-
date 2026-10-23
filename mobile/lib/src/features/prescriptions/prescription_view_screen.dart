import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/services/pdf_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

/// Shows the patient's REAL prescriptions from Appwrite (no mock data).
/// When several exist, a date selector lets the patient switch between them;
/// Download opens the print/share sheet and Share forwards the PDF.
class PrescriptionViewScreen extends ConsumerStatefulWidget {
  const PrescriptionViewScreen({super.key});

  @override
  ConsumerState<PrescriptionViewScreen> createState() =>
      _PrescriptionViewScreenState();
}

class _PrescriptionViewScreenState extends ConsumerState<PrescriptionViewScreen> {
  List<models.Document> _prescriptions = [];
  int _index = 0;
  bool _loading = true;
  bool _busyPdf = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(authServiceProvider).userId ?? '';
      if (userId.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final docs = await DatabaseService().getPatientPrescriptions(userId);
      if (!mounted) return;
      setState(() {
        _prescriptions = docs;
        _index = 0;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load prescriptions: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  models.Document? get _current =>
      _prescriptions.isNotEmpty ? _prescriptions[_index] : null;

  Future<void> _sharePdf() async {
    final doc = _current;
    if (doc == null) return;
    setState(() => _busyPdf = true);
    try {
      final file = await PdfService().generatePrescriptionPdf(
        doctorName: doc.data['doctorName']?.toString() ?? 'Doctor',
        doctorLicense:
            doc.data['doctorLicense']?.toString() ?? 'Licensed Physician',
        patientName: doc.data['patientName']?.toString() ?? 'Patient',
        diagnosis: doc.data['diagnosis']?.toString() ?? '',
        medicines: DatabaseService.decodeMedicines(doc.data['medicines']),
        instructions: doc.data['instructions']?.toString() ?? '',
        date: _fmtDate(doc.data['createdAt']),
      );
      await PdfService().printOrShare(file);
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Could not open the PDF: $e',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _busyPdf = false);
    }
  }

  String _fmtDate(dynamic iso) {
    final dt = DateTime.tryParse(iso?.toString() ?? '');
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          IconButton(
            onPressed: _busyPdf || _current == null ? null : _sharePdf,
            icon: _busyPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.print_outlined),
            tooltip: 'Print / share PDF',
          ),
        ],
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [ShimmerCard(), ShimmerCard(), ShimmerCard()]),
            )
          : _current == null
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Prescriptions Yet',
                  subtitle:
                      'Prescriptions issued to you by your doctor will appear here.',
                  actionLabel: 'Refresh',
                  onAction: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: _buildPrescription(_current!),
                  ),
                ),
    );
  }

  Widget _buildPrescription(models.Document doc) {
    final data = doc.data;
    final medicines = DatabaseService.decodeMedicines(data['medicines']);

    if (_prescriptions.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelector(),
          const SizedBox(height: 12),
          _buildCard(data, medicines),
        ],
      );
    }
    return _buildCard(data, medicines);
  }

  Widget _buildSelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _prescriptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == _index;
          return ChoiceChip(
            label: Text('#${i + 1} • ${_fmtDate(_prescriptions[i].data['createdAt'])}'),
            selected: selected,
            onSelected: (_) => setState(() => _index = i),
            selectedColor: AppColors.primary,
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
      Map<String, dynamic> data, List<Map<String, String>> medicines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(data),
        const Divider(height: 40),
        const Text('Diagnosis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          data['diagnosis']?.toString() ?? '—',
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 32),
        const Text('Medicines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (medicines.isEmpty)
          const Text('No medicines recorded.')
        else
          ...medicines.map((m) => _buildMedicineItem(
                m['name'] ?? '',
                m['frequency'] ?? '',
                m['duration'] ?? '',
              )),
        const SizedBox(height: 32),
        const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          data['instructions']?.toString() ?? 'Follow your doctor’s advice.',
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Text(
                data['doctorName']?.toString() ?? 'Doctor',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Licensed Physician'),
              const SizedBox(height: 8),
              Container(height: 1, width: 150, color: Colors.black),
              const Text('Digital Signature'),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MediConnect', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text('Issued by: ${data['doctorName'] ?? "Doctor"}'),
            Text('Patient: ${data['patientName'] ?? "Patient"}'),
            Text('Date: ${_fmtDate(data['createdAt'])}'),
          ],
        ),
        const Icon(Icons.local_hospital, size: 50, color: Colors.blue),
      ],
    );
  }

  Widget _buildMedicineItem(String name, String frequency, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.medication_rounded, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$frequency • $duration',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
