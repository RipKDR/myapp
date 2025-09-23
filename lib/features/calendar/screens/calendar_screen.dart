import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/cards.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/empty_states.dart';

/// Calendar Screen
/// View and manage appointments
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Calendar',
      actions: [
        PopupMenuButton<String>(
          onSelected: (final value) => setState(() => _viewMode = value),
          itemBuilder: (final context) => [
            const PopupMenuItem(value: 'Month', child: Text('Month View')),
            const PopupMenuItem(value: 'Week', child: Text('Week View')),
            const PopupMenuItem(value: 'Day', child: Text('Day View')),
          ],
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: _addAppointment),
      ],
      body: Column(
        children: [
          _buildViewModeSelector(),
          _buildCalendarHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMonthView(), _buildWeekView(), _buildDayView()],
            ),
          ),
        ],
      ),
    );

  Widget _buildViewModeSelector() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Month', label: Text('Month')),
                ButtonSegment(value: 'Week', label: Text('Week')),
                ButtonSegment(value: 'Day', label: Text('Day')),
              ],
              selected: {_viewMode},
              onSelectionChanged: (final selection) {
                setState(() => _viewMode = selection.first);
                _tabController.animateTo(_getTabIndex(_viewMode));
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildCalendarHeader() => Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getMonthYear(_selectedDate),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousPeriod,
              ),
              TextButton(onPressed: _goToToday, child: const Text('Today')),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextPeriod,
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildMonthView() => _buildCalendarGrid();

  Widget _buildWeekView() => _buildWeekGrid();

  Widget _buildDayView() => _buildDaySchedule();

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
    );
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final firstDayOfWeek = firstDayOfMonth.weekday;

    final days = <Widget>[];

    // Add day headers
    final dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (final header in dayHeaders) {
      days.add(
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            header,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstDayOfWeek; i++) {
      days.add(const SizedBox());
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final hasAppointments = _hasAppointmentsOnDate(date);

      days.add(_buildCalendarDay(day, hasAppointments, date));
    }

    return GridView.count(crossAxisCount: 7, children: days);
  }

  Widget _buildWeekGrid() {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final days = <Widget>[];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final hasAppointments = _hasAppointmentsOnDate(date);

      days.add(_buildWeekDay(date, hasAppointments));
    }

    return ListView(children: days);
  }

  Widget _buildDaySchedule() {
    final appointments = _getAppointmentsForDate(_selectedDate);

    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today,
        title: 'No appointments',
        description: 'You have no appointments scheduled for this day.',
        action: PrimaryButton(
          text: 'Add Appointment',
          onPressed: _addAppointment,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (final context, final index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppointmentCard(
            title: appointment['title'],
            date: appointment['date'],
            time: appointment['time'],
            provider: appointment['provider'],
            location: appointment['location'],
            status: appointment['status'],
            onTap: () => _showAppointmentDetails(appointment),
          ),
        );
      },
    );
  }

  Widget _buildCalendarDay(final int day, final bool hasAppointments, final DateTime date) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);

    return InkWell(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
              ? theme.colorScheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : isToday
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (hasAppointments)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDay(final DateTime date, final bool hasAppointments) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);

    return InkWell(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDayName(date.weekday),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isToday
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (hasAppointments)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_getAppointmentsForDate(date).length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAppointmentsForDate(final DateTime date) {
    // Mock appointments data
    final allAppointments = [
      {
        'title': 'Physiotherapy Session',
        'date': DateTime.now().add(const Duration(days: 1)),
        'time': '10:00 AM',
        'provider': 'Dr. Sarah Johnson',
        'location': 'ABC Physiotherapy',
        'status': AppointmentStatus.scheduled,
      },
      {
        'title': 'Plan Review Meeting',
        'date': DateTime.now().add(const Duration(days: 3)),
        'time': '2:00 PM',
        'provider': 'NDIS Planner',
        'location': 'Online Meeting',
        'status': AppointmentStatus.scheduled,
      },
      {
        'title': 'Occupational Therapy',
        'date': DateTime.now().add(const Duration(days: 5)),
        'time': '11:30 AM',
        'provider': 'Emma Davis',
        'location': 'XYZ OT Clinic',
        'status': AppointmentStatus.scheduled,
      },
    ];

    return allAppointments
        .where((final apt) => _isSameDay(apt['date'] as DateTime, date))
        .toList();
  }

  bool _hasAppointmentsOnDate(final DateTime date) => _getAppointmentsForDate(date).isNotEmpty;

  bool _isSameDay(final DateTime date1, final DateTime date2) => date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;

  String _getMonthYear(final DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDayName(final int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  int _getTabIndex(final String viewMode) {
    switch (viewMode) {
      case 'Month':
        return 0;
      case 'Week':
        return 1;
      case 'Day':
        return 2;
      default:
        return 0;
    }
  }

  void _previousPeriod() {
    setState(() {
      switch (_viewMode) {
        case 'Month':
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
          break;
        case 'Week':
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case 'Day':
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (_viewMode) {
        case 'Month':
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
          break;
        case 'Week':
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case 'Day':
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
      }
    });
  }

  void _goToToday() {
    setState(() => _selectedDate = DateTime.now());
  }

  void _addAppointment() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Add Appointment'),
        content: const Text('Add new appointment feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(final Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(appointment['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${appointment['date'].day}/${appointment['date'].month}/${appointment['date'].year}',
            ),
            Text('Time: ${appointment['time']}'),
            Text('Provider: ${appointment['provider']}'),
            Text('Location: ${appointment['location']}'),
            Text('Status: ${appointment['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
