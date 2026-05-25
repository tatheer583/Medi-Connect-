import 'package:flutter/material.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  final List<Map<String, String>> _reports = [
    {'name': 'Complete Blood Count (CBC)', 'date': '12 May, 2026', 'type': 'PDF'},
    {'name': 'Lipid Profile', 'date': '10 April, 2026', 'type': 'PDF'},
    {'name': 'X-Ray Chest', 'date': '01 March, 2026', 'type': 'Image'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Reports'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                report['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                color: Colors.red.shade400,
                size: 30,
              ),
              title: Text(report['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Uploaded on: ${report['date']}'),
              trailing: const Icon(Icons.open_in_new, color: Colors.blue),
              onTap: () {
                // TODO: Open file viewer
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUploadSourceSelector();
        },
        label: const Text('Upload Report'),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }

  void _showUploadSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text('Upload PDF Document'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
