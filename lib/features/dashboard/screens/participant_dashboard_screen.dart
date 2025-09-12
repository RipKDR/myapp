import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/cards.dart';
import '../../../ui/components/navigation.dart';
import '../../../app/router.dart';

/// Participant Dashboard Screen
/// Main hub for NDIS participants
class ParticipantDashboardScreen extends StatefulWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  State<ParticipantDashboardScreen> createState() =>
      _ParticipantDashboardScreenState();
}

class _ParticipantDashboardScreenState
    extends State<ParticipantDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Dashboard',
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: context.pushMessages,
        icon: Icons.message,
        tooltip: 'New Message',
      ),
    );

  Widget _buildBody() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildBudgetOverview(),
          const SizedBox(height: 24),
          _buildUpcomingAppointments(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, Sarah!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your NDIS plan overview',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.account_balance_wallet,
                title: 'View Budget',
                onTap: () => context.pushBudgets(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt,
                title: 'Submit Claim',
                onTap: () => context.pushClaims(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.location_on,
                title: 'Find Services',
                onTap: () => context.pushServices(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.people,
                title: 'Support Circle',
                onTap: () => context.pushSupport(),
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildBudgetOverview() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.pushBudgets(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BudgetProgressCard(
          title: 'Core Supports',
          amount: 15000,
          spent: 8500,
          remaining: 6500,
          category: 'Core',
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.pushBudgets(),
        ),
        const SizedBox(height: 12),
        BudgetProgressCard(
          title: 'Capacity Building',
          amount: 8000,
          spent: 3200,
          remaining: 4800,
          category: 'Capacity',
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.pushBudgets(),
        ),
      ],
    );

  Widget _buildUpcomingAppointments() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.pushCalendar(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppointmentCard(
          title: 'Physiotherapy Session',
          date: DateTime.now().add(const Duration(days: 2)),
          time: '10:00 AM',
          provider: 'ABC Physiotherapy',
          location: '123 Health St, Melbourne',
          onTap: () => context.pushCalendar(),
        ),
        const SizedBox(height: 12),
        AppointmentCard(
          title: 'Plan Review Meeting',
          date: DateTime.now().add(const Duration(days: 7)),
          time: '2:00 PM',
          provider: 'NDIS Planner',
          location: 'Online Meeting',
          onTap: () => context.pushCalendar(),
        ),
      ],
    );

  Widget _buildRecentActivity() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const _ActivityItem(
          icon: Icons.receipt,
          title: 'Claim submitted',
          subtitle: r'Physiotherapy - $150',
          time: '2 hours ago',
        ),
        const SizedBox(height: 12),
        const _ActivityItem(
          icon: Icons.message,
          title: 'New message',
          subtitle: 'From ABC Physiotherapy',
          time: '1 day ago',
        ),
        const SizedBox(height: 12),
        const _ActivityItem(
          icon: Icons.calendar_today,
          title: 'Appointment confirmed',
          subtitle: 'Occupational Therapy - Tomorrow',
          time: '2 days ago',
        ),
      ],
    );

  void _onNavigationTap(final int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        context.pushBudgets();
        break;
      case 2:
        context.pushCalendar();
        break;
      case 3:
        context.pushMessages();
        break;
      case 4:
        context.pushSettings();
        break;
    }
  }
}

/// Quick Action Card
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Item
class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
