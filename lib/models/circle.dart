class CircleMember {
  final String id;
  final String name;
  final String role; // e.g., Participant, Provider, Family
  const CircleMember({required this.id, required this.name, required this.role});
}

class CircleMessage {
  final String id;
  final String authorId;
  final String text;
  final DateTime sentAt;
  final bool encrypted;
  final Map<String, String>? payload; // if encrypted, holds {n,c,t}
  const CircleMessage({
    required this.id,
    required this.authorId,
    required this.text,
    required this.sentAt,
    this.encrypted = false,
    this.payload,
  });
}

class GoalCard {
  final String id;
  final String title;
  final String status; // Todo, Doing, Done
  const GoalCard({required this.id, required this.title, required this.status});
}
