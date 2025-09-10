import '../models/appointment.dart';
import '../services/firestore_service.dart';

class AppointmentRepository {
  static const _col = 'appointments';

  // Save appointment
  static Future<bool> save(final Appointment appointment) async {
    final data = appointment.toMap();
    data['updatedAt'] = DateTime.now().toIso8601String();
    return FirestoreService.save(_col, appointment.id, data);
  }

  // Get appointment by ID
  static Future<Appointment?> getById(final String id) async {
    final data = await FirestoreService.get(_col, id);
    return data != null ? Appointment.fromMap(data) : null;
  }

  // Delete appointment
  static Future<bool> delete(final String id) async => FirestoreService.delete(_col, id);

  // Stream all appointments for current user
  static Stream<List<Appointment>> streamForUser(final String userId) => FirestoreService.query(
      _col,
      field: 'userId',
      value: userId,
      orderBy: 'start',
    ).map((final list) => list.map(Appointment.fromMap).toList());

  // Stream appointments for provider
  static Stream<List<Appointment>> streamForProvider(final String providerId) => FirestoreService.query(
      _col,
      field: 'providerId',
      value: providerId,
      orderBy: 'start',
    ).map((final list) => list.map(Appointment.fromMap).toList());

  // Stream all appointments (no filter)
  static Stream<List<Appointment>> stream() => FirestoreService.stream(
      _col,
      orderBy: 'start',
    ).map((final list) => list.map(Appointment.fromMap).toList());

  // Get upcoming appointments
  static Stream<List<Appointment>> getUpcoming(final String userId, {final int limit = 5}) {
    final now = DateTime.now();
    return FirestoreService.query(
      _col,
      field: 'userId',
      value: userId,
      orderBy: 'start',
      limit: limit,
    ).map(
      (final list) => list
          .map(Appointment.fromMap)
          .where((final appointment) => appointment.start.isAfter(now))
          .toList(),
    );
  }

  // Get appointments by date range
  static Stream<List<Appointment>> getByDateRange(
    final String userId,
    final DateTime startDate,
    final DateTime endDate,
  ) => FirestoreService.query(
      _col,
      field: 'userId',
      value: userId,
      orderBy: 'start',
    ).map(
      (final list) => list
          .map(Appointment.fromMap)
          .where(
            (final appointment) =>
                appointment.start.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                appointment.start.isBefore(
                  endDate.add(const Duration(days: 1)),
                ),
          )
          .toList(),
    );

  // Confirm appointment
  static Future<bool> confirm(final String id) async => FirestoreService.save(_col, id, {
      'confirmed': true,
      'confirmedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

  // Cancel appointment
  static Future<bool> cancel(final String id, final String reason) async => FirestoreService.save(_col, id, {
      'cancelled': true,
      'cancelledAt': DateTime.now().toIso8601String(),
      'cancellationReason': reason,
      'updatedAt': DateTime.now().toIso8601String(),
    });

  // Reschedule appointment
  static Future<bool> reschedule(
    final String id,
    final DateTime newStart,
    final DateTime newEnd,
  ) async => FirestoreService.save(_col, id, {
      'start': newStart.toIso8601String(),
      'end': newEnd.toIso8601String(),
      'rescheduledAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

  // Get appointment statistics
  static Future<Map<String, int>> getStats(final String userId) async {
    final appointments = await streamForUser(userId).first;
    final now = DateTime.now();

    return {
      'total': appointments.length,
      'upcoming': appointments
          .where((final a) => a.start.isAfter(now) && !a.cancelled)
          .length,
      'completed':
          appointments.where((final a) => a.end.isBefore(now) && !a.cancelled).length,
      'cancelled': appointments.where((final a) => a.cancelled).length,
      'pending_confirmation':
          appointments.where((final a) => !a.confirmed && !a.cancelled).length,
    };
  }
}
