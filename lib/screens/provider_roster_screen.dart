import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/shift_repository.dart';
import '../models/shift.dart';
import '../services/compliance_service.dart';

class ProviderRosterScreen extends StatefulWidget {
  const ProviderRosterScreen({super.key});
  @override
  State<ProviderRosterScreen> createState() => _ProviderRosterScreenState();
}

class _ProviderRosterScreenState extends State<ProviderRosterScreen> {
  final _shifts = <Shift>[];
  StreamSubscription<List<Shift>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ShiftRepository.stream().listen((final cloud) {
      if (!mounted || cloud.isEmpty) return;
      setState(() {
        _shifts
          ..clear()
          ..addAll(cloud);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final score = ComplianceService.score(_shifts);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster & Compliance'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: Text('Compliance $score%')),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _ComplianceBar(score: score),
          const SizedBox(height: 8),
          for (final s in _shifts)
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text('${s.staff} — ${s.participant}'),
                subtitle: Text('${s.start} - ${s.end}'),
                trailing: Icon(
                  s.confirmed ? Icons.verified : Icons.error_outline,
                  color: s.confirmed ? Colors.green : Colors.orange,
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addShift,
        icon: const Icon(Icons.add),
        label: const Text('Add shift'),
      ),
    );
  }

  Future<void> _addShift() async {
    final staffCtrl = TextEditingController();
    final partCtrl = TextEditingController();
    DateTime start = DateTime.now().add(const Duration(hours: 1));
    DateTime end = start.add(const Duration(hours: 1));
    final s = await showDialog<Shift>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('New shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: staffCtrl,
              decoration: const InputDecoration(labelText: 'Staff name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: partCtrl,
              decoration: const InputDecoration(labelText: 'Participant'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: DateTime.now(),
                      );
                      if (d != null) {
                        start = DateTime(d.year, d.month, d.day, start.hour, start.minute);
                      }
                    },
                    child: const Text('Pick date'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(start),
                      );
                      if (t != null) {
                        start = DateTime(start.year, start.month, start.day, t.hour, t.minute);
                      }
                    },
                    child: const Text('Start'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(end),
                      );
                      if (t != null) {
                        end = DateTime(start.year, start.month, start.day, t.hour, t.minute);
                      }
                    },
                    child: const Text('End'),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (staffCtrl.text.isNotEmpty && partCtrl.text.isNotEmpty) {
                Navigator.pop(
                  context,
                  Shift(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    staff: staffCtrl.text.trim(),
                    start: start,
                    end: end,
                    participant: partCtrl.text.trim(),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (s == null) return;
    await ShiftRepository.save(s);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift saved')));
    }
  }
}

class _ComplianceBar extends StatelessWidget {
  const _ComplianceBar({required this.score});
  final int score;
  @override
  Widget build(final BuildContext context) {
    final pct = score / 100;
    final color = score >= 90
        ? Colors.green
        : score >= 70
            ? Colors.orange
            : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.verified_user), SizedBox(width: 8), Text('Compliance')]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pct, color: color),
            const SizedBox(height: 6),
            Text('$score% • Resolve overlaps and confirm shifts')
          ],
        ),
      ),
    );
  }
}

