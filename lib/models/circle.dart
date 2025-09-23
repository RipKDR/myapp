class CircleMember {
  const CircleMember({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
  });
  final String id;
  final String name;
  final String role; // e.g., Participant, Provider, Family
  final String? email;
  final String? phone;
}

class CircleMessage { // if encrypted, holds {n,c,t}
  const CircleMessage({
    required this.id,
    required this.authorId,
    required this.text,
    required this.sentAt,
    this.encrypted = false,
    this.payload,
  });
  final String id;
  final String authorId;
  final String text;
  final DateTime sentAt;
  final bool encrypted;
  final Map<String, String>? payload;
}

class GoalCard { // Todo, Doing, Done
  const GoalCard({required this.id, required this.title, required this.status});
  final String id;
  final String title;
  final String status;
}

class SupportCircle {

  const SupportCircle({
    required this.id,
    required this.name,
    required this.participantId,
    this.description,
    this.members = const [],
  });
  final String id;
  final String name;
  final String participantId;
  final String? description;
  final List<CircleMember> members;

  SupportCircle copyWith({
    final String? id,
    final String? name,
    final String? participantId,
    final String? description,
    final List<CircleMember>? members,
  }) => SupportCircle(
        id: id ?? this.id,
        name: name ?? this.name,
        participantId: participantId ?? this.participantId,
        description: description ?? this.description,
        members: members ?? this.members,
      );
}
