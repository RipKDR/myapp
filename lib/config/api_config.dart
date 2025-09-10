/// API Configuration for NDIS Connect
///
/// IMPORTANT: Do not commit real API keys to source control.
/// Keys are sourced from `--dart-define` or environment at build time.
/// Example (Flutter):
///   flutter run --dart-define=GOOGLE_MAPS_API_KEY=... --dart-define=GEMINI_API_KEY=...
class ApiConfig {
  // Google Maps API Key (from environment)
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  // Gemini API Key for AI features (from environment)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );

  // Gemini API Configuration
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-1.5-flash';

  // API Endpoints
  static const String geminiGenerateContentEndpoint =
      '$geminiApiUrl/models/$geminiModel:generateContent';

  // Request Configuration (built on demand to avoid emitting empty keys)
  static Map<String, String> geminiHeaders({final Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (geminiApiKey.isNotEmpty) {
      headers['x-goog-api-key'] = geminiApiKey;
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  // Feature Flags for API Usage (overridable via --dart-define)
  static const bool enableGeminiAI = bool.fromEnvironment(
    'ENABLE_GEMINI_AI',
    defaultValue: true,
  );
  static const bool enableMapsFeatures = bool.fromEnvironment(
    'ENABLE_MAPS_FEATURES',
    defaultValue: true,
  );

  /// Get Gemini API key for HTTP requests
  static String getGeminiApiKey() => geminiApiKey;

  /// Get Google Maps API key
  static String getGoogleMapsApiKey() => googleMapsApiKey;

  /// Check if AI features are enabled
  static bool isAIEnabled() => enableGeminiAI && geminiApiKey.isNotEmpty;

  /// Check if Maps features are enabled
  static bool isMapsEnabled() =>
      enableMapsFeatures && googleMapsApiKey.isNotEmpty;
}
