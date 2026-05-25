import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/features/profile/profile_screen.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';
import 'package:mediconnect_mobile/src/features/chat/chat_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authServiceProvider);
    final isDoctor = userState.role == UserRole.doctor;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDoctor ? 'Doctor Dashboard' : 'Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Toggle Role (Dev Only)',
            onPressed: () => ref.read(authServiceProvider.notifier).toggleRole(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider.notifier).logout(),
          ),
        ],
      ),
      body: _buildBody(userState.role),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: isDoctor ? _doctorNavItems() : _patientNavItems(),
      ),
      floatingActionButton: !isDoctor && _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed(AppRoute.doctorSearch.name);
              },
              label: const Text('Book Appointment'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(UserRole role) {
    if (_selectedIndex == 1) return const ChatListScreen();
    if (_selectedIndex == 2) return const ProfileScreen();
    
    if (role == UserRole.doctor) {
      return _DoctorDashboardBody(index: _selectedIndex);
    } else {
      return _PatientDashboardBody(index: _selectedIndex);
    }
  }

  List<BottomNavigationBarItem> _patientNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  List<BottomNavigationBarItem> _doctorNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
    ];
  }
}

class _PatientDashboardBody extends StatelessWidget {
  final int index;
  const _PatientDashboardBody({required this.index});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthCardSummary(),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          const Text(
            'Upcoming Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildAppointmentCard(
            context,
            doctorName: 'Dr. Ahmed Raza',
            specialty: 'Cardiologist',
            date: 'Tomorrow, 10:30 AM',
            status: 'Confirmed',
          ),
          const SizedBox(height: 24),
          const Text(
            'Medicine Reminders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMedicineCard(
            name: 'Metformin',
            dosage: '500mg',
            time: '08:00 AM',
            taken: true,
          ),
          _buildMedicineCard(
            name: 'Lisinopril',
            dosage: '10mg',
            time: '09:00 PM',
            taken: false,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCardSummary() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Fatima Bibi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Blood Group: B+ | Age: 42'),
                  Text('Next Checkup: May 20, 2026'),
                ],
              ),
            ),
            const Icon(Icons.qr_code, size: 40, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(context, Icons.file_copy_outlined, 'Lab Reports', () {
          context.pushNamed(AppRoute.labResults.name);
        }),
        _buildActionItem(context, Icons.medication_outlined, 'Prescriptions', () {
          context.pushNamed(AppRoute.prescriptionView.name);
        }),
        _buildActionItem(context, Icons.history_outlined, 'History', () {}),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context, {
    required String doctorName,
    required String specialty,
    required String date,
    required String status,
  }) {
    return Card(
      child: ListTile(
        onTap: () => context.pushNamed(AppRoute.prescriptionView.name),
        leading: const CircleAvatar(child: Icon(Icons.medical_services)),
        title: Text(doctorName),
        subtitle: Text('$specialty • $date'),
        trailing: Chip(
          label: Text(status),
          backgroundColor: Colors.green.shade50,
          labelStyle: const TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildMedicineCard({
    required String name,
    required String dosage,
    required String time,
    required bool taken,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          taken ? Icons.check_circle : Icons.radio_button_unchecked,
          color: taken ? Colors.green : Colors.grey,
        ),
        title: Text(name),
        subtitle: Text('$dosage • $time'),
      ),
    );
  }
}

class _DoctorDashboardBody extends StatelessWidget {
  final int index;
  const _DoctorDashboardBody({required this.index});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, i) {
        if (i == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "Today's Appointments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }
        return _buildPatientQueueItem(
          context,
          patientName: 'Patient $i',
          time: '09:${i}0 AM',
          type: i % 2 == 0 ? 'Follow-up' : 'First Visit',
        );
      },
    );
  }

  Widget _buildPatientQueueItem(
    BuildContext context, {
    required String patientName,
    required String time,
    required String type,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(patientName),
              subtitle: Text(time),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                ),
                onPressed: () {
                  context.pushNamed(AppRoute.prescriptionEditor.name, extra: patientName);
                },
                child: const Text('Start'),
              ),
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AI Brief: Patient missed 2 doses of Metformin. BP was high last visit.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
