// ignore_for_file: deprecated_member_use
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:mediconnect_mobile/src/config/appwrite_client.dart';

/// Appwrite database IDs — create these collections in your Appwrite console
class AppwriteDB {
  static const String databaseId = 'mediconnect_db';

  // Collection IDs
  static const String appointments = 'appointments';
  static const String prescriptions = 'prescriptions';
  static const String medicines = 'medicines';
  static const String medicineReminders = 'medicine_reminders';
  static const String chatMessages = 'chat_messages';
  static const String labResults = 'lab_results';
  static const String doctors = 'doctors';
  static const String userProfiles = 'user_profiles';

  // Storage bucket IDs
  static const String labResultsBucket = 'lab_results_files';
  static const String prescriptionsBucket = 'lab_results_files'; // shared bucket (free plan)
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final Databases _db = Databases(client);
  final Storage _storage = Storage(client);

  // ─── Appointments ─────────────────────────────────────────────────────────

  Future<models.Document> createAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String date,
    required String timeSlot,
    required String fee,
  }) async {
    return await _db.createDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.appointments,
      documentId: ID.unique(),
      data: {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialty': specialty,
        'date': date,
        'timeSlot': timeSlot,
        'fee': fee,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<models.Document>> getPatientAppointments(String patientId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.appointments,
      queries: [
        Query.equal('patientId', patientId),
        Query.orderDesc('createdAt'),
      ],
    );
    return result.documents;
  }

  Future<List<models.Document>> getDoctorAppointments(String doctorId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.appointments,
      queries: [
        Query.equal('doctorId', doctorId),
        Query.orderDesc('date'),
      ],
    );
    return result.documents;
  }

  Future<models.Document> updateAppointmentStatus(
      String appointmentId, String status) async {
    return await _db.updateDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.appointments,
      documentId: appointmentId,
      data: {'status': status},
    );
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _db.deleteDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.appointments,
      documentId: appointmentId,
    );
  }

  // ─── Doctors ──────────────────────────────────────────────────────────────

  Future<List<models.Document>> searchDoctors({String? query, String? specialty}) async {
    final queries = <String>[];
    if (specialty != null && specialty.isNotEmpty) {
      queries.add(Query.equal('specialty', specialty));
    }
    if (query != null && query.isNotEmpty) {
      queries.add(Query.search('name', query));
    }

    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.doctors,
      queries: queries,
    );
    return result.documents;
  }

  Future<List<models.Document>> getAllDoctors() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.doctors,
    );
    return result.documents;
  }

  // ─── Prescriptions ────────────────────────────────────────────────────────

  Future<models.Document> createPrescription({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String diagnosis,
    required List<Map<String, String>> medicines,
    required String instructions,
  }) async {
    return await _db.createDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.prescriptions,
      documentId: ID.unique(),
      data: {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': patientId,
        'patientName': patientName,
        'diagnosis': diagnosis,
        'medicines': medicines.map((m) => '${m['name']}|${m['dosage']}|${m['frequency']}|${m['duration']}').toList(),
        'instructions': instructions,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<models.Document>> getPatientPrescriptions(String patientId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.prescriptions,
      queries: [
        Query.equal('patientId', patientId),
        Query.orderDesc('createdAt'),
      ],
    );
    return result.documents;
  }

  // ─── Medicine Reminders ───────────────────────────────────────────────────

  Future<models.Document> createReminder({
    required String userId,
    required String medicineName,
    required String dosage,
    required String time,
    required bool active,
  }) async {
    return await _db.createDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.medicineReminders,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'medicineName': medicineName,
        'dosage': dosage,
        'time': time,
        'active': active,
        'takenToday': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<models.Document>> getUserReminders(String userId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.medicineReminders,
      queries: [Query.equal('userId', userId)],
    );
    return result.documents;
  }

  Future<models.Document> updateReminder(
      String reminderId, Map<String, dynamic> data) async {
    return await _db.updateDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.medicineReminders,
      documentId: reminderId,
      data: data,
    );
  }

  Future<void> deleteReminder(String reminderId) async {
    await _db.deleteDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.medicineReminders,
      documentId: reminderId,
    );
  }

  // ─── Chat Messages ────────────────────────────────────────────────────────

  Future<models.Document> sendMessage({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String text,
    required String chatId,
  }) async {
    return await _db.createDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.chatMessages,
      documentId: ID.unique(),
      data: {
        'senderId': senderId,
        'receiverId': receiverId,
        'senderName': senderName,
        'text': text,
        'chatId': chatId,
        'read': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<models.Document>> getChatMessages(String chatId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.chatMessages,
      queries: [
        Query.equal('chatId', chatId),
        Query.orderAsc('createdAt'),
        Query.limit(100),
      ],
    );
    return result.documents;
  }

  Future<void> markMessageRead(String messageId) async {
    await _db.updateDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.chatMessages,
      documentId: messageId,
      data: {'read': true},
    );
  }

  // ─── Lab Results ──────────────────────────────────────────────────────────

  Future<models.Document> createLabResult({
    required String patientId,
    required String testName,
    required String uploadedBy,
    required String fileId,
    required String fileType,
  }) async {
    return await _db.createDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.labResults,
      documentId: ID.unique(),
      data: {
        'patientId': patientId,
        'testName': testName,
        'uploadedBy': uploadedBy,
        'fileId': fileId,
        'fileType': fileType,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<models.Document>> getPatientLabResults(String patientId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.labResults,
      queries: [
        Query.equal('patientId', patientId),
        Query.orderDesc('uploadedAt'),
      ],
    );
    return result.documents;
  }

  // ─── File Storage ─────────────────────────────────────────────────────────

  Future<models.File> uploadFile({
    required String bucketId,
    required String filePath,
    required String fileName,
  }) async {
    return await _storage.createFile(
      bucketId: bucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: filePath, filename: fileName),
    );
  }

  String getFileViewUrl(String bucketId, String fileId) {
    return 'https://fra.cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=6a14834f003c65073c46';
  }

  // ─── Realtime ─────────────────────────────────────────────────────────────

  RealtimeSubscription subscribeToChatMessages(
      String chatId, void Function(RealtimeMessage) callback) {
    final realtime = Realtime(client);
    return realtime.subscribe([
      'databases.${AppwriteDB.databaseId}.collections.${AppwriteDB.chatMessages}.documents',
    ])
      ..stream.listen((event) {
        if (event.payload['chatId'] == chatId) {
          callback(event);
        }
      });
  }
}
