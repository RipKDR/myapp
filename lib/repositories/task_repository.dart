import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskRepository {
  static const _col = 'tasks';

  static Future<void> save(PlanTask t) async {
    await FirestoreService.save(_col, t.id, t.toMap());
  }

  static Stream<List<PlanTask>> stream() =>
      FirestoreService.stream(_col).map((e) => e.map(PlanTask.fromMap).toList());
}
