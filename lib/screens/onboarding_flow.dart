import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/enhanced_form_components.dart';

/// Comprehensive onboarding flow for NDIS Connect
/// Following 2025 UX patterns with progressive disclosure and accessibility focus
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _slideController;

  int _currentPage = 0;
  bool _isLoading = false;

  // User selection data
  String? _selectedRole;
  final List<String> _selectedNeeds = [];
  final Map<String, bool> _accessibilityPreferences = {
    'highContrast': false,
    'largeText': false,
    'voiceOver': false,
    'reduceMotion': false,
    'simplifiedUI': false,
  };

  final List<OnboardingStep> _steps = [
    OnboardingStep.welcome(),
    OnboardingStep.roleSelection(),
    OnboardingStep.needsAssessment(),
    OnboardingStep.accessibilitySetup(),
    OnboardingStep.permissions(),
    OnboardingStep.completion(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _pageController = PageController();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _steps.length,
                itemBuilder: (final context, final index) => _buildStepContent(_steps[index], index),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Step indicator
          Row(
            children: List.generate(_steps.length, (final index) {
              final isActive = index <= _currentPage;
              final isCurrent = index == _currentPage;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < _steps.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? GoogleTheme.googleBlue
                        : colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: isCurrent
                      ? AnimatedBuilder(
                          animation: _progressController,
                          builder: (final context, final child) => LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                GoogleTheme.googleBlue,
                              ),
                            ),
                        )
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Step title and description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_currentPage),
              children: [
                Text(
                  _steps[_currentPage].title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _steps[_currentPage].description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(final OnboardingStep step, final int index) => AnimatedBuilder(
      animation: _slideController,
      builder: (final context, final child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _slideController,
            child: ResponsivePadding(
              mobile: const EdgeInsets.all(24),
              tablet: const EdgeInsets.all(32),
              desktop: const EdgeInsets.all(48),
              child: _buildStepWidget(step, index),
            ),
          ),
        ),
    );

  Widget _buildStepWidget(final OnboardingStep step, final int index) {
    switch (step.type) {
      case OnboardingStepType.welcome:
        return _buildWelcomeStep();
      case OnboardingStepType.roleSelection:
        return _buildRoleSelectionStep();
      case OnboardingStepType.needsAssessment:
        return _buildNeedsAssessmentStep();
      case OnboardingStepType.accessibilitySetup:
        return _buildAccessibilitySetupStep();
      case OnboardingStepType.permissions:
        return _buildPermissionsStep();
      case OnboardingStepType.completion:
        return _buildCompletionStep();
    }
  }

  Widget _buildWelcomeStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero illustration/icon
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GoogleTheme.googleBlue.withValues(alpha: 0.1),
                    GoogleTheme.googleGreen.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.accessibility_new,
                size: 80,
                color: GoogleTheme.googleBlue,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Welcome to NDIS Connect',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Your accessible companion for NDIS services. Let\'s personalize your experience to meet your unique needs.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Key features preview
            _buildFeaturePreview([
              FeaturePreview(
                icon: Icons.accessibility,
                title: 'Fully Accessible',
                description: 'WCAG 2.2 AA compliant',
              ),
              FeaturePreview(
                icon: Icons.offline_bolt,
                title: 'Works Offline',
                description: 'Access your data anywhere',
              ),
              FeaturePreview(
                icon: Icons.security,
                title: 'Secure & Private',
                description: 'Your data is protected',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionStep() {
    final roles = [
      RoleOption(
        id: 'participant',
        title: 'NDIS Participant',
        description: 'I receive NDIS support and services',
        icon: Icons.person,
        color: GoogleTheme.googleBlue,
      ),
      RoleOption(
        id: 'provider',
        title: 'Service Provider',
        description: 'I provide NDIS services to participants',
        icon: Icons.business,
        color: GoogleTheme.googleGreen,
      ),
      RoleOption(
        id: 'supporter',
        title: 'Family/Supporter',
        description: 'I support someone who receives NDIS services',
        icon: Icons.family_restroom,
        color: GoogleTheme.ndisTeal,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            ...roles.map(_buildRoleCard),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(final RoleOption role) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedRole == role.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isSelected ? role.color.withValues(alpha: 0.1) : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 2 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() => _selectedRole = role.id);
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? role.color
                    : colorScheme.outline.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: role.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    role.icon,
                    color: role.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: role.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeedsAssessmentStep() {
    final needs = _getAvailableNeeds();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'What areas would you like support with?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply. You can change these later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: needs.map(_buildNeedChip).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedChip(final NeedOption need) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedNeeds.contains(need.id);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            need.icon,
            size: 18,
            color: isSelected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(need.title),
        ],
      ),
      selected: isSelected,
      onSelected: (final selected) {
        setState(() {
          if (selected) {
            _selectedNeeds.add(need.id);
          } else {
            _selectedNeeds.remove(need.id);
          }
        });
        HapticFeedback.lightImpact();
      },
      backgroundColor: colorScheme.surface,
      selectedColor: GoogleTheme.googleBlue.withValues(alpha: 0.1),
      checkmarkColor: GoogleTheme.googleBlue,
      side: BorderSide(
        color: isSelected
            ? GoogleTheme.googleBlue
            : colorScheme.outline.withValues(alpha: 0.1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildAccessibilitySetupStep() {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'Accessibility Preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Customize the app to work best for you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ..._buildAccessibilityOptions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAccessibilityOptions() {
    final options = [
      AccessibilityOption(
        key: 'highContrast',
        title: 'High Contrast',
        subtitle: 'Increase contrast for better visibility',
        icon: Icons.contrast,
      ),
      AccessibilityOption(
        key: 'largeText',
        title: 'Large Text',
        subtitle: 'Increase text size throughout the app',
        icon: Icons.text_fields,
      ),
      AccessibilityOption(
        key: 'voiceOver',
        title: 'Screen Reader Support',
        subtitle: 'Enhanced support for screen readers',
        icon: Icons.record_voice_over,
      ),
      AccessibilityOption(
        key: 'reduceMotion',
        title: 'Reduce Motion',
        subtitle: 'Minimize animations and transitions',
        icon: Icons.motion_photos_off,
      ),
      AccessibilityOption(
        key: 'simplifiedUI',
        title: 'Simplified Interface',
        subtitle: 'Show only essential features',
        icon: Icons.view_compact,
      ),
    ];

    return options.map((final option) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: EnhancedCheckbox(
          value: _accessibilityPreferences[option.key] ?? false,
          onChanged: (final value) {
            setState(() {
              _accessibilityPreferences[option.key] = value ?? false;
            });
          },
          label: option.title,
          subtitle: option.subtitle,
        ),
      )).toList();
  }

  Widget _buildPermissionsStep() {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 64,
              color: GoogleTheme.googleBlue,
            ),
            const SizedBox(height: 24),
            Text(
              'Permissions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We need a few permissions to provide the best experience.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ..._buildPermissionItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPermissionItems() {
    final permissions = [
      PermissionItem(
        icon: Icons.notifications,
        title: 'Notifications',
        description: 'Get reminders for appointments and important updates',
        color: GoogleTheme.googleBlue,
      ),
      PermissionItem(
        icon: Icons.location_on,
        title: 'Location',
        description: 'Find nearby services and providers',
        color: GoogleTheme.googleGreen,
      ),
      PermissionItem(
        icon: Icons.calendar_today,
        title: 'Calendar',
        description: 'Sync appointments with your device calendar',
        color: GoogleTheme.ndisTeal,
      ),
    ];

    return permissions.map((final permission) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: permission.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                permission.icon,
                color: permission.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permission.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    permission.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList();
  }

  Widget _buildCompletionStep() {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GoogleTheme.googleGreen.withValues(alpha: 0.1),
                    GoogleTheme.googleBlue.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: GoogleTheme.googleGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You\'re all set!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to NDIS Connect. Your personalized dashboard is ready.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSetupSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupSummary() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Setup:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (_selectedRole != null) ...[
            _buildSummaryItem(
              Icons.person,
              'Role: ${_getRoleTitle(_selectedRole!)}',
            ),
            const SizedBox(height: 4),
          ],
          if (_selectedNeeds.isNotEmpty) ...[
            _buildSummaryItem(
              Icons.checklist,
              'Support Areas: ${_selectedNeeds.length} selected',
            ),
            const SizedBox(height: 4),
          ],
          _buildSummaryItem(
            Icons.accessibility,
            'Accessibility: ${_getEnabledAccessibilityCount()} features enabled',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(final IconData icon, final String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePreview(final List<FeaturePreview> features) => Column(
      children: features.map((final feature) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: GoogleTheme.googleBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  feature.icon,
                  size: 16,
                  color: GoogleTheme.googleBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      feature.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
    );

  Widget _buildNavigationButtons() {
    final canGoNext = _canProceedToNext();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0)
            Expanded(
              child: EnhancedButton(
                onPressed: _goToPreviousPage,
                isSecondary: true,
                child: const Text('Back'),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 16),

          // Next/Finish button
          Expanded(
            flex: 2,
            child: EnhancedButton(
              onPressed: canGoNext ? _goToNextPage : null,
              isLoading: _isLoading,
              child: Text(
                _currentPage == _steps.length - 1 ? 'Get Started' : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(final int page) {
    setState(() => _currentPage = page);
    _progressController.forward();

    // Reset slide animation for new page
    _slideController.reset();
    _slideController.forward();
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _goToNextPage() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding
      await _completeOnboarding();
    }
  }

  bool _canProceedToNext() {
    switch (_currentPage) {
      case 0: // Welcome
        return true;
      case 1: // Role selection
        return _selectedRole != null;
      case 2: // Needs assessment
        return _selectedNeeds.isNotEmpty;
      case 3: // Accessibility
        return true;
      case 4: // Permissions
        return true;
      case 5: // Completion
        return true;
      default:
        return false;
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Save onboarding data
      // await auth.completeOnboarding({ // Method not available
      //   'role': _selectedRole,
      //   'needs': _selectedNeeds,
      //   'accessibility': _accessibilityPreferences,
      //   'completedAt': DateTime.now().toIso8601String(),
      // });

      // Navigate to main app
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<NeedOption> _getAvailableNeeds() {
    if (_selectedRole == 'participant') {
      return [
        NeedOption(
            id: 'mobility', title: 'Mobility Support', icon: Icons.accessible),
        NeedOption(
            id: 'communication', title: 'Communication', icon: Icons.chat),
        NeedOption(
            id: 'daily_living', title: 'Daily Living Skills', icon: Icons.home),
        NeedOption(
            id: 'employment', title: 'Employment Support', icon: Icons.work),
        NeedOption(
            id: 'social_community',
            title: 'Social & Community',
            icon: Icons.people),
        NeedOption(
            id: 'transport', title: 'Transport', icon: Icons.directions_car),
        NeedOption(
            id: 'education', title: 'Education & Training', icon: Icons.school),
        NeedOption(
            id: 'health',
            title: 'Health & Wellbeing',
            icon: Icons.health_and_safety),
      ];
    } else if (_selectedRole == 'provider') {
      return [
        NeedOption(
            id: 'client_management',
            title: 'Client Management',
            icon: Icons.people),
        NeedOption(
            id: 'scheduling', title: 'Scheduling', icon: Icons.calendar_today),
        NeedOption(
            id: 'billing', title: 'Billing & Claims', icon: Icons.receipt),
        NeedOption(id: 'compliance', title: 'Compliance', icon: Icons.verified),
        NeedOption(id: 'reporting', title: 'Reporting', icon: Icons.analytics),
        NeedOption(
            id: 'communication', title: 'Communication', icon: Icons.chat),
      ];
    } else {
      return [
        NeedOption(
            id: 'coordination',
            title: 'Care Coordination',
            icon: Icons.connect_without_contact),
        NeedOption(
            id: 'communication', title: 'Communication', icon: Icons.chat),
        NeedOption(
            id: 'planning', title: 'Planning Support', icon: Icons.event_note),
        NeedOption(id: 'advocacy', title: 'Advocacy', icon: Icons.campaign),
        NeedOption(
            id: 'information', title: 'Information Access', icon: Icons.info),
      ];
    }
  }

  String _getRoleTitle(final String roleId) {
    switch (roleId) {
      case 'participant':
        return 'NDIS Participant';
      case 'provider':
        return 'Service Provider';
      case 'supporter':
        return 'Family/Supporter';
      default:
        return 'Unknown';
    }
  }

  int _getEnabledAccessibilityCount() => _accessibilityPreferences.values
        .where((final enabled) => enabled == true)
        .length;
}

// Data models for onboarding
enum OnboardingStepType {
  welcome,
  roleSelection,
  needsAssessment,
  accessibilitySetup,
  permissions,
  completion,
}

class OnboardingStep {

  OnboardingStep({
    required this.type,
    required this.title,
    required this.description,
  });

  factory OnboardingStep.welcome() => OnboardingStep(
        type: OnboardingStepType.welcome,
        title: 'Welcome',
        description: 'Let\'s get you started with NDIS Connect',
      );

  factory OnboardingStep.roleSelection() => OnboardingStep(
        type: OnboardingStepType.roleSelection,
        title: 'Your Role',
        description: 'How will you be using NDIS Connect?',
      );

  factory OnboardingStep.needsAssessment() => OnboardingStep(
        type: OnboardingStepType.needsAssessment,
        title: 'Your Needs',
        description: 'What areas would you like support with?',
      );

  factory OnboardingStep.accessibilitySetup() => OnboardingStep(
        type: OnboardingStepType.accessibilitySetup,
        title: 'Accessibility',
        description: 'Customize the app to work best for you',
      );

  factory OnboardingStep.permissions() => OnboardingStep(
        type: OnboardingStepType.permissions,
        title: 'Permissions',
        description: 'Enable features for the best experience',
      );

  factory OnboardingStep.completion() => OnboardingStep(
        type: OnboardingStepType.completion,
        title: 'All Set!',
        description: 'Your personalized experience is ready',
      );
  final OnboardingStepType type;
  final String title;
  final String description;
}

class RoleOption {

  RoleOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class NeedOption {

  NeedOption({
    required this.id,
    required this.title,
    required this.icon,
  });
  final String id;
  final String title;
  final IconData icon;
}

class AccessibilityOption {

  AccessibilityOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
}

class PermissionItem {

  PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class FeaturePreview {

  FeaturePreview({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
}
