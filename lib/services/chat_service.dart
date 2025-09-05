// Dialogflow integration with offline fallback.
// Provide a Cloud Function or API endpoint via --dart-define=DIALOGFLOW_ENDPOINT=https://... and optional auth header via --dart-define=DIALOGFLOW_AUTH=Bearer xyz

import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _endpoint = String.fromEnvironment('DIALOGFLOW_ENDPOINT');
  static const String _auth = String.fromEnvironment('DIALOGFLOW_AUTH');

  Future<String> ask(String query) async {
    if (_endpoint.isNotEmpty) {
      try {
        final res = await http.post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            if (_auth.isNotEmpty) 'Authorization': _auth,
          },
          body: jsonEncode({'query': query}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return (data['reply'] as String?) ?? 'Okay';
        }
      } catch (_) {
        // fall through to offline
      }
    }
    // Offline quick answers to common NDIS questions.
    final q = query.toLowerCase();
    if (q.contains('budget') || q.contains('core')) {
      return 'To track your NDIS budget, open Budget Tracker. We will alert you if buckets reach 80%. You can also upload invoices or compare rates.';
    }
    if (q.contains('book') || q.contains('session')) {
      return 'Use Smart Scheduling to find available times. One-tap to book and get points for attendance.';
    }
    if (q.contains('map') || q.contains('provider')) {
      return 'Open Service Map to filter providers by wait times and accessibility. Offline tips are cached.';
    }
    return 'Thanks for your question. For complex queries, we can escalate to NDIA or your support coordinator.';
  }
}
