import 'package:flutter/material.dart';

class HealthCardScreen extends StatelessWidget {
  const HealthCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Health Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 150, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Fatima Bibi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ID: MC-2026-4482',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              title: 'Personal Information',
              items: [
                _buildInfoRow('CNIC', '42101-XXXXXXX-X'),
                _buildInfoRow('Blood Group', 'B+'),
                _buildInfoRow('Age', '42 Years'),
                _buildInfoRow('Weight', '68 kg'),
                _buildInfoRow('Height', '5\'4"'),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Medical Conditions',
              items: [
                _buildChipRow('Chronic', ['Hypertension', 'Diabetes Type 2']),
                _buildChipRow('Allergies', ['Penicillin', 'Dust']),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Emergency Contact',
              items: [
                _buildInfoRow('Name', 'Ali Ahmed (Husband)'),
                _buildInfoRow('Phone', '+92 300 1234567'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: tags.map((tag) => Chip(
            label: Text(tag, style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.red.shade50,
            labelStyle: const TextStyle(color: Colors.red),
            side: BorderSide.none,
          )).toList(),
        ),
      ],
    );
  }
}
