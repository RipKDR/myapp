import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../app/router.dart';

/// Development Panel Screen
/// Quick navigation for development and testing
class DevPanelScreen extends StatelessWidget {
  const DevPanelScreen({super.key});

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Dev Panel',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Navigation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _DevButton(
                    title: 'Splash',
                    icon: Icons.play_arrow,
                    onTap: context.goToSplash,
                  ),
                  _DevButton(
                    title: 'Onboarding',
                    icon: Icons.login,
                    onTap: context.goToOnboarding,
                  ),
                  _DevButton(
                    title: 'Participant Dashboard',
                    icon: Icons.dashboard,
                    onTap: context.goToParticipantDashboard,
                  ),
                  _DevButton(
                    title: 'Provider Dashboard',
                    icon: Icons.medical_services,
                    onTap: context.goToProviderDashboard,
                  ),
                  _DevButton(
                    title: 'Budgets',
                    icon: Icons.account_balance_wallet,
                    onTap: context.goToBudgets,
                  ),
                  _DevButton(
                    title: 'Claims',
                    icon: Icons.receipt,
                    onTap: context.goToClaims,
                  ),
                  _DevButton(
                    title: 'Services',
                    icon: Icons.location_on,
                    onTap: context.goToServices,
                  ),
                  _DevButton(
                    title: 'Messages',
                    icon: Icons.message,
                    onTap: context.goToMessages,
                  ),
                  _DevButton(
                    title: 'Support Circle',
                    icon: Icons.people,
                    onTap: context.goToSupport,
                  ),
                  _DevButton(
                    title: 'Calendar',
                    icon: Icons.calendar_today,
                    onTap: context.goToCalendar,
                  ),
                  _DevButton(
                    title: 'Settings',
                    icon: Icons.settings,
                    onTap: context.goToSettings,
                  ),
                  _DevButton(
                    title: 'Link Portal',
                    icon: Icons.link,
                    onTap: context.goToLinkPortal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

/// Development Button Widget
class _DevButton extends StatelessWidget {
  const _DevButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
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
