import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/settings_controller.dart';
import '../../../ui/components/app_scaffold.dart';

/// Settings Screen
/// App preferences and accessibility settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccessibilitySection(context),
          const SizedBox(height: 24),
          _buildAppearanceSection(context),
          const SizedBox(height: 24),
          _buildPrivacySection(context),
          const SizedBox(height: 24),
          _buildSupportSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
        ],
      ),
    );

  Widget _buildAccessibilitySection(final BuildContext context) {
    final settings = context.watch<SettingsController>();
    
    return _SettingsSection(
      title: 'Accessibility',
      icon: Icons.accessibility,
      children: [
        _SettingsSwitchTile(
          title: 'High Contrast',
          subtitle: 'Increase contrast for better visibility',
          value: settings.highContrast,
          onChanged: settings.setHighContrast,
        ),
        _SettingsSwitchTile(
          title: 'Reduce Motion',
          subtitle: 'Minimize animations and transitions',
          value: settings.reduceMotion,
          onChanged: settings.setReduceMotion,
        ),
        _SettingsSliderTile(
          title: 'Text Scale',
          subtitle: 'Adjust text size (${(settings.textScale * 100).round()}%)',
          value: settings.textScale,
          min: 0.8,
          max: 2,
          divisions: 12,
          onChanged: settings.setTextScale,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(final BuildContext context) {
    final settings = context.watch<SettingsController>();
    
    return _SettingsSection(
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        _SettingsListTile(
          title: 'Theme',
          subtitle: _getThemeModeText(settings.themeMode),
          onTap: () => _showThemeDialog(context, settings),
        ),
        _SettingsListTile(
          title: 'Language',
          subtitle: 'English',
          onTap: () => _showComingSoon(context, 'Language selection'),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(final BuildContext context) => _SettingsSection(
      title: 'Privacy & Security',
      icon: Icons.security,
      children: [
        _SettingsListTile(
          title: 'Privacy Policy',
          subtitle: 'View our privacy policy',
          onTap: () => _showComingSoon(context, 'Privacy policy'),
        ),
        _SettingsListTile(
          title: 'Data Export',
          subtitle: 'Download your data',
          onTap: () => _showComingSoon(context, 'Data export'),
        ),
        _SettingsListTile(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );

  Widget _buildSupportSection(final BuildContext context) => _SettingsSection(
      title: 'Support',
      icon: Icons.help,
      children: [
        _SettingsListTile(
          title: 'Help Center',
          subtitle: 'Get help and support',
          onTap: () => _showComingSoon(context, 'Help center'),
        ),
        _SettingsListTile(
          title: 'Contact Support',
          subtitle: 'Get in touch with our team',
          onTap: () => _showComingSoon(context, 'Contact support'),
        ),
        _SettingsListTile(
          title: 'Report a Bug',
          subtitle: 'Help us improve the app',
          onTap: () => _showComingSoon(context, 'Bug reporting'),
        ),
        _SettingsListTile(
          title: 'Feature Request',
          subtitle: 'Suggest new features',
          onTap: () => _showComingSoon(context, 'Feature requests'),
        ),
      ],
    );

  Widget _buildAboutSection(final BuildContext context) => _SettingsSection(
      title: 'About',
      icon: Icons.info,
      children: [
        const _SettingsListTile(
          title: 'App Version',
          subtitle: '1.0.0',
        ),
        _SettingsListTile(
          title: 'Terms of Service',
          subtitle: 'View terms and conditions',
          onTap: () => _showComingSoon(context, 'Terms of service'),
        ),
        _SettingsListTile(
          title: 'Open Source Licenses',
          subtitle: 'View third-party licenses',
          onTap: () => _showComingSoon(context, 'Open source licenses'),
        ),
      ],
    );

  String _getThemeModeText(final ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(final BuildContext context, final SettingsController settings) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (final value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (final value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (final value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context, 'Account deletion');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(final BuildContext context, final String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
      ),
    );
  }
}

/// Settings Section Widget
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Settings Switch Tile
class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(final BuildContext context) => SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
}

/// Settings Slider Tile
class _SettingsSliderTile extends StatelessWidget {
  const _SettingsSliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(final BuildContext context) => ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
}

/// Settings List Tile
class _SettingsListTile extends StatelessWidget {
  const _SettingsListTile({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) => ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
}
