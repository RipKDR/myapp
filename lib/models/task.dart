class PlanTask {
  final String id;
  final String title;
  final bool done;
  final int priority; // 1=high, 2=med, 3=low
  const PlanTask({required this.id, required this.title, this.done = false, this.priority = 2});

  PlanTask toggle() => PlanTask(id: id, title: title, done: !done, priority: priority);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'done': done,
        'priority': priority,
      };

  static PlanTask fromMap(Map<String, dynamic> m) => PlanTask(
        id: m['id'] as String,
        title: m['title'] as String,
        done: (m['done'] as bool?) ?? false,
        priority: (m['priority'] as num?)?.toInt() ?? 2,
      );
}
