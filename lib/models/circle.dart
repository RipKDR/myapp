class CircleMember {
  final String id;
  final String name;
  final String role; // e.g., Participant, Provider, Family
  final String? email;
  final String? phone;
  const CircleMember({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
  });
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

class SupportCircle {
  final String id;
  final String name;
  final String participantId;
  final String? description;
  final List<CircleMember> members;

  const SupportCircle({
    required this.id,
    required this.name,
    required this.participantId,
    this.description,
    this.members = const [],
  });

  SupportCircle copyWith({
    String? id,
    String? name,
    String? participantId,
    String? description,
    List<CircleMember>? members,
  }) => SupportCircle(
        id: id ?? this.id,
        name: name ?? this.name,
        participantId: participantId ?? this.participantId,
        description: description ?? this.description,
        members: members ?? this.members,
      );
}
