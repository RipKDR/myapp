/// API Configuration for NDIS Connect
///
/// This file contains all API keys and configuration for external services.
/// In production, these should be loaded from environment variables or secure storage.
class ApiConfig {
  // Google Maps API Key
  static const String googleMapsApiKey =
      'AIzaSyBYEed3sy2-qp1KGeEhvzSP4JwzaRgAzTg';

  // Gemini API Key for AI features
  static const String geminiApiKey = 'AIzaSyCTSDz6jdRsTDcoL8MExmRcwcan4cWnW6w';

  // Gemini API Configuration
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-1.5-flash';

  // API Endpoints
  static const String geminiGenerateContentEndpoint =
      '$geminiApiUrl/models/$geminiModel:generateContent';

  // Request Configuration
  static const Map<String, String> geminiHeaders = {
    'Content-Type': 'application/json',
    'x-goog-api-key': geminiApiKey,
  };

  // Feature Flags for API Usage
  static const bool enableGeminiAI = true;
  static const bool enableMapsFeatures = true;

  /// Get Gemini API key for HTTP requests
  static String getGeminiApiKey() {
    return geminiApiKey;
  }

  /// Get Google Maps API key
  static String getGoogleMapsApiKey() {
    return googleMapsApiKey;
  }

  /// Check if AI features are enabled
  static bool isAIEnabled() {
    return enableGeminiAI && geminiApiKey.isNotEmpty;
  }

  /// Check if Maps features are enabled
  static bool isMapsEnabled() {
    return enableMapsFeatures && googleMapsApiKey.isNotEmpty;
  }
}
