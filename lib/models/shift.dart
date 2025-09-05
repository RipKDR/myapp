class Shift {
  final String id;
  final String staff;
  final DateTime start;
  final DateTime end;
  final String participant;
  final bool confirmed;

  Shift({
    required this.id,
    required this.staff,
    required this.start,
    required this.end,
    required this.participant,
    this.confirmed = false,
  });

  bool overlaps(Shift other) {
    if (staff != other.staff) return false;
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff': staff,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'participant': participant,
        'confirmed': confirmed,
      };

  static Shift fromMap(Map<String, dynamic> m) => Shift(
        id: m['id'] as String,
        staff: m['staff'] as String,
        start: DateTime.parse(m['start'] as String),
        end: DateTime.parse(m['end'] as String),
        participant: m['participant'] as String,
        confirmed: (m['confirmed'] as bool?) ?? false,
      );
}

