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
    String collection,
    String id,
    Map<String, dynamic> data,
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
  static Future<Map<String, dynamic>?> get(String collection, String id) async {
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
  static Future<bool> delete(String collection, String id) async {
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
    String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
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
            (snapshot) => snapshot.docs
                .map((doc) =>
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
    String collection, {
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
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
            (snapshot) => snapshot.docs
                .map((doc) =>
                    {'id': doc.id, ...doc.data() as Map<String, dynamic>})
                .toList(),
          );
    } catch (e) {
      log('Error querying Firestore: $e');
      return const Stream.empty();
    }
  }

  // Batch operations
  static Future<bool> batchWrite(List<BatchOperation> operations) async {
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
  final BatchOperationType type;
  final String collection;
  final String id;
  final Map<String, dynamic>? data;

  BatchOperation.set(this.collection, this.id, this.data)
      : type = BatchOperationType.set;
  BatchOperation.update(this.collection, this.id, this.data)
      : type = BatchOperationType.update;
  BatchOperation.delete(this.collection, this.id)
      : type = BatchOperationType.delete,
        data = null;
}
