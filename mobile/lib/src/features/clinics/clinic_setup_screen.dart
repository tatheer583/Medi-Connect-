import 'package:flutter/material.dart';

class ClinicSetupScreen extends StatefulWidget {
  const ClinicSetupScreen({super.key});

  @override
  State<ClinicSetupScreen> createState() => _ClinicSetupScreenState();
}

class _ClinicSetupScreenState extends State<ClinicSetupScreen> {
  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _feeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Manage your clinic details and consultation settings.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _clinicNameController,
              decoration: const InputDecoration(
                labelText: 'Clinic Name',
                prefixIcon: Icon(Icons.store_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feeController,
              decoration: const InputDecoration(
                labelText: 'Consultation Fee (PKR)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            const Text(
              'Working Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDayToggle('Monday', true),
            _buildDayToggle('Tuesday', true),
            _buildDayToggle('Wednesday', true),
            _buildDayToggle('Thursday', true),
            _buildDayToggle('Friday', true),
            _buildDayToggle('Saturday', false),
            _buildDayToggle('Sunday', false),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayToggle(String day, bool enabled) {
    return Row(
      children: [
        Checkbox(value: enabled, onChanged: (v) {}),
        Expanded(child: Text(day)),
        if (enabled)
          const Text('09:00 AM - 05:00 PM', style: TextStyle(color: Colors.blue)),
      ],
    );
  }
}
