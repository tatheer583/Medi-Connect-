import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';

class HealthCardScreen extends ConsumerWidget {
  const HealthCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider);
    final name = (user.name?.isNotEmpty ?? false)
        ? user.name!
        : (user.email?.split('@').first ?? 'Patient');

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
                  const Icon(Icons.badge_rounded, size: 110, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email ?? '—',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    'Member ID: MC-${user.userId?.substring(0, 8) ?? "00000000"}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Health details below are examples — enter real values '
                    'clinically confirmed by your doctor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              title: 'Personal Information',
              items: [
                _buildInfoRow('Blood Group', '—'),
                _buildInfoRow('Age', '—'),
                _buildInfoRow('Weight', '—'),
                _buildInfoRow('Height', '—'),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Medical Conditions',
              items: [
                _buildChipRow('Chronic', ['None recorded']),
                _buildChipRow('Allergies', ['None recorded']),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Emergency Contact',
              items: [
                _buildInfoRow('Name', '—'),
                _buildInfoRow('Phone', '—'),
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
