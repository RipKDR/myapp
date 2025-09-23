import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore? _db;

  static FirebaseFirestore? get db {
    try {
      _db ??= FirebaseFirestore.instance;
      return _db;
    } catch (e) {
      log('Firestore unavailable: $e');
      return null;
    }
  }

  // Generic save operation
  static Future<bool> save(
    final String collection,
    final String id,
    final Map<String, dynamic> data,
  ) async {
    try {
      final d = db;
      if (d == null) {
        log('Firestore not available for save operation');
        return false;
      }

      await d.collection(collection).doc(id).set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      log('Error saving to Firestore: $e');
      return false;
    }
  }

  // Generic get operation
  static Future<Map<String, dynamic>?> get(final String collection, final String id) async {
    try {
      final d = db;
      if (d == null) return null;

      final doc = await d.collection(collection).doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      log('Error getting from Firestore: $e');
      return null;
    }
  }

  // Generic delete operation
  static Future<bool> delete(final String collection, final String id) async {
    try {
      final d = db;
      if (d == null) return false;

      await d.collection(collection).doc(id).delete();
      return true;
    } catch (e) {
      log('Error deleting from Firestore: $e');
      return false;
    }
  }

  // Generic stream operation
  static Stream<List<Map<String, dynamic>>> stream(
    final String collection, {
    final String? orderBy,
    final bool descending = false,
    final int? limit,
    final DocumentSnapshot? startAfter,
  }) {
    try {
      final d = db;
      if (d == null) return const Stream.empty();

      Query query = d.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots().map(
            (final snapshot) => snapshot.docs
                .map((final doc) =>
                    {'id': doc.id, ...doc.data() as Map<String, dynamic>})
                .toList(),
          );
    } catch (e) {
      log('Error streaming from Firestore: $e');
      return const Stream.empty();
    }
  }

  // Query with where clause
  static Stream<List<Map<String, dynamic>>> query(
    final String collection, {
    required final String field,
    required final dynamic value,
    final String? orderBy,
    final bool descending = false,
    final int? limit,
  }) {
    try {
      final d = db;
      if (d == null) return const Stream.empty();

      Query query = d.collection(collection).where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map(
            (final snapshot) => snapshot.docs
                .map((final doc) =>
                    {'id': doc.id, ...doc.data() as Map<String, dynamic>})
                .toList(),
          );
    } catch (e) {
      log('Error querying Firestore: $e');
      return const Stream.empty();
    }
  }

  // Batch operations
  static Future<bool> batchWrite(final List<BatchOperation> operations) async {
    try {
      final d = db;
      if (d == null) return false;

      final batch = d.batch();

      for (final op in operations) {
        switch (op.type) {
          case BatchOperationType.set:
            batch.set(d.collection(op.collection).doc(op.id), op.data!);
            break;
          case BatchOperationType.update:
            batch.update(d.collection(op.collection).doc(op.id), op.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(d.collection(op.collection).doc(op.id));
            break;
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      log('Error in batch write: $e');
      return false;
    }
  }

  // Enable offline persistence
  static Future<void> enableOfflinePersistence() async {
    try {
      final d = db;
      if (d == null) return;

      // Persistence is enabled by default in newer versions
      log('Firestore offline persistence enabled');
    } catch (e) {
      log('Error enabling offline persistence: $e');
    }
  }
}

enum BatchOperationType { set, update, delete }

class BatchOperation {

  BatchOperation.set(this.collection, this.id, this.data)
      : type = BatchOperationType.set;
  BatchOperation.update(this.collection, this.id, this.data)
      : type = BatchOperationType.update;
  BatchOperation.delete(this.collection, this.id)
      : type = BatchOperationType.delete,
        data = null;
  final BatchOperationType type;
  final String collection;
  final String id;
  final Map<String, dynamic>? data;
}
