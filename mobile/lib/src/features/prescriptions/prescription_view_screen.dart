import 'package:flutter/material.dart';

class PrescriptionViewScreen extends StatelessWidget {
  const PrescriptionViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 40),
            const Text('Diagnosis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Hypertension and Early Stage Type 2 Diabetes management.'),
            const SizedBox(height: 32),
            const Text('Medicines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMedicineItem('Metformin 500mg', '1-0-1 (After meals)', '30 Days'),
            _buildMedicineItem('Lisinopril 10mg', '0-0-1 (Before bed)', 'Ongoing'),
            _buildMedicineItem('Panadol 500mg', 'As needed for headache', '5 Days'),
            const SizedBox(height: 32),
            const Text('Lab Tests Ordered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• Fasting Blood Sugar (FBS)\n• HbA1c\n• Lipid Profile'),
            const SizedBox(height: 32),
            const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Reduce salt intake. Walk for 30 minutes daily. Monitor BP twice a day.'),
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  const Text('Dr. Ahmed Raza', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('PMDC: 12345-P'),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    width: 150,
                    color: Colors.black,
                  ),
                  const Text('Digital Signature'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('MediConnect Clinic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text('Phase 5, DHA, Lahore'),
            Text('Date: 16 May, 2026'),
          ],
        ),
        const Icon(Icons.local_hospital, size: 50, color: Colors.blue),
      ],
    );
  }

  Widget _buildMedicineItem(String name, String instruction, String duration) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medication, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(instruction, style: const TextStyle(color: Colors.grey)),
                Text('Duration: $duration', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
