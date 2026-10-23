import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';

/// Fallback doctors used only while the `doctors` collection is empty —
/// keeps the booking flow demonstrable before real data is seeded.
const List<Map<String, String>> _demoDoctors = [
  {'id': 'demo-dr-ahmed', 'name': 'Dr. Ahmed Raza', 'specialty': 'Cardiologist', 'fee': '2000', 'rating': '4.9'},
  {'id': 'demo-dr-sarah', 'name': 'Dr. Sarah Khan', 'specialty': 'Pediatrician', 'fee': '1500', 'rating': '4.8'},
  {'id': 'demo-dr-usman', 'name': 'Dr. Usman Ali', 'specialty': 'Dermatologist', 'fee': '1800', 'rating': '4.7'},
  {'id': 'demo-dr-maria', 'name': 'Dr. Maria Zain', 'specialty': 'General Physician', 'fee': '1000', 'rating': '4.9'},
];

class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  List<Map<String, String>> _doctors = [];
  bool _loading = true;
  bool _usingDemoData = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    try {
      final List<models.Document> docs = _query.isEmpty
          ? await DatabaseService().getAllDoctors()
          : await DatabaseService().searchDoctors(query: _query);
      if (!mounted) return;
      setState(() {
        _doctors = docs
            .map((d) => {
                  'id': d.$id,
                  'name': (d.data['name'] ?? 'Doctor').toString(),
                  'specialty': (d.data['specialty'] ?? 'General Physician').toString(),
                  'fee': (d.data['fee'] ?? '1000').toString(),
                  'rating': (d.data['rating'] ?? '4.5').toString(),
                })
            .toList();
        _usingDemoData = _doctors.isEmpty;
        if (_usingDemoData) {
          _doctors = _demoDoctors
              .where((d) =>
                  _query.isEmpty ||
                  d['name']!.toLowerCase().contains(_query.toLowerCase()) ||
                  d['specialty']!.toLowerCase().contains(_query.toLowerCase()))
              .toList();
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Collection missing or offline → show demo data so the flow works.
      setState(() {
        _doctors = _demoDoctors
            .where((d) =>
                _query.isEmpty ||
                d['name']!.toLowerCase().contains(_query.toLowerCase()) ||
                d['specialty']!.toLowerCase().contains(_query.toLowerCase()))
            .toList();
        _usingDemoData = true;
        _loading = false;
      });
    }
  }

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
              onChanged: (value) => _query = value,
              onSubmitted: (_) => _loadDoctors(),
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_usingDemoData)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Demo doctors shown — seed the "doctors" collection in Appwrite to list real doctors.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: [ShimmerCard(), ShimmerCard(), ShimmerCard()]),
                  )
                : _doctors.isEmpty
                    ? EmptyState(
                        icon: Icons.person_search_rounded,
                        title: 'No Doctors Found',
                        subtitle: 'Try a different name or specialty',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDoctors,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
                            return _buildDoctorCard(context, doctor);
                          },
                        ),
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
