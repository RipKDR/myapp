import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../widgets/budget_pie.dart';
import '../widgets/modern_dashboard_card.dart';
import '../widgets/modern_dashboard_layout.dart';
import '../widgets/google_dashboard_header.dart';
import '../models/budget.dart';
import '../models/appointment.dart';
import '../controllers/auth_controller.dart';
import '../widgets/confetti_banner.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/budget_repository.dart';
import '../theme/google_theme.dart';
import '../widgets/enhanced_settings_sheet.dart';
import '../services/enhanced_voice_service.dart';
import '../utils/haptic_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/compact_infographics.dart';

class ParticipantDashboardScreen extends StatelessWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dateFmt = DateFormat('EEE d MMM, h:mm a');

    return ModernDashboardLayout(
      title: 'Welcome back',
      subtitle: 'Your NDIS journey at a glance',
      actions: [
        IconButton(
          tooltip: 'Settings & Accessibility',
          onPressed: () => _openSettings(context),
          icon: const Icon(Icons.settings_accessibility),
        ),
      ],
      floatingActionButton: VoiceCommandButton(
        onCommand: (command) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice command: $command')),
          );
        },
        prompt: 'How can I help you with your NDIS plan today?',
        tooltip: 'Voice Commands',
      ),
      header: Column(
        children: [
          const ConfettiBanner(),
          GoogleDashboardHeader(
            greeting: 'there',
            subtitle: 'Your NDIS journey continues',
            showStats: true,
            onProfileTap: () => _openSettings(context),
            actions: [
              IconButton(
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
      children: [
        // Core Services
        InteractiveCard(
          onTap: () => Navigator.pushNamed(context, Routes.calendar),
          child: ModernDashboardCard(
            icon: Icons.event_available,
            title: 'Book Sessions',
            subtitle: 'Schedule appointments and manage your calendar',
            value: 'Next: Tomorrow 2PM',
            iconColor: AppTheme.calmingBlue,
            onTap: () => Navigator.pushNamed(context, Routes.calendar),
            actions: [
              QuickActionButton(
                icon: Icons.add,
                label: 'Book Now',
                onPressed: () => Navigator.pushNamed(context, Routes.calendar),
              ),
            ],
          ),
        ),

        ModernDashboardCard(
          icon: Icons.account_balance_wallet,
          title: 'Budget Tracker',
          subtitle: 'Monitor spending and plan your NDIS funds',
          value: auth.userId != null ? null : '\$18,400 remaining',
          iconColor: GoogleTheme.ndisGreen,
          showTrend: true,
          trend: '12% left',
          trendDirection: TrendDirection.down,
          onTap: () => Navigator.pushNamed(context, Routes.budget),
          actions: [
            QuickActionButton(
              icon: Icons.receipt,
              label: 'Add Receipt',
              onPressed: () => Navigator.pushNamed(context, Routes.budget),
            ),
          ],
        ),

        ModernDashboardCard(
          icon: Icons.chat_bubble_outline,
          title: 'NDIS Assistant',
          subtitle: 'Get instant help with NDIS questions',
          value: 'AI Powered',
          iconColor: GoogleTheme.ndisTeal,
          onTap: () => Navigator.pushNamed(context, '/chat'),
          actions: [
            QuickActionButton(
              icon: Icons.mic,
              label: 'Voice Chat',
              onPressed: () => Navigator.pushNamed(context, '/chat'),
            ),
          ],
        ),

        ModernDashboardCard(
          icon: Icons.checklist_rtl,
          title: 'Plan Checklist',
          subtitle: 'Track your goals and milestones',
          value: '8/12 Complete',
          iconColor: GoogleTheme.ndisOrange,
          showTrend: true,
          trend: '67%',
          trendDirection: TrendDirection.up,
          onTap: () => Navigator.pushNamed(context, '/checklist'),
          actions: [
            QuickActionButton(
              icon: Icons.check,
              label: 'Mark Done',
              onPressed: () => Navigator.pushNamed(context, '/checklist'),
            ),
          ],
        ),

        ModernDashboardCard(
          icon: Icons.timeline,
          title: 'Progress Report',
          subtitle: 'View your progress and export reports',
          value: 'Last updated today',
          iconColor: GoogleTheme.ndisPurple,
          onTap: () => Navigator.pushNamed(context, '/snapshot'),
          actions: [
            QuickActionButton(
              icon: Icons.download,
              label: 'Export PDF',
              onPressed: () => Navigator.pushNamed(context, '/snapshot'),
            ),
          ],
        ),

        ModernDashboardCard(
          icon: Icons.people_outline,
          title: 'Support Circle',
          subtitle: 'Connect with your support team',
          value: '5 Members',
          iconColor: GoogleTheme.ndisTeal,
          onTap: () => Navigator.pushNamed(context, '/circle'),
          actions: [
            QuickActionButton(
              icon: Icons.message,
              label: 'Message',
              onPressed: () => Navigator.pushNamed(context, '/circle'),
            ),
          ],
        ),

        ModernDashboardCard(
          icon: Icons.map_outlined,
          title: 'Find Services',
          subtitle: 'Discover local NDIS providers',
          value: '24 nearby',
          iconColor: GoogleTheme.ndisGreen,
          onTap: () => Navigator.pushNamed(context, '/map'),
          actions: [
            QuickActionButton(
              icon: Icons.search,
              label: 'Search',
              onPressed: () => Navigator.pushNamed(context, '/map'),
            ),
          ],
        ),

        // Budget Overview Card
        _buildBudgetOverviewCard(context, auth),

        // Appointments Card
        _buildAppointmentsCard(context, auth, dateFmt),

        // Compact professional infographics (minimal, tasteful)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CompactTimeline(
            entries: const [
              TimelineEntry(
                title: 'Receipt Uploaded',
                subtitle: 'Budget • Core Supports',
                trailing: 'Today',
                color: AppTheme.ndisGreen,
              ),
              TimelineEntry(
                title: 'Session Confirmed',
                subtitle: 'Calendar • Physio Tomorrow 2PM',
                trailing: '1h ago',
                color: AppTheme.ndisBlue,
              ),
              TimelineEntry(
                title: 'Goal Progress',
                subtitle: 'Checklist • Mobility 67%',
                trailing: 'Today',
                color: AppTheme.ndisPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetOverviewCard(BuildContext context, AuthController auth) {
    if (auth.userId != null) {
      return StreamBuilder<BudgetOverview?>(
        stream: BudgetRepository.streamForUser(auth.userId!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final budget = snapshot.data!;
            final remaining = budget.totalAllocated - budget.totalSpent;
            final percentUsed =
                (budget.totalSpent / budget.totalAllocated * 100);

            return ModernDashboardCard(
              icon: Icons.pie_chart,
              title: 'Budget Overview',
              subtitle: 'Your NDIS funding breakdown',
              value: '\$${remaining.toStringAsFixed(0)} left',
              iconColor: GoogleTheme.ndisGreen,
              showTrend: true,
              trend: '${(100 - percentUsed).toStringAsFixed(0)}%',
              trendDirection:
                  percentUsed > 80 ? TrendDirection.down : TrendDirection.up,
              onTap: () => Navigator.pushNamed(context, Routes.budget),
              trailing: SizedBox(
                width: 60,
                height: 60,
                child: BudgetPieChart(data: budget),
              ),
            );
          } else {
            return ModernDashboardCard(
              icon: Icons.pie_chart,
              title: 'Budget Overview',
              subtitle: 'Set up your NDIS budget tracking',
              value: 'Not configured',
              iconColor: GoogleTheme.ndisGreen,
              onTap: () => Navigator.pushNamed(context, Routes.budget),
              actions: [
                QuickActionButton(
                  icon: Icons.add,
                  label: 'Set Up',
                  onPressed: () => Navigator.pushNamed(context, Routes.budget),
                ),
              ],
            );
          }
        },
      );
    } else {
      final budget = _mockBudget();
      final remaining = budget.totalAllocated - budget.totalSpent;

      return ModernDashboardCard(
        icon: Icons.pie_chart,
        title: 'Budget Overview',
        subtitle: 'Demo budget data',
        value: '\$${remaining.toStringAsFixed(0)} left',
        iconColor: GoogleTheme.ndisGreen,
        showTrend: true,
        trend: '73%',
        trendDirection: TrendDirection.up,
        onTap: () => Navigator.pushNamed(context, Routes.budget),
        trailing: SizedBox(
          width: 60,
          height: 60,
          child: BudgetPieChart(data: budget),
        ),
      );
    }
  }

  Widget _buildAppointmentsCard(
      BuildContext context, AuthController auth, DateFormat dateFmt) {
    if (auth.userId != null) {
      return StreamBuilder<List<Appointment>>(
        stream: AppointmentRepository.getUpcoming(auth.userId!, limit: 3),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final appointments = snapshot.data!;
            final nextAppointment = appointments.first;

            return ModernDashboardCard(
              icon: Icons.schedule,
              title: 'Upcoming Sessions',
              subtitle: '${appointments.length} sessions scheduled',
              value: 'Next: ${dateFmt.format(nextAppointment.start)}',
              iconColor: GoogleTheme.ndisBlue,
              onTap: () => Navigator.pushNamed(context, Routes.calendar),
              actions: [
                QuickActionButton(
                  icon: Icons.calendar_today,
                  label: 'View All',
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.calendar),
                ),
              ],
            );
          } else {
            return ModernDashboardCard(
              icon: Icons.schedule,
              title: 'Upcoming Sessions',
              subtitle: 'No sessions scheduled',
              value: 'Book your first session',
              iconColor: GoogleTheme.ndisBlue,
              onTap: () => Navigator.pushNamed(context, Routes.calendar),
              actions: [
                QuickActionButton(
                  icon: Icons.add,
                  label: 'Book Now',
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.calendar),
                ),
              ],
            );
          }
        },
      );
    } else {
      final appointments = _mockAppointments();
      final nextAppointment = appointments.first;

      return ModernDashboardCard(
        icon: Icons.schedule,
        title: 'Upcoming Sessions',
        subtitle: '${appointments.length} sessions scheduled',
        value: 'Next: ${dateFmt.format(nextAppointment.start)}',
        iconColor: GoogleTheme.ndisBlue,
        onTap: () => Navigator.pushNamed(context, Routes.calendar),
        actions: [
          QuickActionButton(
            icon: Icons.calendar_today,
            label: 'View All',
            onPressed: () => Navigator.pushNamed(context, Routes.calendar),
          ),
        ],
      );
    }
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnhancedSettingsSheet(),
    );
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
