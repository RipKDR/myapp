import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

/// Optimized appointment repository with caching and performance improvements
class OptimizedAppointmentRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, List<Appointment>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _defaultPageSize = 20;

  /// Get appointments with pagination and caching
  static Future<List<Appointment>> getAppointments({
    String? userId,
    int limit = _defaultPageSize,
    DocumentSnapshot? startAfter,
    bool useCache = true,
  }) async {
    final cacheKey =
        'appointments_${userId ?? 'all'}_${limit}_${startAfter?.id ?? 'first'}';

    // Check cache first
    if (useCache && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      // Build optimized query
      Query query = _firestore
          .collection('appointments')
          .orderBy('start', descending: false)
          .limit(limit);

      // Add user filter if specified
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      // Add pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Execute query
      final snapshot = await query.get();

      // Convert to appointments
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Cache result
      _cache[cacheKey] = appointments;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return appointments;
    } catch (e) {
      // Return cached data if available, even if expired
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// Get appointment by ID with caching
  static Future<Appointment?> getAppointmentById(String id) async {
    const cacheKey = 'appointment_';

    // Check cache first
    if (_isCacheValid(cacheKey + id)) {
      return _cache[cacheKey + id]?.first;
    }

    try {
      final doc = await _firestore.collection('appointments').doc(id).get();

      if (doc.exists) {
        final appointment = Appointment.fromMap(doc.data()!);

        // Cache result
        _cache[cacheKey + id] = [appointment];
        _cacheTimestamps[cacheKey + id] = DateTime.now();

        return appointment;
      }

      return null;
    } catch (e) {
      // Return cached data if available
      if (_cache.containsKey(cacheKey + id)) {
        return _cache[cacheKey + id]?.first;
      }
      rethrow;
    }
  }

  /// Create appointment with optimistic updates
  static Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      // Add to Firestore
      final docRef =
          await _firestore.collection('appointments').add(appointment.toMap());

      // Update appointment with ID
      final createdAppointment = appointment.copyWith(id: docRef.id);

      // Update Firestore with ID
      await docRef.update({'id': docRef.id});

      // Invalidate related cache
      _invalidateUserCache(appointment.userId);

      return createdAppointment;
    } catch (e) {
      rethrow;
    }
  }

  /// Update appointment with optimistic updates
  static Future<Appointment> updateAppointment(Appointment appointment) async {
    try {
      // Update Firestore
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toMap());

      // Invalidate related cache
      _invalidateUserCache(appointment.userId);
      _invalidateAppointmentCache(appointment.id);

      return appointment;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete appointment
  static Future<void> deleteAppointment(String id, String? userId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('appointments').doc(id).delete();

      // Invalidate related cache
      if (userId != null) {
        _invalidateUserCache(userId);
      }
      _invalidateAppointmentCache(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get upcoming appointments (optimized query)
  static Future<List<Appointment>> getUpcomingAppointments({
    String? userId,
    int limit = 10,
  }) async {
    final cacheKey = 'upcoming_${userId ?? 'all'}_$limit';

    // Check cache first
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final now = DateTime.now();

      Query query = _firestore
          .collection('appointments')
          .where('start', isGreaterThan: now)
          .orderBy('start', descending: false)
          .limit(limit);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Cache result
      _cache[cacheKey] = appointments;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return appointments;
    } catch (e) {
      // Return cached data if available
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// Get appointments by date range (optimized query)
  static Future<List<Appointment>> getAppointmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    int limit = 50,
  }) async {
    final cacheKey =
        'dateRange_${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}_${userId ?? 'all'}';

    // Check cache first
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      Query query = _firestore
          .collection('appointments')
          .where('start', isGreaterThanOrEqualTo: startDate)
          .where('start', isLessThanOrEqualTo: endDate)
          .orderBy('start', descending: false)
          .limit(limit);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Cache result
      _cache[cacheKey] = appointments;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return appointments;
    } catch (e) {
      // Return cached data if available
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// Stream appointments with real-time updates
  static Stream<List<Appointment>> streamAppointments({
    String? userId,
    int limit = _defaultPageSize,
  }) {
    Query query = _firestore
        .collection('appointments')
        .orderBy('start', descending: false)
        .limit(limit);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Check if cache is valid
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Invalidate cache for a specific user
  static void _invalidateUserCache(String? userId) {
    if (userId == null) return;

    final keysToRemove = <String>[];
    for (var key in _cache.keys) {
      if (key.contains('_${userId}_') || key.contains('_$userId')) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Invalidate cache for a specific appointment
  static void _invalidateAppointmentCache(String appointmentId) {
    final keysToRemove = <String>[];
    for (var key in _cache.keys) {
      if (key.contains('appointment_$appointmentId')) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Clear all cache
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _cache.length,
      'cacheKeys': _cache.keys.toList(),
      'oldestEntry': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'newestEntry': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }
}
