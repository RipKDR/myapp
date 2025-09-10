import '../models/shift.dart';
import '../services/firestore_service.dart';

class ShiftRepository {
  static const _col = 'shifts';
  static Future<void> save(final Shift s) => FirestoreService.save(_col, s.id, s.toMap());
  static Stream<List<Shift>> stream() => FirestoreService.stream(_col).map((final e) => e.map(Shift.fromMap).toList());
}

