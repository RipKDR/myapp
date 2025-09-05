class Appointment {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final String providerName;
  final String? providerId;
  final String? userId;
  final bool confirmed;
  final bool cancelled;
  final String? description;
  final String? location;
  final String? cancellationReason;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? rescheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.providerName,
    this.providerId,
    this.userId,
    this.confirmed = false,
    this.cancelled = false,
    this.description,
    this.location,
    this.cancellationReason,
    this.confirmedAt,
    this.cancelledAt,
    this.rescheduledAt,
    this.createdAt,
    this.updatedAt,
  });

  Appointment copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? title,
    String? providerName,
    String? providerId,
    String? userId,
    bool? confirmed,
    bool? cancelled,
    String? description,
    String? location,
    String? cancellationReason,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    DateTime? rescheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      title: title ?? this.title,
      providerName: providerName ?? this.providerName,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      confirmed: confirmed ?? this.confirmed,
      cancelled: cancelled ?? this.cancelled,
      description: description ?? this.description,
      location: location ?? this.location,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'title': title,
    'providerName': providerName,
    'providerId': providerId,
    'userId': userId,
    'confirmed': confirmed,
    'cancelled': cancelled,
    'description': description,
    'location': location,
    'cancellationReason': cancellationReason,
    'confirmedAt': confirmedAt?.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
    'rescheduledAt': rescheduledAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static Appointment fromMap(Map<String, dynamic> m) => Appointment(
    id: m['id'] as String,
    start: DateTime.parse(m['start'] as String),
    end: DateTime.parse(m['end'] as String),
    title: m['title'] as String,
    providerName: m['providerName'] as String,
    providerId: m['providerId'] as String?,
    userId: m['userId'] as String?,
    confirmed: (m['confirmed'] as bool?) ?? false,
    cancelled: (m['cancelled'] as bool?) ?? false,
    description: m['description'] as String?,
    location: m['location'] as String?,
    cancellationReason: m['cancellationReason'] as String?,
    confirmedAt: m['confirmedAt'] != null
        ? DateTime.parse(m['confirmedAt'] as String)
        : null,
    cancelledAt: m['cancelledAt'] != null
        ? DateTime.parse(m['cancelledAt'] as String)
        : null,
    rescheduledAt: m['rescheduledAt'] != null
        ? DateTime.parse(m['rescheduledAt'] as String)
        : null,
    createdAt: m['createdAt'] != null
        ? DateTime.parse(m['createdAt'] as String)
        : null,
    updatedAt: m['updatedAt'] != null
        ? DateTime.parse(m['updatedAt'] as String)
        : null,
  );

  // Helper methods
  bool get isUpcoming => start.isAfter(DateTime.now()) && !cancelled;
  bool get isCompleted => end.isBefore(DateTime.now()) && !cancelled;
  bool get isPendingConfirmation => !confirmed && !cancelled;
  Duration get duration => end.difference(start);

  @override
  String toString() =>
      'Appointment(id: $id, title: $title, start: $start, provider: $providerName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
