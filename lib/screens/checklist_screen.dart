import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../controllers/gamification_controller.dart';
import '../repositories/task_repository.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});
  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _tasks = <PlanTask>[
    const PlanTask(id: 't1', title: 'Book session with physio', priority: 1),
    const PlanTask(id: 't2', title: 'Upload last invoice', priority: 2),
    const PlanTask(id: 't3', title: 'Check Core budget', priority: 1),
  ];

  @override
  void initState() {
    super.initState();
    TaskRepository.stream().listen((cloud) {
      if (!mounted || cloud.isEmpty) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(cloud);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Plan Checklist')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final t in _tasks)
            Card(
              child: CheckboxListTile(
                value: t.done,
                onChanged: (_) => setState(() => _toggle(t)),
                title: Text(t.title),
                secondary: _prioIcon(t.priority),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addTask, child: const Icon(Icons.add_task)),
    );
  }

  void _toggle(PlanTask t) {
    final i = _tasks.indexWhere((x) => x.id == t.id);
    _tasks[i] = t.toggle();
    if (_tasks[i].done) {
      context.read<GamificationController>().addPoints(2);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great job! +2 points earned')));
    }
  }

  Future<void> _addTask() async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add task'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'e.g., Book session')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Add'))],
      ),
    );
    if (text == null || text.isEmpty) return;
    final t = PlanTask(id: DateTime.now().millisecondsSinceEpoch.toString(), title: text, priority: 2);
    setState(() => _tasks.add(t));
    TaskRepository.save(t);
  }

  Widget _prioIcon(int p) {
    switch (p) {
      case 1:
        return const Icon(Icons.priority_high, color: Colors.red);
      case 3:
        return const Icon(Icons.low_priority, color: Colors.grey);
      default:
        return const Icon(Icons.flag, color: Colors.orange);
    }
  }
}
