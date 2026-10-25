/// Shared medical domain constants used by registration, the doctor
/// directory, and the clinic setup screens so every surface lists the
/// exact same specialty vocabulary.
class MedicalConstants {
  const MedicalConstants._();

  /// Specialties a doctor can register under / patients can filter by.
  static const List<String> doctorSpecialties = [
    'General Physician',
    'Cardiologist',
    'Pediatrician',
    'Dermatologist',
    'Orthopedic Surgeon',
    'Gynecologist',
    'Neurologist',
    'ENT Specialist',
    'Ophthalmologist',
    'Psychiatrist',
    'Urologist',
    'Oncologist',
  ];

  /// Displayed when a doctor has not been rated yet.
  static const String unratedValue = '0.0';

  static bool isUnrated(String? rating) =>
      rating == null || rating.isEmpty || rating == unratedValue;
}
