import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/gamification_controller.dart';
import '../theme/google_theme.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/profile_components.dart';
import '../widgets/enhanced_form_components.dart';
import '../widgets/trending_2025_components.dart';
import '../widgets/neo_brutalism_components.dart';
import '../widgets/advanced_glassmorphism_2025.dart';
import '../widgets/cinematic_data_storytelling.dart';

/// Enhanced profile and settings screen with comprehensive customization
/// Following 2025 design trends with advanced personalization and accessibility
class EnhancedProfileSettingsScreen extends StatefulWidget {
  const EnhancedProfileSettingsScreen({super.key});

  @override
  State<EnhancedProfileSettingsScreen> createState() =>
      _EnhancedProfileSettingsScreenState();
}

class _EnhancedProfileSettingsScreenState
    extends State<EnhancedProfileSettingsScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late ScrollController _scrollController;

  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupScrollListener();
  }

  void _initializeControllers() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scrollController = ScrollController();

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 150;
      if (shouldShow != _showAppBarTitle) {
        setState(() => _showAppBarTitle = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = context.watch<SettingsController>();
    final gamification = context.watch<GamificationController>();

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(context),
          ];
        },
        body: AnimatedBuilder(
          animation: _contentController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _contentController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _contentController,
                  curve: Curves.easeOutCubic,
                )),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ResponsivePadding(
                    mobile: const EdgeInsets.all(16),
                    tablet: const EdgeInsets.all(24),
                    desktop: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Enhanced Profile header with NDIS integration
                        _buildEnhancedProfileHeader(context, gamification),

                        const SizedBox(height: 24),

                        // Enhanced voice-controlled quick actions
                        _buildVoiceControlledActions(context),

                        const SizedBox(height: 24),

                        // NDIS-specific profile information
                        _buildNDISProfileSection(context),

                        const SizedBox(height: 24),

                        // Enhanced accessibility settings with glassmorphism
                        AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                          context: context,
                          child: SettingsSection(
                            title: 'Accessibility & Comfort',
                            icon: Icons.accessibility_new,
                            headerColor: GoogleTheme.googleBlue,
                            items: [
                              SettingsItem(
                                title: 'High Contrast Mode',
                                subtitle:
                                    'Enhanced visibility for better readability',
                                leadingIcon: Icons.contrast,
                                trailing: Switch(
                                  value: settings.highContrast,
                                  onChanged: (value) {
                                    HapticFeedback.lightImpact();
                                    settings.setHighContrast(value);
                                  },
                                ),
                              ),
                              SettingsItem(
                                title: 'Reduce Motion',
                                subtitle:
                                    'Minimize animations for motion sensitivity',
                                leadingIcon: Icons.motion_photos_off,
                                trailing: Switch(
                                  value: settings.reduceMotion,
                                  onChanged: (value) {
                                    HapticFeedback.lightImpact();
                                    settings.setReduceMotion(value);
                                  },
                                ),
                              ),
                              SettingsItem(
                                title: 'Voice Navigation',
                                subtitle: 'Navigate with voice commands',
                                leadingIcon: Icons.record_voice_over,
                                trailing: Switch(
                                  value: settings.voiceNavigation,
                                  onChanged: (value) {
                                    HapticFeedback.lightImpact();
                                    settings.setVoiceNavigation(value);
                                    _toggleVoiceNavigation(value);
                                  },
                                ),
                              ),
                              SettingsItem(
                                title: 'Cognitive Assistance',
                                subtitle:
                                    'Simplified navigation and extra help',
                                leadingIcon: Icons.psychology,
                                trailing: Switch(
                                  value: settings.cognitiveAssistance,
                                  onChanged: (value) {
                                    HapticFeedback.lightImpact();
                                    settings.setCognitiveAssistance(value);
                                    _toggleCognitiveAssistance(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Text size slider
                        SliderPreference(
                          title: 'Text Size',
                          subtitle: 'Adjust text size for better readability',
                          value: settings.textScale,
                          min: 0.8,
                          max: 1.8,
                          divisions: 10,
                          onChanged: settings.setTextScale,
                          formatter: (value) => '${(value * 100).round()}%',
                          icon: Icons.text_fields,
                          activeColor: GoogleTheme.googleBlue,
                        ),

                        const SizedBox(height: 24),

                        // Appearance settings
                        SettingsSection(
                          title: 'Appearance',
                          icon: Icons.palette,
                          headerColor: GoogleTheme.googleGreen,
                          items: [
                            SettingsItem(
                              title: 'Theme',
                              subtitle:
                                  _getThemeDescription(settings.themeMode),
                              leadingIcon: Icons.brightness_6,
                              trailing: DropdownButton<ThemeMode>(
                                value: settings.themeMode,
                                underline: const SizedBox(),
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
                                onChanged: (mode) {
                                  if (mode != null) {
                                    HapticFeedback.lightImpact();
                                    settings.setThemeMode(mode);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Notifications settings
                        SettingsSection(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          headerColor: GoogleTheme.ndisTeal,
                          items: [
                            SettingsItem(
                              title: 'Appointment Reminders',
                              subtitle: 'Get notified before appointments',
                              leadingIcon: Icons.event_note,
                              trailing: Switch(
                                value: settings.notifAppointmentReminders,
                                onChanged: (value) {
                                  HapticFeedback.lightImpact();
                                  settings.setNotifAppointmentReminders(value);
                                },
                              ),
                            ),
                            SettingsItem(
                              title: 'Budget Alerts',
                              subtitle: 'Notifications for budget thresholds',
                              leadingIcon: Icons.account_balance_wallet,
                              trailing: Switch(
                                value: settings.notifBudgetAlerts,
                                onChanged: (value) {
                                  HapticFeedback.lightImpact();
                                  settings.setNotifBudgetAlerts(value);
                                },
                              ),
                            ),
                            SettingsItem(
                              title: 'AI Assistant Updates',
                              subtitle: 'Get proactive NDIS guidance',
                              leadingIcon: Icons.smart_toy,
                              trailing: Switch(
                                value: settings.notifAIUpdates,
                                onChanged: (value) {
                                  HapticFeedback.lightImpact();
                                  settings.setNotifAIUpdates(value);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Privacy & Security
                        SettingsSection(
                          title: 'Privacy & Security',
                          icon: Icons.security,
                          headerColor: GoogleTheme.ndisPurple,
                          items: [
                            SettingsItem(
                              title: 'Data Sharing',
                              subtitle: 'Control how your data is used',
                              leadingIcon: Icons.share,
                              onTap: _showDataSharingSettings,
                            ),
                            SettingsItem(
                              title: 'Export Data',
                              subtitle: 'Download your NDIS data',
                              leadingIcon: Icons.download,
                              onTap: _exportUserData,
                            ),
                            SettingsItem(
                              title: 'Delete Account',
                              subtitle: 'Permanently delete your account',
                              leadingIcon: Icons.delete_forever,
                              onTap: _showDeleteAccountDialog,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Support & Help
                        SettingsSection(
                          title: 'Support & Help',
                          icon: Icons.help,
                          headerColor: GoogleTheme.googleYellow,
                          items: [
                            SettingsItem(
                              title: 'Help Center',
                              subtitle: 'FAQs and user guides',
                              leadingIcon: Icons.help_center,
                              onTap: _openHelpCenter,
                            ),
                            SettingsItem(
                              title: 'Contact Support',
                              subtitle: 'Get help from our team',
                              leadingIcon: Icons.support_agent,
                              onTap: _contactSupport,
                            ),
                            SettingsItem(
                              title: 'Feedback',
                              subtitle: 'Help us improve the app',
                              leadingIcon: Icons.feedback,
                              onTap: _provideFeedback,
                            ),
                            SettingsItem(
                              title: 'About',
                              subtitle: 'App version and legal information',
                              leadingIcon: Icons.info,
                              onTap: _showAbout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final gamification = context.watch<GamificationController>();

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Text('Profile & Settings'),
      ),
      actions: [
        Trending2025Components.buildDarkModeToggle(
          context: context,
          isDark: Theme.of(context).brightness == Brightness.dark,
          onChanged: (isDark) {
            final settings = context.read<SettingsController>();
            settings.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
          },
          isAccessible: true,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showAdvancedSettings,
          icon: const Icon(Icons.tune),
          tooltip: 'Advanced Settings',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: NeoBrutalismComponents.buildStrikingHeader(
          context: context,
          title: 'Your NDIS Profile',
          subtitle: 'Personalize your experience',
          backgroundColor: GoogleTheme.ndisPurple,
          trailing: CinematicDataStoryTelling.buildAnimatedDataStory(
            context: context,
            title: 'Total Points',
            value: '${gamification.points}',
            previousValue: '${gamification.points - 50}',
            trendDescription: 'Great engagement!',
            icon: Icons.emoji_events,
            color: GoogleTheme.googleYellow,
            showCelebration: gamification.points > 1000,
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follows system setting';
      case ThemeMode.light:
        return 'Always light theme';
      case ThemeMode.dark:
        return 'Always dark theme';
    }
  }

  // Event handlers
  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => _buildEditProfileDialog(),
    );
  }

  Widget _buildEditProfileDialog() {
    final nameController = TextEditingController(text: 'Alex Johnson');
    final emailController =
        TextEditingController(text: 'alex.johnson@email.com');

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            EnhancedTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            EnhancedTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: EnhancedButton(
                    onPressed: () => Navigator.pop(context),
                    isSecondary: true,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EnhancedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _saveProfile(nameController.text, emailController.text);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EnhancedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _selectFromGallery();
                    },
                    isSecondary: true,
                    icon: Icons.photo_library,
                    child: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EnhancedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                    isSecondary: true,
                    icon: Icons.camera_alt,
                    child: const Text('Camera'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => _buildPrivacySettingsDialog(),
    );
  }

  Widget _buildPrivacySettingsDialog() {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            PreferenceToggle(
              value: context.watch<SettingsController>().shareData,
              onChanged: (value) {
                context.read<SettingsController>().setShareData(value);
              },
              title: 'Data Sharing',
              subtitle: 'Share anonymized data to improve NDIS services',
              icon: Icons.share,
              activeColor: GoogleTheme.googleGreen,
            ),
            const SizedBox(height: 16),
            PreferenceToggle(
              value: context.watch<SettingsController>().analyticsEnabled,
              onChanged: (value) {
                context.read<SettingsController>().setAnalyticsEnabled(value);
              },
              title: 'Analytics',
              subtitle: 'Help improve the app with usage analytics',
              icon: Icons.analytics,
              activeColor: GoogleTheme.googleBlue,
            ),
            const SizedBox(height: 16),
            PreferenceToggle(
              value: context.watch<SettingsController>().crashReportingEnabled,
              onChanged: (value) {
                context
                    .read<SettingsController>()
                    .setCrashReportingEnabled(value);
              },
              title: 'Crash Reporting',
              subtitle: 'Automatically report crashes to improve stability',
              icon: Icons.bug_report,
              activeColor: GoogleTheme.ndisTeal,
            ),
            const SizedBox(height: 24),
            EnhancedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupSettings() {
    showDialog(
      context: context,
      builder: (context) => _buildBackupSettingsDialog(),
    );
  }

  Widget _buildBackupSettingsDialog() {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup & Sync',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.cloud_upload, color: GoogleTheme.googleBlue),
              title: const Text('Backup to Cloud'),
              subtitle: const Text('Last backup: Today, 2:30 PM'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EnhancedButton(
                    onPressed: _performBackup,
                    isSecondary: true,
                    child: const Text('Backup Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EnhancedButton(
                    onPressed: _restoreFromBackup,
                    isSecondary: true,
                    child: const Text('Restore'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            EnhancedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedSettings() {
    // TODO: Implement advanced settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced settings feature coming soon')),
    );
  }

  void _showDataSharingSettings() {
    Navigator.pop(context);
    // TODO: Implement data sharing settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Data sharing settings feature coming soon')),
    );
  }

  void _exportUserData() {
    // TODO: Implement data export
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export initiated')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          EnhancedButton(
            onPressed: () {
              Navigator.pop(context);
              _performAccountDeletion();
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _saveProfile(String name, String email) {
    // TODO: Implement profile save
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _selectFromGallery() {
    // TODO: Implement gallery selection
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery selection feature coming soon')),
    );
  }

  void _takePhoto() {
    // TODO: Implement camera capture
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera capture feature coming soon')),
    );
  }

  void _performBackup() {
    // TODO: Implement backup functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup completed successfully')),
    );
  }

  void _restoreFromBackup() {
    // TODO: Implement restore functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore feature coming soon')),
    );
  }

  void _openHelpCenter() {
    // TODO: Implement help center
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center feature coming soon')),
    );
  }

  void _contactSupport() {
    // TODO: Implement contact support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support feature coming soon')),
    );
  }

  void _provideFeedback() {
    // TODO: Implement feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback feature coming soon')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'NDIS Connect',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: GoogleTheme.googleBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.accessibility_new,
          color: GoogleTheme.googleBlue,
          size: 24,
        ),
      ),
      children: [
        const Text(
          'NDIS Connect is an accessible, role-based companion for NDIS participants and providers. Built with accessibility in mind and following WCAG 2.2 AA standards.',
        ),
      ],
    );
  }

  // BMAD Enhanced Methods - New 2025+ Features

  Widget _buildEnhancedProfileHeader(
      BuildContext context, GamificationController gamification) {
    final theme = Theme.of(context);

    return AdvancedGlassmorphism2025.buildInteractiveGlassCard(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile avatar with achievement ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Achievement progress ring
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: gamification.streakDays / 30.0, // 30-day streak goal
                    strokeWidth: 6,
                    backgroundColor: GoogleTheme.googleBlue.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(GoogleTheme.googleBlue),
                  ),
                ),

                // Profile avatar
                GestureDetector(
                  onTap: _changeAvatar,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          GoogleTheme.googleBlue,
                          GoogleTheme.ndisPurple,
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                // Level badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GoogleTheme.googleYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '${(gamification.points / 100).floor() + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // User information
            Text(
              'Alex Johnson',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'NDIS Participant • Plan: Active',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: GoogleTheme.googleGreen,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // Enhanced stats with cinematic elements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CinematicDataStoryTelling.buildAnimatedDataStory(
                  context: context,
                  title: 'Streak',
                  value: '${gamification.streakDays}',
                  previousValue: '${gamification.streakDays - 1}',
                  trendDescription: 'Days active',
                  icon: Icons.local_fire_department,
                  color: GoogleTheme.googleRed,
                  showCelebration: gamification.streakDays > 7,
                ),
                CinematicDataStoryTelling.buildAnimatedDataStory(
                  context: context,
                  title: 'Sessions',
                  value: '47',
                  previousValue: '44',
                  trendDescription: 'Completed',
                  icon: Icons.event_available,
                  color: GoogleTheme.googleGreen,
                  showCelebration: false,
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: _editProfile,
    );
  }

  Widget _buildVoiceControlledActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice-Controlled Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),

        const SizedBox(height: 16),

        // Voice interface for profile actions
        Trending2025Components.buildVoiceInterface(
          context: context,
          isListening: false,
          onVoiceToggle: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Say "Edit profile" or "Show settings"'),
                duration: Duration(seconds: 3),
              ),
            );
          },
          transcribedText: null,
          isAccessible: true,
        ),

        const SizedBox(height: 16),

        // Quick action buttons with enhanced design
        ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 4,
          desktopColumns: 4,
          spacing: 12,
          children: [
            Trending2025Components.buildInteractiveButton(
              label: 'Edit Profile',
              onPressed: _editProfile,
              icon: Icons.edit,
              backgroundColor: GoogleTheme.googleBlue,
              hasPulseAnimation: false,
            ),
            Trending2025Components.buildInteractiveButton(
              label: 'Emergency',
              onPressed: _showEmergencyContacts,
              icon: Icons.emergency,
              backgroundColor: GoogleTheme.googleRed,
              hasPulseAnimation: true,
            ),
            Trending2025Components.buildInteractiveButton(
              label: 'Care Team',
              onPressed: _manageCareTeam,
              icon: Icons.people,
              backgroundColor: GoogleTheme.ndisTeal,
              hasPulseAnimation: false,
            ),
            Trending2025Components.buildInteractiveButton(
              label: 'Health Data',
              onPressed: _manageHealthData,
              icon: Icons.health_and_safety,
              backgroundColor: GoogleTheme.googleGreen,
              hasPulseAnimation: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNDISProfileSection(BuildContext context) {
    return AdvancedGlassmorphism2025.buildInteractiveGlassCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeoBrutalismComponents.buildStrikingHeader(
            context: context,
            title: 'NDIS Information',
            subtitle: 'Your plan and support details',
            backgroundColor: GoogleTheme.ndisTeal,
          ),

          const SizedBox(height: 20),

          // NDIS-specific information cards
          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'NDIS Plan Status',
            content: 'Active • Expires: March 2025 • Review Due: January 2025',
            icon: Icons.assignment,
            accentColor: GoogleTheme.googleGreen,
            onTap: _showPlanDetails,
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Support Coordinator',
            content: 'Sarah Wilson • Active Care Solutions • (03) 9876 5432',
            icon: Icons.support_agent,
            accentColor: GoogleTheme.googleBlue,
            onTap: _contactSupportCoordinator,
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Plan Utilization',
            content: '68% used • \$18,400 remaining of \$28,000 total',
            icon: Icons.pie_chart,
            accentColor: GoogleTheme.ndisPurple,
            onTap: _showBudgetBreakdown,
          ),

          const SizedBox(height: 20),

          // Contextual guidance
          CinematicDataStoryTelling.buildContextualVisualCue(
            context: context,
            message:
                'Your plan review is due in 2 months. Book a meeting with your coordinator.',
            type: CueType.attention,
            onAction: _bookPlanReview,
          ),
        ],
      ),
    );
  }

  // Enhanced event handlers with NDIS-specific features
  void _toggleVoiceNavigation(bool enabled) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enabled
            ? 'Voice navigation enabled. Say "Hey NDIS" to start.'
            : 'Voice navigation disabled.'),
        backgroundColor: enabled ? GoogleTheme.googleGreen : null,
      ),
    );
  }

  void _toggleCognitiveAssistance(bool enabled) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enabled
            ? 'Cognitive assistance enabled. Simplified interface activated.'
            : 'Cognitive assistance disabled.'),
        backgroundColor: enabled ? GoogleTheme.googleBlue : null,
      ),
    );
  }

  void _showEmergencyContacts() {
    showDialog(
      context: context,
      builder: (context) => AdvancedGlassmorphism2025.buildGlassModalOverlay(
        context: context,
        child: _buildEmergencyContactsDialog(),
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEmergencyContactsDialog() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeoBrutalismComponents.buildStrikingHeader(
            context: context,
            title: 'Emergency Contacts',
            subtitle: 'Quick access to your support network',
            backgroundColor: GoogleTheme.googleRed,
          ),

          const SizedBox(height: 24),

          // Emergency contact list
          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Primary Emergency Contact',
            content: 'Sarah Johnson (Mother) • 0412 345 678',
            icon: Icons.person,
            accentColor: GoogleTheme.googleRed,
            onTap: () {
              // TODO: Call emergency contact
            },
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Support Coordinator',
            content: 'Active Care Solutions • 1800 SUPPORT',
            icon: Icons.support_agent,
            accentColor: GoogleTheme.googleBlue,
            onTap: () {
              // TODO: Call support coordinator
            },
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Medical Emergency',
            content: 'Ambulance • 000',
            icon: Icons.local_hospital,
            accentColor: GoogleTheme.googleRed,
            onTap: () {
              // TODO: Call emergency services
            },
          ),

          const SizedBox(height: 24),

          Trending2025Components.buildInteractiveButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
            backgroundColor: GoogleTheme.googleBlue,
          ),
        ],
      ),
    );
  }

  void _manageCareTeam() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Care team management feature coming soon')),
    );
  }

  void _manageHealthData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Health data management feature coming soon')),
    );
  }

  void _showPlanDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NDIS plan details feature coming soon')),
    );
  }

  void _contactSupportCoordinator() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacting support coordinator...')),
    );
  }

  void _showBudgetBreakdown() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget breakdown feature coming soon')),
    );
  }

  void _bookPlanReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan review booking feature coming soon')),
    );
  }

  void _performAccountDeletion() {
    // TODO: Implement account deletion
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deletion initiated'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
