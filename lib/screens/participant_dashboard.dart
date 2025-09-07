import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../widgets/icon_card.dart';
import '../widgets/budget_pie.dart';
import '../models/budget.dart';
import '../models/appointment.dart';
import '../controllers/settings_controller.dart';
import '../controllers/gamification_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/hero_banner.dart';
import '../widgets/confetti_banner.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/budget_repository.dart';

class ParticipantDashboardScreen extends StatelessWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final settings = context.watch<SettingsController>();
    final auth = context.watch<AuthController>();
    final dateFmt = DateFormat('EEE d MMM, h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDIS Connect'),
        actions: [
          IconButton(
            tooltip: 'Settings & Accessibility',
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_accessibility),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ConfettiBanner(),
          const HeroBanner(
            title: 'Welcome back',
            subtitle: 'Your week at a glance',
          ),
          const SizedBox(height: 12),
          IconCard(
            icon: Icons.event_available,
            label: 'Book or view sessions',
            onTap: () => Navigator.pushNamed(context, Routes.calendar),
          ),
          IconCard(
            icon: Icons.account_balance_wallet,
            label: 'Track your budget',
            onTap: () => Navigator.pushNamed(context, Routes.budget),
          ),
          IconCard(
            icon: Icons.chat_bubble_outline,
            label: 'Ask NDIS Assistant',
            onTap: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconCard(
            icon: Icons.map_outlined,
            label: 'Find services near you',
            onTap: () => Navigator.pushNamed(context, '/map'),
          ),
          IconCard(
            icon: Icons.checklist_rtl,
            label: 'Smart Plan Checklist',
            onTap: () => Navigator.pushNamed(context, '/checklist'),
          ),
          IconCard(
            icon: Icons.timeline,
            label: 'Plan Progress Snapshot',
            onTap: () => Navigator.pushNamed(context, '/snapshot'),
          ),
          IconCard(
            icon: Icons.people_outline,
            label: 'Support Circle',
            onTap: () => Navigator.pushNamed(context, '/circle'),
          ),
          const SizedBox(height: 8),
          // Budget snapshot
          if (auth.userId != null)
            StreamBuilder<BudgetOverview?>(
              stream: BudgetRepository.streamForUser(auth.userId!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final budget = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget snapshot',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          BudgetPieChart(data: budget),
                          const SizedBox(height: 8),
                          Text(
                            'Total allocated: \$${budget.totalAllocated.toStringAsFixed(0)}',
                          ),
                          Text(
                            'Total spent: \$${budget.totalSpent.toStringAsFixed(0)}',
                          ),
                          Text(
                            'Remaining: \$${(budget.totalAllocated - budget.totalSpent).toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget snapshot',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text('No budget data available'),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, Routes.budget),
                            child: const Text('Set up your budget'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget snapshot',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    BudgetPieChart(data: _mockBudget()),
                    const SizedBox(height: 8),
                    const Text('Demo budget data'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Upcoming appointments
          if (auth.userId != null)
            StreamBuilder<List<Appointment>>(
              stream: AppointmentRepository.getUpcoming(auth.userId!, limit: 3),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final appointments = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule),
                              const SizedBox(width: 8),
                              Text(
                                'Upcoming sessions',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final a in appointments)
                            ListTile(
                              leading: const Icon(Icons.event),
                              title: Text(a.title),
                              subtitle: Text(
                                '${a.providerName} • ${dateFmt.format(a.start)}',
                              ),
                              trailing: a.confirmed
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : const Icon(
                                      Icons.hourglass_bottom,
                                      color: Colors.orange,
                                    ),
                            ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, Routes.calendar),
                            child: const Text('View calendar'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule),
                              const SizedBox(width: 8),
                              Text(
                                'Upcoming sessions',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('No upcoming appointments'),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, Routes.calendar),
                            child: const Text('Book a session'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule),
                        const SizedBox(width: 8),
                        Text(
                          'Upcoming sessions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final a in _mockAppointments().take(3))
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(a.title),
                        subtitle: Text(
                          '${a.providerName} • ${dateFmt.format(a.start)}',
                        ),
                        trailing: a.confirmed
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.hourglass_bottom,
                                color: Colors.orange,
                              ),
                      ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.calendar),
                      child: const Text('View calendar'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            color: Colors.indigo.withValues(alpha: 0.08),
            child: const ListTile(
              leading: Icon(Icons.emoji_events_outlined),
              title: Text('NDIS Champion'),
              subtitle: _GamiSummary(),
            ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final settings = context.read<SettingsController>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accessibility & Appearance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Theme: '),
                  const SizedBox(width: 8),
                  DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (m) =>
                        m != null ? settings.setThemeMode(m) : null,
                  ),
                ],
              ),
              SwitchListTile(
                value: settings.highContrast,
                onChanged: settings.setHighContrast,
                title: const Text('High contrast'),
              ),
              SwitchListTile(
                value: settings.reduceMotion,
                onChanged: settings.setReduceMotion,
                title: const Text('Reduce motion (limit animations)'),
              ),
              Row(
                children: [
                  const Text('Text size'),
                  Expanded(
                    child: Slider(
                      min: 0.8,
                      max: 1.8,
                      value: settings.textScale,
                      onChanged: (v) => settings.setTextScale(v),
                    ),
                  ),
                  Text('${(settings.textScale * 100).round()}%'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GamiSummary extends StatelessWidget {
  const _GamiSummary();
  @override
  Widget build(BuildContext context) {
    final points = context.select<GamificationController, int>((g) => g.points);
    final streak = context.select<GamificationController, int>(
      (g) => g.streakDays,
    );
    return Text('Daily streak: $streak days • Points: $points');
  }
}

List<Appointment> _mockAppointments() {
  final now = DateTime.now();
  return [
    Appointment(
      id: '1',
      start: now.add(const Duration(days: 1, hours: 2)),
      end: now.add(const Duration(days: 1, hours: 3)),
      title: 'Physio session',
      providerName: 'FlexCare Physio',
      confirmed: true,
    ),
    Appointment(
      id: '2',
      start: now.add(const Duration(days: 3, hours: 1)),
      end: now.add(const Duration(days: 3, hours: 2)),
      title: 'OT assessment',
      providerName: 'Ability OT',
    ),
    Appointment(
      id: '3',
      start: now.add(const Duration(days: 7, hours: 4)),
      end: now.add(const Duration(days: 7, hours: 5)),
      title: 'Support worker visit',
      providerName: 'CareCo',
      confirmed: true,
    ),
  ];
}

BudgetOverview _mockBudget() {
  return const BudgetOverview([
    BudgetBucket(name: 'Core', allocated: 12000, spent: 9600),
    BudgetBucket(name: 'Capacity', allocated: 8000, spent: 4200),
    BudgetBucket(name: 'Capital', allocated: 5000, spent: 1000),
  ]);
}
