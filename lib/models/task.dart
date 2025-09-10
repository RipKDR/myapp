class PlanTask {

  const PlanTask({
    required this.id,
    required this.title,
    this.description,
    this.done = false,
    this.priority = 2,
    this.dueDate,
    this.category,
    this.completedAt,
  });
  final String id;
  final String title;
  final String? description;
  final bool done;
  final int priority; // 1=high, 2=med, 3=low
  final DateTime? dueDate;
  final String? category;
  final DateTime? completedAt;

  bool get isOverdue => (dueDate != null) && !done && DateTime.now().isAfter(dueDate!);

  PlanTask toggle() => PlanTask(
        id: id,
        title: title,
        description: description,
        done: !done,
        priority: priority,
        dueDate: dueDate,
        category: category,
        completedAt: !done ? DateTime.now() : null,
      );

  PlanTask copyWith({
    final String? id,
    final String? title,
    final String? description,
    final bool? done,
    final int? priority,
    final DateTime? dueDate,
    final String? category,
    final DateTime? completedAt,
  }) => PlanTask(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        done: done ?? this.done,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        category: category ?? this.category,
        completedAt: completedAt ?? this.completedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'done': done,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
        'completedAt': completedAt?.toIso8601String(),
      };

  static PlanTask fromMap(final Map<String, dynamic> m) => PlanTask(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        done: (m['done'] as bool?) ?? false,
        priority: (m['priority'] as num?)?.toInt() ?? 2,
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null,
        category: m['category'] as String?,
        completedAt: m['completedAt'] != null ? DateTime.parse(m['completedAt'] as String) : null,
      );
}
