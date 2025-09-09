import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../widgets/icon_card.dart';
import '../widgets/hero_banner.dart';
import '../theme/app_theme.dart';
import '../controllers/settings_controller.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Hub'),
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
          const HeroBanner(
            title: 'Provider Dashboard',
            subtitle: 'Manage your NDIS services and clients',
            icon: Icons.business,
            showGamification: false,
          ),
          const SizedBox(height: 16),

          // Core Provider Services
          const _SectionHeader(
              title: 'Core Services', icon: Icons.business_center),
          const SizedBox(height: 8),
          IconCard(
            icon: Icons.calendar_today,
            label: 'Roster & Bookings',
            subtitle: 'Manage your schedule and accept bookings',
            iconColor: AppTheme.ndisBlue,
            onTap: () => Navigator.pushNamed(context, Routes.roster),
          ),
          IconCard(
            icon: Icons.receipt_long,
            label: 'Invoices & Compliance',
            subtitle: 'Submit claims and track compliance status',
            iconColor: AppTheme.ndisGreen,
            onTap: () {},
          ),
          IconCard(
            icon: Icons.people_outline,
            label: 'Client Management',
            subtitle: 'View and manage your participant relationships',
            iconColor: AppTheme.ndisTeal,
            onTap: () {},
          ),

          const SizedBox(height: 16),
          const _SectionHeader(
              title: 'Analytics & Reports', icon: Icons.analytics),
          const SizedBox(height: 8),
          IconCard(
            icon: Icons.assessment,
            label: 'Performance Reports',
            subtitle: 'View your service delivery metrics',
            iconColor: AppTheme.ndisPurple,
            onTap: () {},
          ),
          IconCard(
            icon: Icons.trending_up,
            label: 'Growth Insights',
            subtitle: 'Track your business growth and opportunities',
            iconColor: AppTheme.ndisOrange,
            onTap: () {},
          ),

          const SizedBox(height: 16),
          // Compliance Status Card
          Card(
            color: AppTheme.ndisGreen.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.ndisGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: AppTheme.ndisGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compliance Status',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your compliance rating is excellent',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '88%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.ndisGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'Overall Compliance',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.ndisBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'Active Clients',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '156',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.ndisTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'Sessions This Month',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
          ),
          const Spacer(),
          Container(
            height: 1,
            width: 40,
            color: scheme.outline.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
