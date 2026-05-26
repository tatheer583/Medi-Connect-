import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/appwrite_service.dart';
import 'package:mediconnect_mobile/src/features/profile/health_card_screen.dart';
import 'package:mediconnect_mobile/src/features/clinics/clinic_setup_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _displayName = '';
  String _email = '';
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final appwrite = AppwriteService();
      appwrite.initialize();
      final user = await appwrite.getCurrentUser();
      if (mounted) {
        setState(() {
          _displayName = user.name.isNotEmpty ? user.name : 'User';
          _email = user.email;
          _loadingUser = false;
        });
      }
    } catch (_) {
      // Fall back to state values
      final userState = ref.read(authServiceProvider);
      if (mounted) {
        setState(() {
          _email = userState.email ?? '';
          _displayName = _email.isNotEmpty ? _email.split('@').first : 'User';
          _loadingUser = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authServiceProvider.notifier).logout();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authServiceProvider);
    final role = userState.role;
    final isDoctor = role == UserRole.doctor;
    final isClinic = role == UserRole.clinic;

    final roleLabel = role.name[0].toUpperCase() + role.name.substring(1);
    final roleIcon = isDoctor
        ? Icons.medical_services
        : isClinic
            ? Icons.business
            : Icons.person;
    final roleColor = isDoctor
        ? Colors.green
        : isClinic
            ? Colors.purple
            : Colors.blue;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            child: Icon(roleIcon, size: 45, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit, size: 14, color: roleColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _loadingUser
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _displayName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          roleLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Menu items
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Role-specific section
              _buildSection(
                title: 'My Account',
                children: [
                  if (!isDoctor && !isClinic)
                    _buildTile(
                      icon: Icons.badge_outlined,
                      iconColor: Colors.blue,
                      title: 'Digital Health Card',
                      subtitle: 'View your health summary & QR code',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HealthCardScreen()),
                      ),
                    ),
                  if (isDoctor || isClinic)
                    _buildTile(
                      icon: Icons.store_outlined,
                      iconColor: Colors.purple,
                      title: isClinic ? 'Clinic Settings' : 'Practice Settings',
                      subtitle: 'Manage your clinic information',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClinicSetupScreen()),
                      ),
                    ),
                  _buildTile(
                    icon: Icons.edit_outlined,
                    iconColor: Colors.teal,
                    title: 'Edit Profile',
                    subtitle: 'Update your name and details',
                    onTap: () => _showEditProfileSheet(context),
                  ),
                ],
              ),

              _buildSection(
                title: 'Preferences',
                children: [
                  _buildTile(
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.orange,
                    title: 'Reminders & Alerts',
                    subtitle: 'Manage medication and appointment alerts',
                    onTap: () => _showNotificationSettings(context),
                  ),
                  _buildTile(
                    icon: Icons.language_outlined,
                    iconColor: Colors.indigo,
                    title: 'Language',
                    subtitle: 'English / اردو',
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),

              _buildSection(
                title: 'Support',
                children: [
                  _buildTile(
                    icon: Icons.help_outline,
                    iconColor: Colors.green,
                    title: 'Help & Support',
                    subtitle: 'FAQs and contact us',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.grey,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: 'App Version',
                    subtitle: 'v1.0.0',
                    onTap: null,
                  ),
                ],
              ),

              // Logout
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Color iconColor = Colors.blue,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
      onTap: onTap,
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: _displayName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _displayName = nameCtrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _NotificationSettingsSheet(),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: Colors.blue),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Text('🇵🇰', style: TextStyle(fontSize: 24)),
              title: const Text('اردو (Urdu)'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  bool _medicationReminders = true;
  bool _appointmentAlerts = true;
  bool _labResultsReady = false;
  bool _doctorMessages = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reminders & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Medication Reminders'),
            subtitle: const Text('Daily medicine alerts'),
            value: _medicationReminders,
            onChanged: (v) => setState(() => _medicationReminders = v),
          ),
          SwitchListTile(
            title: const Text('Appointment Alerts'),
            subtitle: const Text('Upcoming appointment notifications'),
            value: _appointmentAlerts,
            onChanged: (v) => setState(() => _appointmentAlerts = v),
          ),
          SwitchListTile(
            title: const Text('Lab Results Ready'),
            subtitle: const Text('Notify when reports are uploaded'),
            value: _labResultsReady,
            onChanged: (v) => setState(() => _labResultsReady = v),
          ),
          SwitchListTile(
            title: const Text('Doctor Messages'),
            subtitle: const Text('New message notifications'),
            value: _doctorMessages,
            onChanged: (v) => setState(() => _doctorMessages = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
