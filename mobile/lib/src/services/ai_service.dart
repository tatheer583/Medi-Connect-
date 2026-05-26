import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // API key should be provided at runtime from environment or secure storage
  static String _apiKey = '';
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  /// Initialize the AI service with API key
  static void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  /// Generate a pre-appointment patient summary for the doctor
  Future<String> generatePatientSummary({
    required String patientName,
    required List<String> pastAppointments,
    required List<String> currentMedicines,
    required List<String> labResults,
  }) async {
    final prompt = '''
You are a medical AI assistant. Generate a concise pre-appointment summary for a doctor.

Patient: $patientName

Past Appointments:
${pastAppointments.isEmpty ? 'No previous appointments' : pastAppointments.map((a) => '- $a').join('\n')}

Current Medications:
${currentMedicines.isEmpty ? 'None' : currentMedicines.map((m) => '- $m').join('\n')}

Recent Lab Results:
${labResults.isEmpty ? 'None available' : labResults.map((l) => '- $l').join('\n')}

Write a 3-4 sentence clinical summary highlighting key health concerns, medication adherence, and what the doctor should focus on in this appointment. Be concise and professional.
''';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 300,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional medical AI assistant that helps doctors prepare for patient appointments.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      return 'Unable to generate AI summary at this time. Please review the patient\'s history manually.';
    }
  }
}
