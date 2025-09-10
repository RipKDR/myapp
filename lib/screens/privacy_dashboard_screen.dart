import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_utils.dart';
import '../widgets/modern_dashboard_layout.dart';

/// Privacy-first dashboard implementing 2025 healthcare UX standards
class PrivacyDashboardScreen extends StatelessWidget {
  const PrivacyDashboardScreen({super.key});

  @override
  Widget build(final BuildContext context) => ModernDashboardLayout(
      title: 'Privacy & Data Control',
      subtitle: 'Your data, your choices',
      children: [
        _DataUsageOverview(),
        _PermissionControls(),
        _DataExportCard(),
        _PrivacyEducationCard(),
        _ContactPreferences(),
        _DataRetentionSettings(),
      ],
    );
}

/// Clear overview of how user data is being used
class _DataUsageOverview extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.trustGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppTheme.trustGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Data Usage Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.calmingBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Transparent',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.calmingBlue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataUsageItem(
            context,
            'Health & Plan Data',
            'Used for personalized recommendations',
            Icons.health_and_safety,
            AppTheme.trustGreen,
            true,
          ),
          const SizedBox(height: 12),
          _buildDataUsageItem(
            context,
            'Location Services',
            'Find nearby NDIS providers',
            Icons.location_on,
            AppTheme.warmAccent,
            true,
          ),
          const SizedBox(height: 12),
          _buildDataUsageItem(
            context,
            'Analytics',
            'Improve app experience (anonymized)',
            Icons.analytics,
            AppTheme.safetyGrey,
            false,
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: Today',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsageItem(
    final BuildContext context,
    final String title,
    final String description,
    final IconData icon,
    final Color iconColor,
    final bool isEnabled,
  ) => Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Icon(
          isEnabled ? Icons.check_circle : Icons.cancel,
          color: isEnabled ? AppTheme.trustGreen : AppTheme.safetyGrey,
          size: 18,
        ),
      ],
    );
}

/// Granular permission controls for different data types
class _PermissionControls extends StatefulWidget {
  @override
  State<_PermissionControls> createState() => _PermissionControlsState();
}

class _PermissionControlsState extends State<_PermissionControls> {
  final Map<String, bool> _permissions = {
    'location': true,
    'notifications': true,
    'camera': false,
    'microphone': true,
    'contacts': false,
    'calendar': true,
  };

  @override
  Widget build(final BuildContext context) => InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.empathyPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppTheme.empathyPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'App Permissions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._permissions.entries
              .map((final entry) => _buildPermissionToggle(entry.key, entry.value)),
        ],
      ),
    );

  Widget _buildPermissionToggle(final String permission, final bool isEnabled) {
    final permissionData = _getPermissionData(permission);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            permissionData['icon'] as IconData,
            color: permissionData['color'] as Color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permissionData['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  permissionData['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (final value) {
              setState(() {
                _permissions[permission] = value;
              });
              HapticUtils.selectionClick(context);
            },
            activeTrackColor: AppTheme.trustGreen,
            activeThumbColor: AppTheme.trustGreen,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPermissionData(final String permission) {
    final data = {
      'location': {
        'title': 'Location',
        'description': 'Find nearby NDIS services and providers',
        'icon': Icons.location_on,
        'color': AppTheme.warmAccent,
      },
      'notifications': {
        'title': 'Notifications',
        'description': 'Appointment reminders and important updates',
        'icon': Icons.notifications,
        'color': AppTheme.calmingBlue,
      },
      'camera': {
        'title': 'Camera',
        'description': 'Scan documents and QR codes',
        'icon': Icons.camera_alt,
        'color': AppTheme.safetyGrey,
      },
      'microphone': {
        'title': 'Microphone',
        'description': 'Voice commands and accessibility features',
        'icon': Icons.mic,
        'color': AppTheme.empathyPurple,
      },
      'contacts': {
        'title': 'Contacts',
        'description': 'Add support workers to your contact list',
        'icon': Icons.contacts,
        'color': AppTheme.safetyGrey,
      },
      'calendar': {
        'title': 'Calendar',
        'description': 'Sync appointments with your device calendar',
        'icon': Icons.calendar_today,
        'color': AppTheme.trustGreen,
      },
    };
    return data[permission] ?? {};
  }
}

/// Easy data export functionality
class _DataExportCard extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.hopeBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download,
                  color: AppTheme.hopeBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Export Your Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Download a copy of all your data in an easy-to-read format. This includes your plan details, appointment history, and preferences.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          HapticButton(
            isPrimary: true,
            backgroundColor: AppTheme.hopeBlue,
            onPressed: () => _exportData(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download, size: 18),
                SizedBox(width: 8),
                Text('Download My Data'),
              ],
            ),
          ),
        ],
      ),
    );

  Future<void> _exportData(final BuildContext context) async {
    HapticUtils.successFeedback(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.trustGreen),
            SizedBox(width: 8),
            Text(
                'Data export started. You\'ll receive an email shortly.'),
          ],
        ),
        backgroundColor: AppTheme.trustGreen.withValues(alpha: 0.1),
      ),
    );
  }
}

/// Privacy education and tips
class _PrivacyEducationCard extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => InteractiveCard(
      onTap: () => _showPrivacyEducation(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warmAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: AppTheme.warmAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Privacy Education',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Learn about your privacy rights, how your data is protected, and tips for staying safe online.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.calmingBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.calmingBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'New: Understanding NDIS Data Rights',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.calmingBlue,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  void _showPrivacyEducation(final BuildContext context) {
    HapticUtils.lightImpact(context);
    // Implementation would show detailed privacy education
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy education feature coming soon!')),
    );
  }
}

/// Communication preferences
class _ContactPreferences extends StatefulWidget {
  @override
  State<_ContactPreferences> createState() => _ContactPreferencesState();
}

class _ContactPreferencesState extends State<_ContactPreferences> {
  String _preferredContact = 'email';
  bool _marketingEmails = false;
  bool _appointmentReminders = true;
  bool _emergencyContacts = true;

  @override
  Widget build(final BuildContext context) => InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.calmingBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_mail,
                  color: AppTheme.calmingBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Preferred contact method:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildContactChoice('email', 'Email', Icons.email),
              _buildContactChoice('sms', 'SMS', Icons.sms),
              _buildContactChoice('phone', 'Phone', Icons.phone),
            ],
          ),
          const SizedBox(height: 16),
          _buildTogglePreference(
            'Appointment Reminders',
            'Get notified about upcoming appointments',
            _appointmentReminders,
            (final value) => setState(() => _appointmentReminders = value),
          ),
          _buildTogglePreference(
            'Emergency Contacts',
            'Allow emergency services to contact you',
            _emergencyContacts,
            (final value) => setState(() => _emergencyContacts = value),
          ),
          _buildTogglePreference(
            'Marketing Emails',
            'Receive updates about new NDIS services',
            _marketingEmails,
            (final value) => setState(() => _marketingEmails = value),
          ),
        ],
      ),
    );

  Widget _buildContactChoice(final String value, final String label, final IconData icon) {
    final isSelected = _preferredContact == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (final selected) {
        if (selected) {
          setState(() => _preferredContact = value);
          HapticUtils.selectionClick(context);
        }
      },
      selectedColor: AppTheme.calmingBlue.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.calmingBlue,
    );
  }

  Widget _buildTogglePreference(
    final String title,
    final String description,
    final bool value,
    final ValueChanged<bool> onChanged,
  ) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (final newValue) {
              onChanged(newValue);
              HapticUtils.selectionClick(context);
            },
            activeTrackColor: AppTheme.trustGreen,
            activeThumbColor: AppTheme.trustGreen,
          ),
        ],
      ),
    );
}

/// Data retention and deletion settings
class _DataRetentionSettings extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.safetyGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_delete,
                  color: AppTheme.safetyGrey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Retention',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your data is kept secure and automatically deleted according to NDIS privacy requirements.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warmAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warmAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.warmAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Automatic Data Lifecycle',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.warmAccent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Plan data: Kept for 7 years after plan end\n'
                  '• App usage: Anonymized after 2 years\n'
                  '• Support logs: Deleted after 1 year\n'
                  '• Backup data: Encrypted and auto-deleted',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HapticButton(
            isDestructive: true,
            onPressed: () => _showDeleteAccount(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever, size: 18),
                SizedBox(width: 8),
                Text('Delete All My Data'),
              ],
            ),
          ),
        ],
      ),
    );

  void _showDeleteAccount(final BuildContext context) {
    HapticUtils.errorFeedback(context);
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your data including your NDIS plan, appointments, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          HapticButton(
            isDestructive: true,
            onPressed: () {
              Navigator.pop(context);
              // Implementation would handle account deletion
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
