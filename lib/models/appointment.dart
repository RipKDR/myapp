enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final String providerName;
  final String? providerId;
  // participantId is the external-facing name used in tests; userId kept for backwards compatibility
  final String? participantId;
  final String? userId;
  final bool confirmed;
  final bool cancelled;
  final String? description;
  final String? location;
  final String? notes;
  final String? cancellationReason;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? rescheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Preserve explicit status if provided (used by tests and copyWith)
  final AppointmentStatus? _explicitStatus;

  // Accept both start/end and startTime/endTime for compatibility with tests.
  Appointment({
    required this.id,
    DateTime? start,
    DateTime? startTime,
    DateTime? end,
    DateTime? endTime,
    required this.title,
    this.providerName = '',
    this.providerId,
    String? participantId,
    String? userId,
    bool confirmed = false,
    bool cancelled = false,
    AppointmentStatus? status,
    this.description,
    this.location,
    this.notes,
    this.cancellationReason,
    this.confirmedAt,
    this.cancelledAt,
    this.rescheduledAt,
    this.createdAt,
    this.updatedAt,
  })  : start = startTime ??
            start ??
            (throw ArgumentError('start/startTime required')),
        end = endTime ?? end ?? (throw ArgumentError('end/endTime required')),
        // prefer explicit participantId but keep userId for existing code
        participantId = participantId ?? userId,
        userId = userId ?? participantId,
        confirmed = confirmed,
        cancelled = cancelled || (status == AppointmentStatus.cancelled),
        _explicitStatus = status {
    // Basic validation expected by tests
    if (id.isEmpty) {
      throw ArgumentError('id is required');
    }
    if (!this.end.isAfter(this.start)) {
      throw ArgumentError('end must be after start');
    }
    // Reject appointments that start in the past (per unit tests)
    // Allow appointments up to 1 minute in the past to account for clock differences
    final now = DateTime.now();
    if (this.start.isBefore(now.subtract(const Duration(minutes: 1)))) {
      throw ArgumentError('start must be in the future');
    }
  }

  Appointment copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? title,
    String? providerName,
    String? providerId,
    String? participantId,
    String? userId,
    bool? confirmed,
    bool? cancelled,
    String? description,
    String? location,
    String? notes,
    AppointmentStatus? status,
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
      participantId: participantId ?? this.participantId,
      userId: userId ?? this.userId,
      confirmed: confirmed ?? this.confirmed,
      cancelled: cancelled ?? this.cancelled,
      description: description ?? this.description,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? _explicitStatus,
      // Map status onto flags for compatibility
      cancelledAt: (status != null && status == AppointmentStatus.cancelled)
          ? (cancelledAt ?? DateTime.now())
          : cancelledAt ?? this.cancelledAt,
      confirmedAt: (status != null &&
              status == AppointmentStatus.scheduled &&
              (confirmed ?? this.confirmed))
          ? (confirmedAt ?? DateTime.now())
          : confirmedAt ?? this.confirmedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
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
        'participantId': participantId,
        'confirmed': confirmed,
        'cancelled': cancelled,
        'description': description,
        'location': location,
        'notes': notes,
        // Provide a status string for tests
        'status': status.name,
        'cancellationReason': cancellationReason,
        'confirmedAt': confirmedAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'rescheduledAt': rescheduledAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Appointment fromMap(Map<String, dynamic> m) {
    try {
      return Appointment(
        id: m['id'] as String? ?? '',
        start: DateTime.parse((m['startTime'] ?? m['start']) as String? ?? ''),
        end: DateTime.parse((m['endTime'] ?? m['end']) as String? ?? ''),
        title: m['title'] as String? ?? '',
        providerName: (m['providerName'] as String?) ?? '',
        providerId: m['providerId'] as String?,
        participantId:
            (m['participantId'] as String?) ?? (m['userId'] as String?),
        userId: (m['userId'] as String?) ?? (m['participantId'] as String?),
        confirmed: (m['confirmed'] as bool?) ?? false,
        cancelled: ((m['cancelled'] as bool?) ?? false) ||
            ((m['status'] as String?) == 'cancelled'),
        status: _parseAppointmentStatus(m['status'] as String?),
        description: m['description'] as String?,
        location: m['location'] as String?,
        notes: m['notes'] as String?,
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
    } catch (e) {
      throw ArgumentError('Invalid appointment data: $e');
    }
  }

  // Helper methods
  bool get isUpcoming => start.isAfter(DateTime.now()) && !cancelled;
  bool get isCompleted => end.isBefore(DateTime.now()) && !cancelled;
  bool get isPendingConfirmation => !confirmed && !cancelled;
  Duration get duration => end.difference(start);

  AppointmentStatus get status {
    if (_explicitStatus != null) return _explicitStatus;
    if (cancelled) return AppointmentStatus.cancelled;
    if (isCompleted) return AppointmentStatus.completed;
    return AppointmentStatus.scheduled;
  }

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

AppointmentStatus _parseAppointmentStatus(String? s) {
  switch (s) {
    case 'completed':
      return AppointmentStatus.completed;
    case 'cancelled':
      return AppointmentStatus.cancelled;
    case 'scheduled':
    default:
      return AppointmentStatus.scheduled;
  }
}
