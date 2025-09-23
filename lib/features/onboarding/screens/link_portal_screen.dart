import 'package:flutter/material.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/empty_states.dart';
import '../../../app/router.dart';

/// Link Portal Screen
/// Placeholder for myGov/NDIS portal integration
class LinkPortalScreen extends StatelessWidget {
  const LinkPortalScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link NDIS Portal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: EmptyState(
                  icon: Icons.link,
                  title: 'Connect to NDIS Portal',
                  description:
                      'Link your myGov account to access your NDIS plan information directly in the app.',
                  action: Column(
                    children: [
                      PrimaryButton(
                        text: 'Link with myGov',
                        icon: Icons.account_circle,
                        onPressed: () => _showComingSoon(context),
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 16),
                      SecondaryButton(
                        text: 'Skip for now',
                        onPressed: context.goToParticipantDashboard,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
          'NDIS portal integration is currently in development. '
          'You can still use the app with manual data entry.',
        ),
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
