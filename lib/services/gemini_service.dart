import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static final bool _enabled = _apiKey.isNotEmpty;

  static bool get isEnabled => _enabled;

  static Future<String?> ask(final String prompt) async {
    if (!_enabled) return null;
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final resp = await model.generateContent([Content.text(prompt)]);
      final text = resp.text?.trim();
      if (text == null || text.isEmpty) return null;
      return text;
    } catch (e, st) {
      log('Gemini ask failed: $e', stackTrace: st);
      return null;
    }
  }
}


