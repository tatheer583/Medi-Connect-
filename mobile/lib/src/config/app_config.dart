/// Central app configuration.
///
/// Provides compile-time keys via `--dart-define` with safe defaults so the
/// app boots even when keys are not supplied.
///
/// Usage:
///   flutter run --dart-define=OPENAI_API_KEY=sk-...
///   flutter build web --release --dart-define=OPENAI_API_KEY=sk-...
class AppConfig {
  const AppConfig._();

  /// OpenAI API key for the AI pre-appointment summaries.
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  /// Default timezone used for scheduling reminders.
  static const String defaultTimezone = 'Asia/Karachi';
}
