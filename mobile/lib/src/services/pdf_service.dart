import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  Future<File> generatePrescriptionPdf({
    required String doctorName,
    required String doctorLicense,
    required String patientName,
    required String diagnosis,
    required List<Map<String, String>> medicines,
    required String instructions,
    required String date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#1A73E8'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MediConnect Smart',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Digital Prescription',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      date,
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Doctor & Patient info
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#E9ECEF')),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Doctor',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromHex('#6B7280'))),
                          pw.Text(doctorName,
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('PMDC: $doctorLicense',
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#E9ECEF')),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Patient',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromHex('#6B7280'))),
                          pw.Text(patientName,
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Diagnosis
              pw.Text('Diagnosis',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1A73E8'))),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(diagnosis, style: const pw.TextStyle(fontSize: 12)),
              ),

              pw.SizedBox(height: 20),

              // Medicines
              pw.Text('Prescribed Medicines',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1A73E8'))),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E9ECEF'), width: 0.5),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#1A73E8')),
                    children: ['Medicine', 'Dosage', 'Frequency', 'Duration']
                        .map((h) => pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(h,
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 11)),
                            ))
                        .toList(),
                  ),
                  // Medicine rows
                  ...medicines.map((med) => pw.TableRow(
                        children: [
                          med['name'] ?? '',
                          med['dosage'] ?? '',
                          med['frequency'] ?? '',
                          med['duration'] ?? '',
                        ]
                            .map((cell) => pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(cell,
                                      style:
                                          const pw.TextStyle(fontSize: 11)),
                                ))
                            .toList(),
                      )),
                ],
              ),

              pw.SizedBox(height: 20),

              // Instructions
              if (instructions.isNotEmpty) ...[
                pw.Text('Instructions',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1A73E8'))),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(instructions,
                      style: const pw.TextStyle(fontSize: 12)),
                ),
                pw.SizedBox(height: 20),
              ],

              // Signature
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 30),
                      pw.Container(
                          width: 120, height: 1, color: PdfColors.black),
                      pw.Text(doctorName,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Digital Signature',
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromHex('#6B7280'))),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save to temp directory
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Open PDF preview/share dialog
  Future<void> printOrShare(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
}
