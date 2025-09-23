enum ShiftStatus { available, booked, completed, cancelled }

class Shift {

  Shift({
    required this.id,
    final String? staff,
    final DateTime? start,
    final DateTime? startTime,
    final DateTime? end,
    final DateTime? endTime,
    final String? participant,
    this.confirmed = false,
    this.providerId,
    this.maxParticipants,
    final List<String>? participantIds,
    final ShiftStatus? status,
    this.location,
  })  : staff = staff ?? 'Staff',
        start = startTime ?? start ?? (throw ArgumentError('start/startTime required')),
        end = endTime ?? end ?? (throw ArgumentError('end/endTime required')),
        participant = participant ?? 'Participant',
        status = status ?? ShiftStatus.available,
        participantIds = participantIds ?? const [] {
    if (!this.end.isAfter(this.start)) {
      throw ArgumentError('end must be after start');
    }
  }
  final String id;
  // Original fields used in roster UI
  final String staff;
  final DateTime start;
  final DateTime end;
  final String participant;
  final bool confirmed;
  final String? location;

  // Extended fields to satisfy tests and richer features
  final String? providerId;
  final int? maxParticipants;
  final List<String> participantIds;
  final ShiftStatus status;

  Duration get duration => end.difference(start);
  int get availableSpots => (maxParticipants ?? 0) - participantIds.length;
  bool get isFullyBooked => maxParticipants != null && participantIds.length >= maxParticipants!;

  bool overlaps(final Shift other) {
    if (staff != other.staff) return false;
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  Shift copyWith({
    final String? id,
    final String? staff,
    final DateTime? start,
    final DateTime? end,
    final String? participant,
    final bool? confirmed,
    final String? providerId,
    final int? maxParticipants,
    final List<String>? participantIds,
    final ShiftStatus? status,
  }) => Shift(
        id: id ?? this.id,
        staff: staff ?? this.staff,
        start: start ?? this.start,
        end: end ?? this.end,
        participant: participant ?? this.participant,
        confirmed: confirmed ?? this.confirmed,
        providerId: providerId ?? this.providerId,
        maxParticipants: maxParticipants ?? this.maxParticipants,
        participantIds: participantIds ?? this.participantIds,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff': staff,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'participant': participant,
        'confirmed': confirmed,
        'providerId': providerId,
        'maxParticipants': maxParticipants,
        'participantIds': participantIds,
        'status': status.name,
      };

  static Shift fromMap(final Map<String, dynamic> m) => Shift(
        id: m['id'] as String,
        staff: (m['staff'] as String?) ?? 'Staff',
        start: DateTime.parse((m['startTime'] ?? m['start']) as String),
        end: DateTime.parse((m['endTime'] ?? m['end']) as String),
        participant: (m['participant'] as String?) ?? 'Participant',
        confirmed: (m['confirmed'] as bool?) ?? false,
        providerId: m['providerId'] as String?,
        maxParticipants: (m['maxParticipants'] as num?)?.toInt(),
        participantIds: (m['participantIds'] as List?)?.cast<String>() ?? const [],
        status: _parseStatus(m['status'] as String?),
      );
}

ShiftStatus _parseStatus(final String? s) {
  switch (s) {
    case 'booked':
      return ShiftStatus.booked;
    case 'completed':
      return ShiftStatus.completed;
    case 'cancelled':
      return ShiftStatus.cancelled;
    default:
      return ShiftStatus.available;
  }
}
