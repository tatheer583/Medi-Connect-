import 'dart:async';

import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/medical_constants.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';

/// The real doctor directory, backed by the Appwrite `doctors` collection.
/// Every listed doctor either registered through the app or was seeded by
/// an administrator — there is no demo data.
class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  List<Map<String, String>> _doctors = [];
  bool _loading = true;
  String _query = '';
  String? _specialtyFilter;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Live search: fires 450 ms after the user stops typing.
  void _onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _loadDoctors);
  }

  Future<List<models.Document>> _fetchFromServer() async {
    if (_specialtyFilter == null && _query.isEmpty) {
      return DatabaseService().getAllDoctors();
    }
    return DatabaseService().searchDoctors(
      query: _specialtyFilter == null ? _query : null,
      specialty: _specialtyFilter,
    );
  }

  /// Server-side text search (`Query.search`) requires a fulltext index on
  /// `doctors.name`. When that index is absent (or offline) we fall back to
  /// fetching the directory and filtering locally, so search always works.
  Future<List<models.Document>> _fetchWithLocalFallback() async {
    try {
      return await _fetchFromServer();
    } catch (_) {
      final all = await DatabaseService().getAllDoctors();
      final q = _query.toLowerCase();
      return all.where((d) {
        final name = (d.data['name'] ?? '').toString().toLowerCase();
        final specialty = (d.data['specialty'] ?? '').toString().toLowerCase();
        final matchesQuery =
            q.isEmpty || name.contains(q) || specialty.contains(q);
        final matchesSpecialty = _specialtyFilter == null ||
            specialty == _specialtyFilter!.toLowerCase();
        return matchesQuery && matchesSpecialty;
      }).toList();
    }
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    try {
      final docs = await _fetchWithLocalFallback();
      if (!mounted) return;
      setState(() {
        _doctors = docs
            .map((d) => {
                  'id': d.$id,
                  'name': (d.data['name'] ?? 'Doctor').toString(),
                  'specialty':
                      (d.data['specialty'] ?? 'General Physician').toString(),
                  'fee': (d.data['fee'] ?? '1000').toString(),
                  'rating': (d.data['rating'] ?? '').toString(),
                  'available': (d.data['available'] ?? true).toString(),
                })
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _doctors = [];
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
              onChanged: _onQueryChanged,
              onSubmitted: (_) => _loadDoctors(),
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded),
                        onPressed: _loadDoctors,
                      )
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _onQueryChanged('');
                          _loadDoctors();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _specialtyFilter == null,
                    onSelected: (_) {
                      setState(() => _specialtyFilter = null);
                      _loadDoctors();
                    },
                  ),
                ),
                for (final s in MedicalConstants.doctorSpecialties)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: _specialtyFilter == s,
                      onSelected: (_) {
                        setState(() => _specialtyFilter = s);
                        _loadDoctors();
                      },
                    ),
                  ),
              ],
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
                        subtitle: _query.isNotEmpty || _specialtyFilter != null
                            ? 'Try a different name or specialty'
                            : 'Doctors appear here automatically when they '
                                'register with MediConnect',
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
    final isAvailable = doctor['available'] != 'false';
    final unrated = MedicalConstants.isUnrated(doctor['rating']);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, size: 30, color: Colors.blue),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(doctor['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (!isAvailable) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Unavailable',
                    style: TextStyle(fontSize: 10, color: Colors.black54)),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor['specialty']!),
            const SizedBox(height: 4),
            Row(
              children: [
                if (unrated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('New',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700)),
                  )
                else ...[
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(doctor['rating']!),
                ],
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
          onPressed: isAvailable
              ? () {
                  context.pushNamed(AppRoute.booking.name, extra: doctor);
                }
              : null,
          child: const Text('Book'),
        ),
      ),
    );
  }
}
