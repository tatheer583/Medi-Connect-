import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';

class DoctorSearchScreen extends StatelessWidget {
  const DoctorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                final doctors = [
                  {'name': 'Dr. Ahmed Raza', 'specialty': 'Cardiologist', 'fee': '2000', 'rating': '4.9'},
                  {'name': 'Dr. Sarah Khan', 'specialty': 'Pediatrician', 'fee': '1500', 'rating': '4.8'},
                  {'name': 'Dr. Usman Ali', 'specialty': 'Dermatologist', 'fee': '1800', 'rating': '4.7'},
                  {'name': 'Dr. Maria Zain', 'specialty': 'General Physician', 'fee': '1000', 'rating': '4.9'},
                ];
                final doctor = doctors[index];
                return _buildDoctorCard(context, doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, String> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, size: 30, color: Colors.blue),
        ),
        title: Text(doctor['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor['specialty']!),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(doctor['rating']!),
                const SizedBox(width: 12),
                const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('PKR ${doctor['fee']}'),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () {
            context.pushNamed(AppRoute.booking.name, extra: doctor);
          },
          child: const Text('Book'),
        ),
      ),
    );
  }
}
