import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../controllers/gamification_controller.dart';
import '../controllers/auth_controller.dart';
import '../repositories/appointment_repository.dart';
import '../services/notifications_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  final List<Appointment> _items = _mockAppointments();
  StreamSubscription<List<Appointment>>? _sub;

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_month);
    final firstWeekday = _month.weekday % 7; // 0=Sun, 6=Sat
    final cells = List<DateTime?>.generate(
      firstWeekday + days,
      (i) => i < firstWeekday ? null : DateTime(_month.year, _month.month, i - firstWeekday + 1),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scheduling'),
        actions: [
          IconButton(
            tooltip: 'This month',
            onPressed: () => setState(() => _month = DateTime(DateTime.now().year, DateTime.now().month)),
            icon: const Icon(Icons.today),
          )
        ],
      ),
      body: Column(
        children: [
          _CalendarHeader(
            month: _month,
            onPrev: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
            onNext: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
          ),
          _WeekdayRow(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                final date = cells[index];
                return _DayCell(
                  date: date,
                  items: date == null
                      ? const []
                      : _items.where((a) => _sameDay(a.start, date)).toList(),
                  onTap: date == null ? null : () => _showDayActions(context, date),
                );
              },
            ),
          ),
          _LegendBar(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _sub = AppointmentRepository.stream().listen((list) {
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(list.isEmpty ? _items : list);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _showDayActions(BuildContext context, DateTime date) async {
    final timeFmt = DateFormat('h:mm a');
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final slots = List.generate(6, (i) => DateTime(date.year, date.month, date.day, 9 + i));
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ListTile(
                title: Text(DateFormat('EEEE d MMM').format(date)),
                subtitle: const Text('Tap a time to book'),
              ),
              for (final s in slots)
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(timeFmt.format(s)),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    setState(() {
                      _items.add(Appointment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        start: s,
                        end: s.add(const Duration(hours: 1)),
                        title: 'Session',
                        providerName: 'TBD',
                        confirmed: false,
                      ));
                    });
                    // Attempt to persist online (safe no-op if offline)
                    final a = _items.last;
                    AppointmentRepository.save(a);
                    // Schedule reminder 1 hour before
                    NotificationsService.scheduleAt(
                      a.start.subtract(const Duration(hours: 1)),
                      id: a.hashCode,
                      title: 'Upcoming session',
                      body: '${a.title} at ${timeFmt.format(a.start)}',
                    );
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    final g = context.read<GamificationController>();
                    g.addPoints(5);
                    g.bumpStreak();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booked! +5 points.')),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _CalendarHeader({required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Center(
              child: Text(DateFormat.yMMMM().format(month), style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  final days = const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  @override
  Widget build(BuildContext context) {
    return Row(
      children: days
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Center(child: Text(d, semanticsLabel: d)),
                ),
              ))
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime? date;
  final List<Appointment> items;
  final VoidCallback? onTap;
  const _DayCell({required this.date, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();
    final isToday = _sameDay(date!, DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Day ${date!.day} with ${items.length} items',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: isToday ? scheme.primary : scheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${date!.day}', style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
              ...items.take(2).map((a) => Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: a.confirmed ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
                        child: Text(
                          a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

int _daysInMonth(DateTime month) => DateTime(month.year, month.month + 1, 0).day;
bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

List<Appointment> _mockAppointments() {
  final now = DateTime.now();
  return [
    Appointment(
      id: '1',
      start: now.add(const Duration(days: 1, hours: 2)),
      end: now.add(const Duration(days: 1, hours: 3)),
      title: 'Physio',
      providerName: 'FlexCare Physio',
      confirmed: true,
    ),
  ];
}
