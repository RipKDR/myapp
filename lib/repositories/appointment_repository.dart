import '../models/appointment.dart';
import '../services/firestore_service.dart';

class AppointmentRepository {
  static const _col = 'appointments';

  // Save appointment
  static Future<bool> save(Appointment appointment) async {
    final data = appointment.toMap();
    data['updatedAt'] = DateTime.now().toIso8601String();
    return await FirestoreService.save(_col, appointment.id, data);
  }

  // Get appointment by ID
  static Future<Appointment?> getById(String id) async {
    final data = await FirestoreService.get(_col, id);
    return data != null ? Appointment.fromMap(data) : null;
  }

  // Delete appointment
  static Future<bool> delete(String id) async {
    return await FirestoreService.delete(_col, id);
  }

  // Stream all appointments for current user
  static Stream<List<Appointment>> streamForUser(String userId) {
    return FirestoreService.query(
      _col,
      field: 'userId',
      value: userId,
      orderBy: 'start',
      descending: false,
    ).map((list) => list.map(Appointment.fromMap).toList());
  }

  // Stream appointments for provider
  static Stream<List<Appointment>> streamForProvider(String providerId) {
    return FirestoreService.query(
      _col,
      field: 'providerId',
      value: providerId,
      orderBy: 'start',
      descending: false,
    ).map((list) => list.map(Appointment.fromMap).toList());
  }

  // Stream all appointments (no filter)
  static Stream<List<Appointment>> stream() {
    return FirestoreService.stream(
      _col,
      orderBy: 'start',
      descending: false,
    ).map((list) => list.map(Appointment.fromMap).toList());
  }

  // Get upcoming appointments
  static Stream<List<Appointment>> getUpcoming(String userId, {int limit = 5}) {
    final now = DateTime.now();
    return FirestoreService.query(
      _col,
      field: 'userId',
      value: userId,
      orderBy: 'start',
      descending: false,
      limit: limit,
    ).map(
      (list) => list
          .map(Appointment.fromMap)
          .where((appointment) => appointment.start.isAfter(now))
          .toList(),
    );
  }

  // Get appointments by date range
  static Stream<List<Appointment>> getByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return FirestoreService.query(
      _col,
      field: 'userId',
      value: userId,
      orderBy: 'start',
      descending: false,
    ).map(
      (list) => list
          .map(Appointment.fromMap)
          .where(
            (appointment) =>
                appointment.start.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                appointment.start.isBefore(
                  endDate.add(const Duration(days: 1)),
                ),
          )
          .toList(),
    );
  }

  // Confirm appointment
  static Future<bool> confirm(String id) async {
    return await FirestoreService.save(_col, id, {
      'confirmed': true,
      'confirmedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Cancel appointment
  static Future<bool> cancel(String id, String reason) async {
    return await FirestoreService.save(_col, id, {
      'cancelled': true,
      'cancelledAt': DateTime.now().toIso8601String(),
      'cancellationReason': reason,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Reschedule appointment
  static Future<bool> reschedule(
    String id,
    DateTime newStart,
    DateTime newEnd,
  ) async {
    return await FirestoreService.save(_col, id, {
      'start': newStart.toIso8601String(),
      'end': newEnd.toIso8601String(),
      'rescheduledAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get appointment statistics
  static Future<Map<String, int>> getStats(String userId) async {
    final appointments = await streamForUser(userId).first;
    final now = DateTime.now();

    return {
      'total': appointments.length,
      'upcoming': appointments
          .where((a) => a.start.isAfter(now) && !a.cancelled)
          .length,
      'completed':
          appointments.where((a) => a.end.isBefore(now) && !a.cancelled).length,
      'cancelled': appointments.where((a) => a.cancelled).length,
      'pending_confirmation':
          appointments.where((a) => !a.confirmed && !a.cancelled).length,
    };
  }
}
