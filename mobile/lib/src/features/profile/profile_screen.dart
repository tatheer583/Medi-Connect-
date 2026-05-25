import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/features/profile/health_card_screen.dart';
import 'package:mediconnect_mobile/src/features/clinics/clinic_setup_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authServiceProvider);
    final isDoctor = userState.role == UserRole.doctor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Fatima Bibi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text('fatima.bibi@email.com'),
          ),
          const SizedBox(height: 32),
          if (!isDoctor)
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Colors.blue),
              title: const Text('Digital Health Card'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthCardScreen()),
              ),
            ),
          if (isDoctor)
            ListTile(
              leading: const Icon(Icons.store_outlined, color: Colors.blue),
              title: const Text('Clinic Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClinicSetupScreen()),
              ),
            ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined, color: Colors.blue),
            title: Text('Reminders & Alerts'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.language_outlined, color: Colors.blue),
            title: Text('Language (English / Urdu)'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.help_outline, color: Colors.blue),
            title: Text('Support'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authServiceProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
