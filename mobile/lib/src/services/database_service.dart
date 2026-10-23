// ignore_for_file: deprecated_member_use
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:mediconnect_mobile/src/config/appwrite_client.dart';

/// Appwrite database IDs — single source of truth, mirrors setup_appwrite.ps1
class AppwriteDB {
  static const String databaseId = AppwriteConfig.databaseId;

  // Collection IDs
  static const String appointments = 'appointments';
  static const String prescriptions = 'prescriptions';
  static const String medicines = 'medicines';
  static const String medicineReminders = 'medicine_reminders';
  static const String chatMessages = 'chat_messages';
  static const String labResults = 'lab_results';
  static const String doctors = 'doctors';
  static const String userProfiles = 'user_profiles';
  static const String users = 'users';

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

  /// Dates are stored in ISO format (yyyy-MM-dd) so Appwrite ordering is
  /// chronological; format for display right before rendering.
  static String todayIso() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

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

  /// Doctor-side view with graceful fallbacks (doctors row → user id → name).
  Future<List<models.Document>> getDoctorSchedule(String userId, String? name) async {
    final results = <String, models.Document>{};

    // 1) doctors collection row linked to this account (userId attribute)
    String? doctorRowId;
    try {
      final rows = await _db.listDocuments(
        databaseId: AppwriteDB.databaseId,
        collectionId: AppwriteDB.doctors,
        queries: [Query.equal('userId', userId)],
      );
      if (rows.documents.isNotEmpty) {
        doctorRowId = rows.documents.first.$id;
        for (final doc
            in await getDoctorAppointments(doctorRowId)) {
          results[doc.$id] = doc;
        }
      }
    } catch (_) {}

    // 2) appointments booked against the doctor's user id
    try {
      for (final doc in await getDoctorAppointments(userId)) {
        results[doc.$id] = doc;
      }
    } catch (_) {}

    // 3) appointments matched by the doctor's display name
    if (name != null && name.isNotEmpty) {
      try {
        final result = await _db.listDocuments(
          databaseId: AppwriteDB.databaseId,
          collectionId: AppwriteDB.appointments,
          queries: [
            Query.equal('doctorName', name),
            Query.orderDesc('date'),
          ],
        );
        for (final doc in result.documents) {
          results[doc.$id] = doc;
        }
      } catch (_) {}
    }

    return results.values.toList();
  }

  /// Live booked-slot lookup for the booking screen.
  Future<List<String>> getBookedSlots({
    required String doctorId,
    required String date,
  }) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.appointments,
      queries: [
        Query.equal('doctorId', doctorId),
        Query.equal('date', date),
        Query.equal('status', 'pending'),
        Query.limit(100),
      ],
    );
    return result.documents
        .map((d) => d.data['timeSlot']?.toString() ?? '')
        .toList();
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

  /// Creates/updates the doctor row linked to the signed-in account.
  Future<void> upsertDoctor(String userId, String name, String specialty,
      {required String fee}) async {
    try {
      final rows = await _db.listDocuments(
        databaseId: AppwriteDB.databaseId,
        collectionId: AppwriteDB.doctors,
        queries: [Query.equal('userId', userId)],
      );
      if (rows.documents.isNotEmpty) {
        await _db.updateDocument(
          databaseId: AppwriteDB.databaseId,
          collectionId: AppwriteDB.doctors,
          documentId: rows.documents.first.$id,
          data: {'name': name, 'specialty': specialty, 'fee': fee},
        );
        return;
      }
    } catch (_) {}
    await _db.createDocument(
      databaseId: AppwriteDB.databaseId,
      collectionId: AppwriteDB.doctors,
      documentId: ID.unique(),
      data: {
        'name': name,
        'specialty': specialty,
        'fee': fee,
        'rating': '4.8',
        'userId': userId,
        'available': true,
      },
    );
  }

  // ─── Prescriptions ────────────────────────────────────────────────────────

  /// Registers store medicines as a JSON-encoded string in the `medicines`
  /// attribute (a string column is safe regardless of array-attr support).
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
        'medicines':
            jsonEncode(medicines.map((m) => m).toList(growable: false)),
        'instructions': instructions,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Parses the medicines JSON column into a typed list.
  static List<Map<String, String>> decodeMedicines(dynamic raw) {
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw.toString()) as List)
          .map((e) => (e as Map).map(
                (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
              ))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
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

  /// Derives real conversations for the chat list from message history.
  /// Names are resolved via the `users` collection (userId → fullName).
  Future<List<Map<String, String>>> getConversations(String userId) async {
    final counterpart = <String, Map<String, String>>{};
    for (final field in const ['senderId', 'receiverId']) {
      try {
        final result = await _db.listDocuments(
          databaseId: AppwriteDB.databaseId,
          collectionId: AppwriteDB.chatMessages,
          queries: [Query.equal(field, userId), Query.limit(100)],
        );
        for (final doc in result.documents) {
          final data = doc.data;
          final senderId = data['senderId']?.toString() ?? '';
          final receiverId = data['receiverId']?.toString() ?? '';
          final otherId = senderId == userId ? receiverId : senderId;
          if (otherId.isEmpty || otherId == userId) continue;
          counterpart.putIfAbsent(otherId, () => {'id': otherId, 'name': 'User'});
        }
      } catch (_) {}
    }

    if (counterpart.isNotEmpty) {
      try {
        final ids = counterpart.keys.toList();
        final users = await _db.listDocuments(
          databaseId: AppwriteDB.databaseId,
          collectionId: AppwriteDB.users,
          queries: [Query.equal('userId', ids)],
        );
        for (final u in users.documents) {
          final id = u.data['userId']?.toString() ?? '';
          final name = u.data['fullName']?.toString() ?? 'User';
          if (counterpart.containsKey(id)) {
            counterpart[id] = {'id': id, 'name': name};
          }
        }
      } catch (_) {}
    }
    return counterpart.values.toList();
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
        'fileUrl': AppwriteConfig.fileViewUrl(
            AppwriteDB.labResultsBucket, fileId),
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
    return AppwriteConfig.fileViewUrl(bucketId, fileId);
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
