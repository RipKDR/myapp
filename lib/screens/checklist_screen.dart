import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../controllers/gamification_controller.dart';
import '../repositories/task_repository.dart';
import '../theme/app_theme.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});
  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with TickerProviderStateMixin {
  final _tasks = <PlanTask>[
    const PlanTask(id: 't1', title: 'Book session with physio', priority: 1),
    const PlanTask(id: 't2', title: 'Upload last invoice'),
    const PlanTask(id: 't3', title: 'Check Core budget', priority: 1),
  ];

  late AnimationController _progressController;
  late AnimationController _celebrationController;
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'High Priority',
    'Medium Priority',
    'Low Priority',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    TaskRepository.stream().listen((final cloud) {
      if (!mounted || cloud.isEmpty) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(cloud);
      });
      _updateProgress();
    });

    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final completed = _tasks.where((final t) => t.done).length;
    final total = _tasks.length;
    final progress = total > 0 ? completed / total : 0.0;
    _progressController.animateTo(progress);
  }

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredTasks = _getFilteredTasks();
    final completedCount = _tasks.where((final t) => t.done).length;
    final totalCount = _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Plan Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.ndisBlue, AppTheme.ndisTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist_rtl,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan Progress',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '$completedCount of $totalCount tasks completed',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((completedCount / totalCount) * 100).round()}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (final context, final child) => LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                ),
              ],
            ),
          ),

          // Filter Chips
          if (_selectedFilter != 'All')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Filter: $_selectedFilter',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedFilter = 'All'),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Tasks List
          Expanded(
            child: filteredTasks.isEmpty
                ? _EmptyState(filter: _selectedFilter)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (final context, final index) {
                      final task = filteredTasks[index];
                      return _TaskCard(
                        task: task,
                        onToggle: () => _toggle(task),
                        onEdit: () => _editTask(task),
                        onDelete: () => _deleteTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add_task),
        label: const Text('Add Task'),
        backgroundColor: AppTheme.ndisBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  List<PlanTask> _getFilteredTasks() {
    switch (_selectedFilter) {
      case 'High Priority':
        return _tasks.where((final t) => t.priority == 1).toList();
      case 'Medium Priority':
        return _tasks.where((final t) => t.priority == 2).toList();
      case 'Low Priority':
        return _tasks.where((final t) => t.priority == 3).toList();
      case 'Completed':
        return _tasks.where((final t) => t.done).toList();
      default:
        return _tasks;
    }
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((final filter) => RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (final value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            )).toList(),
        ),
      ),
    );
  }

  void _toggle(final PlanTask t) {
    final i = _tasks.indexWhere((final x) => x.id == t.id);
    _tasks[i] = t.toggle();
    _updateProgress();

    if (_tasks[i].done) {
      context.read<GamificationController>().addPoints(2);
      _celebrationController
          .forward()
          .then((_) => _celebrationController.reset());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              SizedBox(width: 8),
              Text('Great job! +2 points earned'),
            ],
          ),
          backgroundColor: AppTheme.ndisGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _editTask(final PlanTask task) {
    final controller = TextEditingController(text: task.title);
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final index = _tasks.indexWhere((final t) => t.id == task.id);
                _tasks[index] = PlanTask(
                  id: task.id,
                  title: newTitle,
                  priority: task.priority,
                  done: task.done,
                );
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(final PlanTask task) {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _tasks.removeWhere((final t) => t.id == task.id);
              _updateProgress();
              setState(() {});
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask() async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Add task'),
        content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'e.g., Book session')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Add'))
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    final t = PlanTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text);
    setState(() => _tasks.add(t));
    TaskRepository.save(t);
  }
}

class _TaskCard extends StatelessWidget {

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  final PlanTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: task.done ? 0 : 2,
        color: task.done
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : scheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.done ? AppTheme.ndisGreen : Colors.transparent,
                    border: Border.all(
                      color: task.done ? AppTheme.ndisGreen : scheme.outline,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: task.done
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              decoration:
                                  task.done ? TextDecoration.lineThrough : null,
                              color: task.done
                                  ? scheme.onSurfaceVariant
                                  : scheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _PriorityChip(priority: task.priority),
                          const SizedBox(width: 8),
                          if (task.done)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.ndisGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Completed',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.ndisGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (final value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (final context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {

  const _PriorityChip({required this.priority});
  final int priority;

  @override
  Widget build(final BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (priority) {
      case 1:
        color = Colors.red;
        label = 'High';
        icon = Icons.priority_high;
        break;
      case 3:
        color = Colors.grey;
        label = 'Low';
        icon = Icons.low_priority;
        break;
      default:
        color = Colors.orange;
        label = 'Medium';
        icon = Icons.flag;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {

  const _EmptyState({required this.filter});
  final String filter;

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.ndisBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.checklist_rtl,
                size: 48,
                color: AppTheme.ndisBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyMessage(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptySubtitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage() {
    switch (filter) {
      case 'High Priority':
        return 'No high priority tasks';
      case 'Medium Priority':
        return 'No medium priority tasks';
      case 'Low Priority':
        return 'No low priority tasks';
      case 'Completed':
        return 'No completed tasks yet';
      default:
        return 'No tasks yet';
    }
  }

  String _getEmptySubtitle() {
    switch (filter) {
      case 'Completed':
        return 'Complete some tasks to see them here';
      default:
        return 'Add your first task to get started';
    }
  }
}
