import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/app_toast.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class LabResultsScreen extends ConsumerStatefulWidget {
  const LabResultsScreen({super.key});

  @override
  ConsumerState<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends ConsumerState<LabResultsScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(authServiceProvider).userId ?? '';
      final docs = await DatabaseService().getPatientLabResults(userId);
      setState(() {
        _results = docs.map((d) => {...d.data, '\$id': d.$id}).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _uploadResult() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;
    if (!mounted) return;

    // Show test name dialog
    final nameCtrl = TextEditingController();
    // ignore: use_build_context_synchronously
    final testName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Test Name'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. Complete Blood Count',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (testName == null || testName.isEmpty) return;

    setState(() => _uploading = true);

    try {
      final userId = ref.read(authServiceProvider).userId ?? '';
      final userEmail = ref.read(authServiceProvider).email ?? 'Unknown';

      // Upload file to Appwrite Storage
      final uploadedFile = await DatabaseService().uploadFile(
        bucketId: AppwriteDB.labResultsBucket,
        filePath: file.path!,
        fileName: file.name,
      );

      // Save record to database
      await DatabaseService().createLabResult(
        patientId: userId,
        testName: testName,
        uploadedBy: userEmail,
        fileId: uploadedFile.$id,
        fileType: file.extension?.toUpperCase() ?? 'FILE',
      );

      if (mounted) {
        AppToast.show(context, 'Lab result uploaded successfully',
            type: ToastType.success);
        _loadResults();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
            context,
            'Upload failed: ${e.toString().replaceFirst('Exception: ', '')}',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(isoString));
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lab Reports')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _uploadResult,
        icon: _uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.upload_file_rounded),
        label: Text(_uploading ? 'Uploading...' : 'Upload Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  children: [ShimmerCard(), ShimmerCard(), ShimmerCard()]),
            )
          : _results.isEmpty
              ? EmptyState(
                  icon: Icons.science_rounded,
                  title: 'No Lab Reports',
                  subtitle: 'Upload your lab results to keep them organized',
                  actionLabel: 'Upload Report',
                  onAction: _uploadResult,
                )
              : RefreshIndicator(
                  onRefresh: _loadResults,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final r = _results[i];
                      return _LabResultCard(
                        testName: r['testName'] ?? 'Unknown Test',
                        uploadedBy: r['uploadedBy'] ?? '',
                        date: _formatDate(r['uploadedAt'] as String?),
                        fileType: r['fileType'] ?? 'FILE',
                        fileId: r['fileId'] ?? '',
                      );
                    },
                  ),
                ),
    );
  }
}

class _LabResultCard extends StatelessWidget {
  final String testName;
  final String uploadedBy;
  final String date;
  final String fileType;
  final String fileId;

  const _LabResultCard({
    required this.testName,
    required this.uploadedBy,
    required this.date,
    required this.fileType,
    required this.fileId,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = fileType == 'PDF';
    final color = isPdf ? AppColors.error : Colors.purple;

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(date,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    const Icon(Icons.person_outline_rounded,
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(uploadedBy,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(fileType,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded,
                color: AppColors.primary, size: 20),
            onPressed: () {
              final url = DatabaseService()
                  .getFileViewUrl(AppwriteDB.labResultsBucket, fileId);
              AppToast.show(context, 'Opening: $url', type: ToastType.info);
            },
          ),
        ],
      ),
    );
  }
}
