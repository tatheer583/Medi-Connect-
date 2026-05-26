import 'package:flutter/material.dart';

class ClinicSetupScreen extends StatefulWidget {
  const ClinicSetupScreen({super.key});

  @override
  State<ClinicSetupScreen> createState() => _ClinicSetupScreenState();
}

class _ClinicSetupScreenState extends State<ClinicSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameCtrl = TextEditingController(text: 'MediConnect Clinic');
  final _addressCtrl = TextEditingController(text: 'Phase 5, DHA, Lahore');
  final _phoneCtrl = TextEditingController(text: '+92 300 1234567');
  final _licenseCtrl = TextEditingController(text: 'PMDC-12345');
  final _feeCtrl = TextEditingController(text: '2000');

  bool _isSaving = false;
  bool _saved = false;

  // Working hours
  final Map<String, Map<String, dynamic>> _workingHours = {
    'Monday': {'open': true, 'start': '09:00 AM', 'end': '05:00 PM'},
    'Tuesday': {'open': true, 'start': '09:00 AM', 'end': '05:00 PM'},
    'Wednesday': {'open': true, 'start': '09:00 AM', 'end': '05:00 PM'},
    'Thursday': {'open': true, 'start': '09:00 AM', 'end': '05:00 PM'},
    'Friday': {'open': true, 'start': '09:00 AM', 'end': '01:00 PM'},
    'Saturday': {'open': false, 'start': '10:00 AM', 'end': '02:00 PM'},
    'Sunday': {'open': false, 'start': '10:00 AM', 'end': '02:00 PM'},
  };

  final List<String> _selectedSpecialties = ['General Medicine', 'Cardiology'];
  final List<String> _allSpecialties = [
    'General Medicine', 'Cardiology', 'Pediatrics', 'Dermatology',
    'Orthopedics', 'Gynecology', 'Neurology', 'ENT', 'Ophthalmology',
    'Psychiatry', 'Urology', 'Oncology',
  ];

  @override
  void dispose() {
    _clinicNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate save
    if (mounted) {
      setState(() {
        _isSaving = false;
        _saved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinic settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic / Practice Settings'),
        actions: [
          if (_saved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            _buildSectionHeader('Basic Information', Icons.info_outline),
            const SizedBox(height: 12),
            _buildField(_clinicNameCtrl, 'Clinic / Practice Name', Icons.business, required: true),
            const SizedBox(height: 12),
            _buildField(_addressCtrl, 'Address', Icons.location_on_outlined, required: true),
            const SizedBox(height: 12),
            _buildField(_phoneCtrl, 'Contact Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 12),
            _buildField(_licenseCtrl, 'PMDC / License Number', Icons.badge_outlined, required: true),
            const SizedBox(height: 12),
            _buildField(_feeCtrl, 'Consultation Fee (PKR)', Icons.payments_outlined,
                keyboardType: TextInputType.number, required: true),

            const SizedBox(height: 24),

            // Specialties
            _buildSectionHeader('Specialties Offered', Icons.medical_services_outlined),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSpecialties.map((spec) {
                final selected = _selectedSpecialties.contains(spec);
                return FilterChip(
                  label: Text(spec),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSpecialties.add(spec);
                      } else {
                        _selectedSpecialties.remove(spec);
                      }
                    });
                  },
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Working Hours
            _buildSectionHeader('Working Hours', Icons.access_time_outlined),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: _workingHours.entries.map((entry) {
                  final day = entry.key;
                  final hours = entry.value;
                  return SwitchListTile(
                    title: Text(day),
                    subtitle: hours['open'] as bool
                        ? Text('${hours['start']} – ${hours['end']}',
                            style: const TextStyle(fontSize: 12))
                        : const Text('Closed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: hours['open'] as bool,
                    onChanged: (val) {
                      setState(() => _workingHours[day]!['open'] = val);
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
    );
  }
}
