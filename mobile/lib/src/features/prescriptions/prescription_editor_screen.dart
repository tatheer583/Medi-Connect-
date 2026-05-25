import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrescriptionEditorScreen extends StatefulWidget {
  final String patientName;
  const PrescriptionEditorScreen({super.key, required this.patientName});

  @override
  State<PrescriptionEditorScreen> createState() => _PrescriptionEditorScreenState();
}

class _PrescriptionEditorScreenState extends State<PrescriptionEditorScreen> {
  final _diagnosisController = TextEditingController();
  final List<Map<String, String>> _medicines = [];

  void _addMedicine() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final dosageController = TextEditingController();
        final frequencyController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Medicine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Medicine Name')),
              TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'Dosage (e.g. 500mg)')),
              TextField(controller: frequencyController, decoration: const InputDecoration(labelText: 'Frequency (e.g. 1-0-1)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _medicines.add({
                    'name': nameController.text,
                    'dosage': dosageController.text,
                    'frequency': frequencyController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription: ${widget.patientName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Diagnosis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _diagnosisController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter diagnosis details...',
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Medicines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _addMedicine, icon: const Icon(Icons.add_circle, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            if (_medicines.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No medicines added yet.', style: TextStyle(color: Colors.grey)),
              ))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final med = _medicines[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(med['name']!),
                      subtitle: Text('${med['dosage']} | ${med['frequency']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _medicines.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            const Text('Instructions / Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save to database
                  context.pop();
                },
                child: const Text('Finish & Issue Prescription'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
