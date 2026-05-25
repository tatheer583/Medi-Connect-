import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, String> doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;

  final List<String> _slots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDoctorInfo(),
            const SizedBox(height: 32),
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 32),
            const Text(
              'Available Time Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSlotsGrid(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _selectedSlot == null ? null : () => _confirmBooking(),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.person, size: 40, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doctor['name']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.doctor['specialty']!,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        title: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
        trailing: const Icon(Icons.calendar_today, color: Colors.blue),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        },
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _slots.length,
      itemBuilder: (context, index) {
        final slot = _slots[index];
        final isSelected = _selectedSlot == slot;
        return InkWell(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed'),
        content: Text(
          'Your appointment with ${widget.doctor['name']} is scheduled for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at $_selectedSlot.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Back to Search
              context.pop(); // Back to Dashboard
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}
