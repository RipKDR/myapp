import 'package:flutter/material.dart';
import '../models/circle.dart';
import '../repositories/circle_repository.dart';
import '../services/e2e_service.dart';
import 'dart:async';

class SupportCircleScreen extends StatefulWidget {
  const SupportCircleScreen({super.key});
  @override
  State<SupportCircleScreen> createState() => _SupportCircleScreenState();
}

class _SupportCircleScreenState extends State<SupportCircleScreen> {
  final _todo = <GoalCard>[];
  final _doing = <GoalCard>[];
  final _done = <GoalCard>[];
  final _messages = <CircleMessage>[];
  final _msgCtrl = TextEditingController();
  StreamSubscription<List<GoalCard>>? _gSub;
  StreamSubscription<List<CircleMessage>>? _mSub;
  bool _e2eReady = false;

  @override
  void initState() {
    super.initState();
    _seed();
    _subscribe();
  }

  void _seed() {
    _todo.addAll([
      const GoalCard(id: 'g1', title: 'Book OT assessment', status: 'Todo'),
      const GoalCard(id: 'g2', title: 'Compare support worker rates', status: 'Todo'),
    ]);
    _messages.addAll([
      CircleMessage(id: 'm1', authorId: 'p', text: 'Welcome to the support circle!', sentAt: DateTime.now()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support Circle'),
          bottom: const TabBar(tabs: [Tab(text: 'Goals'), Tab(text: 'Messages')]),
          actions: [
            IconButton(
              tooltip: _e2eReady ? 'Change passphrase' : 'Set secret passphrase',
              icon: Icon(_e2eReady ? Icons.lock_open : Icons.lock_outline),
              onPressed: _setPassphrase,
            )
          ],
        ),
        body: TabBarView(children: [
          _board(),
          _chat(),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addGoal(context),
          icon: const Icon(Icons.add),
          label: const Text('Add goal'),
        ),
      ),
    );
  }

  void _subscribe() async {
    _e2eReady = await E2EService.hasKey();
    _gSub = CircleRepository.streamGoals('default').listen((goals) {
      if (!mounted || goals.isEmpty) return;
      setState(() {
        _todo
          ..clear()
          ..addAll(goals.where((g) => g.status == 'Todo'));
        _doing
          ..clear()
          ..addAll(goals.where((g) => g.status == 'Doing'));
        _done
          ..clear()
          ..addAll(goals.where((g) => g.status == 'Done'));
      });
    });
    _mSub = CircleRepository.streamMessages('default').listen((msgs) async {
      if (!mounted || msgs.isEmpty) return;
      final decrypted = <CircleMessage>[];
      for (final m in msgs) {
        if (m.encrypted && m.payload != null) {
          final text = await E2EService.decrypt(m.payload!);
          decrypted.add(CircleMessage(
            id: m.id,
            authorId: m.authorId,
            text: text ?? '[Encrypted]',
            sentAt: m.sentAt,
            encrypted: m.encrypted,
            payload: m.payload,
          ));
        } else {
          decrypted.add(m);
        }
      }
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(decrypted);
      });
    });
    setState(() {});
  }

  @override
  void dispose() {
    _gSub?.cancel();
    _mSub?.cancel();
    super.dispose();
  }

  Widget _board() {
    return Row(
      children: [
        Expanded(child: _column('Todo', _todo)),
        Expanded(child: _column('Doing', _doing)),
        Expanded(child: _column('Done', _done)),
      ],
    );
  }

  Widget _column(String title, List<GoalCard> items) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DragTarget<GoalCard>(
        onAcceptWithDetails: (details) => setState(() {
          final g = details.data;
          _removeFromAll(g);
          items.add(GoalCard(id: g.id, title: g.title, status: title));
        }),
        builder: (context, _, __) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('${items.length}')
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: items
                          .map((g) => LongPressDraggable<GoalCard>(
                                data: g,
                                feedback: _goalChip(g),
                                child: _goalTile(g),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _goalTile(GoalCard g) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: _goalChip(g),
    );
  }

  Widget _goalChip(GoalCard g) {
    return Chip(
      label: Text(g.title),
      avatar: const Icon(Icons.drag_indicator),
      deleteIcon: const Icon(Icons.check_circle_outline),
      onDeleted: () => setState(() {
        _removeFromAll(g);
        _done.add(GoalCard(id: g.id, title: g.title, status: 'Done'));
      }),
    );
  }

  void _removeFromAll(GoalCard g) {
    _todo.removeWhere((x) => x.id == g.id);
    _doing.removeWhere((x) => x.id == g.id);
    _done.removeWhere((x) => x.id == g.id);
  }

  Widget _chat() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: _messages
                .map((m) => Align(
                      alignment: m.authorId == 'p' ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: m.authorId == 'p' ? Colors.teal.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(m.text),
                      ),
                    ))
                .toList(),
          ),
        ),
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: const InputDecoration(hintText: 'Message the circle'),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(onPressed: _send, icon: const Icon(Icons.send))
            ],
          ),
        )
      ],
    );
  }

  void _addGoal(BuildContext context) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New goal'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'e.g., Book physio')), 
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Add'))],
      ),
    );
    if (text == null || text.isEmpty) return;
    final g = GoalCard(id: DateTime.now().millisecondsSinceEpoch.toString(), title: text, status: 'Todo');
    setState(() => _todo.add(g));
    CircleRepository.saveGoal('default', g);
  }

  void _send() {
    final t = _msgCtrl.text.trim();
    if (t.isEmpty) return;
    final m = CircleMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), authorId: 'p', text: t, sentAt: DateTime.now());
    setState(() {
      _messages.add(m);
      _msgCtrl.clear();
    });
    if (_e2eReady) {
      E2EService.encrypt(t).then((payload) {
        CircleRepository.saveEncryptedMessage('default', m, payload);
      });
    } else {
      CircleRepository.saveMessage('default', m);
    }
  }

  Future<void> _setPassphrase() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set circle passphrase'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter a secret passphrase'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await E2EService.setPassphrase(ctrl.text.trim());
      _e2eReady = true;
      if (mounted) setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passphrase set. Messages will be encrypted.')));
    }
  }
}
