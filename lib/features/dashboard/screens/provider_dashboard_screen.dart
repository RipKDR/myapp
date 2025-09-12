import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/cards.dart';
import '../../../ui/components/navigation.dart';
import '../../../app/router.dart';

/// Provider Dashboard Screen
/// Main hub for NDIS providers
class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Provider Dashboard',
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
        items: const [
          AppNavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
          AppNavigationItem(icon: Icons.people, label: 'Clients'),
          AppNavigationItem(icon: Icons.calendar_today, label: 'Schedule'),
          AppNavigationItem(icon: Icons.message, label: 'Messages'),
          AppNavigationItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: _showNewAppointmentDialog,
        tooltip: 'New Appointment',
      ),
    );

  Widget _buildBody() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildTodaySchedule(),
          const SizedBox(height: 24),
          _buildRecentClients(),
          const SizedBox(height: 24),
          _buildRecentMessages(),
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
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withValues(alpha: 0.8),
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
            'Good morning, Dr. Smith!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have 3 appointments today',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Active Clients',
                value: '24',
                icon: Icons.people,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'This Week',
                value: '18',
                icon: Icons.calendar_today,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Pending Claims',
                value: '7',
                icon: Icons.pending,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Messages',
                value: '5',
                icon: Icons.message,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildTodaySchedule() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Schedule',
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
          title: 'Physiotherapy - Sarah Johnson',
          date: DateTime.now(),
          time: '9:00 AM',
          provider: 'Dr. Smith',
          location: 'Clinic Room 1',
          onTap: () => context.pushCalendar(),
        ),
        const SizedBox(height: 12),
        AppointmentCard(
          title: 'Assessment - Mike Wilson',
          date: DateTime.now(),
          time: '11:30 AM',
          provider: 'Dr. Smith',
          location: 'Clinic Room 2',
          onTap: () => context.pushCalendar(),
        ),
        const SizedBox(height: 12),
        AppointmentCard(
          title: 'Follow-up - Emma Davis',
          date: DateTime.now(),
          time: '2:00 PM',
          provider: 'Dr. Smith',
          location: 'Clinic Room 1',
          onTap: () => context.pushCalendar(),
        ),
      ],
    );

  Widget _buildRecentClients() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Clients',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: _showClientsList,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ClientItem(
          name: 'Sarah Johnson',
          lastVisit: '2 days ago',
          nextAppointment: 'Today 9:00 AM',
          onTap: () => _showClientDetails('Sarah Johnson'),
        ),
        const SizedBox(height: 12),
        _ClientItem(
          name: 'Mike Wilson',
          lastVisit: '1 week ago',
          nextAppointment: 'Today 11:30 AM',
          onTap: () => _showClientDetails('Mike Wilson'),
        ),
        const SizedBox(height: 12),
        _ClientItem(
          name: 'Emma Davis',
          lastVisit: '3 days ago',
          nextAppointment: 'Today 2:00 PM',
          onTap: () => _showClientDetails('Emma Davis'),
        ),
      ],
    );

  Widget _buildRecentMessages() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Messages',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.pushMessages(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MessageItem(
          sender: 'Sarah Johnson',
          message: 'Thank you for the session today!',
          time: '1 hour ago',
          isUnread: true,
          onTap: () => context.pushMessages(),
        ),
        const SizedBox(height: 12),
        _MessageItem(
          sender: 'Mike Wilson',
          message: 'Can we reschedule tomorrow\'s appointment?',
          time: '3 hours ago',
          isUnread: true,
          onTap: () => context.pushMessages(),
        ),
        const SizedBox(height: 12),
        _MessageItem(
          sender: 'Emma Davis',
          message: 'I have a question about my treatment plan',
          time: '1 day ago',
          isUnread: false,
          onTap: () => context.pushMessages(),
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
        _showClientsList();
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

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('New Appointment'),
        content: const Text('This feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClientsList() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Client List'),
        content: const Text('Client management feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClientDetails(final String clientName) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text('$clientName Details'),
        content: const Text('Client details feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Stat Card
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Client Item
class _ClientItem extends StatelessWidget {
  const _ClientItem({
    required this.name,
    required this.lastVisit,
    required this.nextAppointment,
    required this.onTap,
  });

  final String name;
  final String lastVisit;
  final String nextAppointment;
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
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name.split(' ').map((final n) => n[0]).join(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Last visit: $lastVisit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Next: $nextAppointment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Message Item
class _MessageItem extends StatelessWidget {
  const _MessageItem({
    required this.sender,
    required this.message,
    required this.time,
    required this.isUnread,
    required this.onTap,
  });

  final String sender;
  final String message;
  final String time;
  final bool isUnread;
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
          color: isUnread
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                sender.split(' ').map((final n) => n[0]).join(),
                style: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
