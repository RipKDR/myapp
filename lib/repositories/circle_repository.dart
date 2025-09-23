import '../models/circle.dart';
import '../services/firestore_service.dart';

class CircleRepository {
  static const _goalsCol = 'goals';
  static const _messagesCol = 'messages';

  static Future<void> saveGoal(final String boardId, final GoalCard g) async {
    await FirestoreService.save('circles/$boardId/$_goalsCol', g.id, {
      'id': g.id,
      'title': g.title,
      'status': g.status,
    });
  }

  static Future<void> saveMessage(final String boardId, final CircleMessage m) async {
    await FirestoreService.save('circles/$boardId/$_messagesCol', m.id, {
      'id': m.id,
      'authorId': m.authorId,
      'text': m.text,
      'sentAt': m.sentAt.toIso8601String(),
    });
  }

  static Future<void> saveEncryptedMessage(final String boardId, final CircleMessage m, final Map<String, String> payload) async {
    await FirestoreService.save('circles/$boardId/$_messagesCol', m.id, {
      'id': m.id,
      'authorId': m.authorId,
      'encrypted': true,
      'payload': payload,
      'sentAt': m.sentAt.toIso8601String(),
    });
  }

  static Stream<List<GoalCard>> streamGoals(final String boardId) => FirestoreService
      .stream('circles/$boardId/$_goalsCol')
      .map((final e) => e.map((final m) => GoalCard(id: m['id'], title: m['title'], status: m['status'])).toList());

  static Stream<List<CircleMessage>> streamMessages(final String boardId) => FirestoreService
      .stream('circles/$boardId/$_messagesCol')
      .map((final e) => e
          .map((final m) => CircleMessage(
                id: m['id'],
                authorId: m['authorId'],
                text: (m['text'] ?? '') as String,
                sentAt: DateTime.tryParse(m['sentAt'] ?? '') ?? DateTime.now(),
                encrypted: (m['encrypted'] as bool?) ?? false,
                payload: m['payload'] == null ? null : Map<String, String>.from(m['payload'] as Map),
              ))
          .toList());
}
