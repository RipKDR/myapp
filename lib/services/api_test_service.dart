import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service to test API configurations and connectivity
class ApiTestService {
  /// Test Google Maps API key
  static Future<bool> testGoogleMapsApi() async {
    try {
      if (!ApiConfig.isMapsEnabled()) {
        return false;
      }
      // Test with a simple geocoding request
      final response = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?address=Sydney&key=${ApiConfig.getGoogleMapsApiKey()}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'OK';
      }
      return false;
    } catch (e) {
      debugPrint('Google Maps API test failed: $e');
      return false;
    }
  }

  /// Test Gemini API key
  static Future<bool> testGeminiApi() async {
    try {
      if (!ApiConfig.isAIEnabled()) {
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.geminiGenerateContentEndpoint),
        headers: ApiConfig.geminiHeaders(),
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Hello, this is a test message. Please respond with "API test successful".'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 50,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        return candidates != null && candidates.isNotEmpty;
      }
      return false;
    } catch (e) {
      debugPrint('Gemini API test failed: $e');
      return false;
    }
  }

  /// Test all API configurations
  static Future<Map<String, bool>> testAllApis() async {
    final results = <String, bool>{};

    // Test Google Maps API
    results['google_maps'] = await testGoogleMapsApi();

    // Test Gemini API
    results['gemini_ai'] = await testGeminiApi();

    return results;
  }

  /// Get API status summary
  static Future<String> getApiStatusSummary() async {
    final results = await testAllApis();

    final summary = StringBuffer();
    summary.writeln('API Configuration Status:');
    summary.writeln('========================');

    results.forEach((final api, final isWorking) {
      final status = isWorking ? '[OK]' : '[FAILED]';
      summary.writeln('$api: $status');
    });

    final allWorking = results.values.every((final working) => working);
    summary.writeln(
        '\nOverall Status: ${allWorking ? '[OK] ALL APIS WORKING' : '[WARN] SOME APIS FAILED'}');

    return summary.toString();
  }
}

