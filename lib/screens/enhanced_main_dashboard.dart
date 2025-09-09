import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/gamification_controller.dart';
import '../theme/google_theme.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/advanced_dashboard_components.dart';
import '../widgets/trending_2025_components.dart';
import '../widgets/neo_brutalism_components.dart';
import '../widgets/advanced_glassmorphism_2025.dart';
import '../widgets/cinematic_data_storytelling.dart';
import '../routes.dart';
import '../services/ai_personalization_service.dart';

/// Enhanced main dashboard with 2025 design trends
/// Features advanced data visualization, micro-interactions, and personalized content
class EnhancedMainDashboard extends StatefulWidget {
  const EnhancedMainDashboard({super.key});

  @override
  State<EnhancedMainDashboard> createState() => _EnhancedMainDashboardState();
}

class _EnhancedMainDashboardState extends State<EnhancedMainDashboard>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _fabController;

  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  // Subtle personalization
  final AIPersonalizationService _ai = AIPersonalizationService();
  PersonalizedContent? _dailyTip;
  PersonalizedRecommendation? _primaryRec;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadPersonalization();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  Future<void> _loadPersonalization() async {
    try {
      await _ai.initialize();
      final tip = _ai.getPersonalizedContent('tips');
      final recs = _ai.getPersonalizedRecommendations();
      PersonalizedRecommendation? chosen;
      if (recs.isNotEmpty) {
        chosen = recs.firstWhere(
          (r) => r.priority == RecommendationPriority.high,
          orElse: () => recs.first,
        );
      }
      if (mounted) {
        setState(() {
          _dailyTip = tip;
          _primaryRec = chosen;
        });
      }
    } catch (_) {
      // keep UI clean on failure
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showFab) {
        setState(() => _showFab = shouldShow);
        if (shouldShow) {
          _fabController.forward();
        } else {
          _fabController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // final isMobile = context.isMobile; // not used in this scope

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: GoogleTheme.googleBlue,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Enhanced app bar
            _buildSliverAppBar(context),

            // Main content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
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
                      child: _buildMainContent(context),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating action button
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return ScaleTransition(
            scale: _fabController,
            child: FloatingActionButton.extended(
              onPressed: _showQuickActions,
              backgroundColor: GoogleTheme.googleBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Quick Action'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gamification = context.watch<GamificationController>();

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 1,

      // Leading
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: GoogleTheme.googleBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.accessibility_new,
            color: GoogleTheme.googleBlue,
            size: 20,
          ),
        ),
      ),

      // Actions
      actions: [
        IconButton(
          onPressed: _showNotifications,
          icon: Badge(
            isLabelVisible: true,
            label: const Text('3'),
            child: const Icon(Icons.notifications_outlined),
          ),
          tooltip: 'Notifications',
        ),
        IconButton(
          onPressed: _showProfile,
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'Profile',
        ),
        const SizedBox(width: 8),
      ],

      // Flexible space
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _headerController,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GoogleTheme.googleBlue.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Here\'s what\'s happening with your NDIS journey',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    // Subtle daily tip (professional, unobtrusive)
                    if (_dailyTip != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: GoogleTheme.googleBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: GoogleTheme.googleBlue.withOpacity(0.12)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tips_and_updates,
                                size: 16, color: GoogleTheme.googleBlue),
                            const SizedBox(width: 8),
                            Text(
                              _dailyTip!.content,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Quick stats
                    Row(
                      children: [
                        _buildQuickStat(
                          Icons.local_fire_department,
                          '${gamification.streakDays}',
                          'Day Streak',
                          GoogleTheme.googleRed,
                        ),
                        const SizedBox(width: 24),
                        _buildQuickStat(
                          Icons.emoji_events,
                          '${gamification.points}',
                          'Points',
                          GoogleTheme.googleYellow,
                        ),
                        const SizedBox(width: 24),
                        _buildQuickStat(
                          Icons.trending_up,
                          '85%',
                          'Progress',
                          GoogleTheme.googleGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStat(
      IconData icon, String value, String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final isMobile = context.isMobile;

    return ResponsivePadding(
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key metrics
          _buildMetricsSection(context),

          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActionsSection(context),

          const SizedBox(height: 24),

          // Main content grid
          if (isMobile)
            _buildMobileLayout(context)
          else
            _buildDesktopLayout(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Neo-brutalism header
        NeoBrutalismComponents.buildStrikingHeader(
          context: context,
          title: 'Overview',
          subtitle: 'Your NDIS journey at a glance',
          backgroundColor: GoogleTheme.googleBlue,
          trailing: Trending2025Components.buildDarkModeToggle(
            context: context,
            isDark: Theme.of(context).brightness == Brightness.dark,
            onChanged: (isDark) {
              final settings = context.read<SettingsController>();
              settings.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
            },
            isAccessible: true,
          ),
        ),

        const SizedBox(height: 24),

        // Animated data stories
        Column(
          children: [
            CinematicDataStoryTelling.buildAnimatedDataStory(
              context: context,
              title: 'Budget Remaining',
              value: '\$18,400',
              previousValue: '\$19,200',
              trendDescription: 'You\'re managing your budget wisely',
              icon: Icons.account_balance_wallet,
              color: GoogleTheme.googleGreen,
              showCelebration: false,
            ),
            const SizedBox(height: 16),
            CinematicDataStoryTelling.buildAnimatedDataStory(
              context: context,
              title: 'Sessions Completed',
              value: '8 of 12',
              previousValue: '6 of 12',
              trendDescription: 'Great progress on your goals!',
              icon: Icons.trending_up,
              color: GoogleTheme.ndisTeal,
              showCelebration: true,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Glassmorphism metrics grid
        ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 4,
          desktopColumns: 4,
          spacing: 16,
          children: [
            AdvancedGlassmorphism2025.buildInteractiveGlassCard(
              context: context,
              child: NeoBrutalismComponents.buildBrutalistMetricCard(
                context: context,
                title: 'Budget',
                value: '\$18.4K',
                unit: 'AUD',
                icon: Icons.account_balance_wallet,
                accentColor: GoogleTheme.googleGreen,
                onTap: () => Navigator.pushNamed(context, Routes.budget),
              ),
              onTap: () => Navigator.pushNamed(context, Routes.budget),
              accentColor: GoogleTheme.googleGreen,
            ),
            AdvancedGlassmorphism2025.buildInteractiveGlassCard(
              context: context,
              child: NeoBrutalismComponents.buildBrutalistMetricCard(
                context: context,
                title: 'Sessions',
                value: '3',
                unit: 'Week',
                icon: Icons.event,
                accentColor: GoogleTheme.googleBlue,
                onTap: () => Navigator.pushNamed(context, Routes.calendar),
              ),
              onTap: () => Navigator.pushNamed(context, Routes.calendar),
              accentColor: GoogleTheme.googleBlue,
            ),
            AdvancedGlassmorphism2025.buildInteractiveGlassCard(
              context: context,
              child: NeoBrutalismComponents.buildBrutalistMetricCard(
                context: context,
                title: 'Goals',
                value: '67',
                unit: '%',
                icon: Icons.checklist,
                accentColor: GoogleTheme.ndisTeal,
                onTap: () => Navigator.pushNamed(context, '/checklist'),
              ),
              onTap: () => Navigator.pushNamed(context, '/checklist'),
              accentColor: GoogleTheme.ndisTeal,
            ),
            AdvancedGlassmorphism2025.buildInteractiveGlassCard(
              context: context,
              child: NeoBrutalismComponents.buildBrutalistMetricCard(
                context: context,
                title: 'Network',
                value: '5',
                unit: 'People',
                icon: Icons.people,
                accentColor: GoogleTheme.ndisPurple,
                onTap: () => Navigator.pushNamed(context, '/circle'),
              ),
              onTap: () => Navigator.pushNamed(context, '/circle'),
              accentColor: GoogleTheme.ndisPurple,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Contextual visual cues
        CinematicDataStoryTelling.buildContextualVisualCue(
          context: context,
          message: 'You have 3 upcoming sessions this week. Stay on track!',
          type: CueType.attention,
          onAction: () => Navigator.pushNamed(context, Routes.calendar),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Trending2025Components.buildInteractiveButton(
              label: 'View All',
              onPressed: _showAllActions,
              isPrimary: false,
              backgroundColor: GoogleTheme.googleBlue,
              hasRippleEffect: true,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Voice interface integration
        Trending2025Components.buildVoiceInterface(
          context: context,
          isListening: false,
          onVoiceToggle: () {
            // TODO: Implement voice commands
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice commands coming soon!')),
            );
          },
          transcribedText: null,
          isAccessible: true,
        ),

        const SizedBox(height: 20),

        // Enhanced action buttons with glassmorphism
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // One tasteful personalized quick action (optional)
              if (_primaryRec != null) ...[
                SizedBox(
                  width: 120,
                  child: AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                    context: context,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconForRec(_primaryRec!),
                          color: GoogleTheme.googleBlue,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _primaryRec!.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _handlePersonalizedAction(_primaryRec!),
                    accentColor: GoogleTheme.googleBlue,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              SizedBox(
                width: 120,
                child: AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: GoogleTheme.googleBlue,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Book Session',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, Routes.calendar),
                  accentColor: GoogleTheme.googleBlue,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: GoogleTheme.googleGreen,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Receipt',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, Routes.budget),
                  accentColor: GoogleTheme.googleGreen,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: GoogleTheme.ndisTeal,
                            size: 32,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: GoogleTheme.googleRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask Assistant',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                  accentColor: GoogleTheme.ndisTeal,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: GoogleTheme.ndisPurple,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find Services',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, '/map'),
                  accentColor: GoogleTheme.ndisPurple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildActivityFeed(context),
        const SizedBox(height: 24),
        _buildUpcomingEvents(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildActivityFeed(context),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildUpcomingEvents(context),
        ),
      ],
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  tooltip: 'Mark all as read',
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.1),
          ),
          ...List.generate(5, (index) {
            return ActivityFeedItem(
              icon: _getActivityIcon(index),
              iconColor: _getActivityColor(index),
              title: _getActivityTitle(index),
              subtitle: _getActivitySubtitle(index),
              timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
              isRead: index > 1,
              onTap: () => _handleActivityTap(index),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: _showAllActivity,
                child: const Text('View All Activity'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Upcoming Events',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.calendar),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  tooltip: 'View calendar',
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.1),
          ),
          ...List.generate(3, (index) {
            return _buildEventItem(context, index);
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.calendar),
                child: const Text('View All Events'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final events = [
      {
        'title': 'Physiotherapy Session',
        'time': 'Tomorrow 2:00 PM',
        'location': 'FlexCare Physio',
        'color': GoogleTheme.googleBlue,
      },
      {
        'title': 'OT Assessment',
        'time': 'Friday 10:00 AM',
        'location': 'Ability OT Services',
        'color': GoogleTheme.googleGreen,
      },
      {
        'title': 'Plan Review Meeting',
        'time': 'Next Week',
        'location': 'NDIS Office',
        'color': GoogleTheme.ndisTeal,
      },
    ];

    final event = events[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: event['color'] as Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${event['time']} • ${event['location']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEventOptions(index),
            icon: const Icon(Icons.more_vert, size: 18),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _getActivityIcon(int index) {
    const icons = [
      Icons.event_available,
      Icons.receipt,
      Icons.people,
      Icons.notification_important,
      Icons.check_circle,
    ];
    return icons[index % icons.length];
  }

  Color _getActivityColor(int index) {
    const colors = [
      GoogleTheme.googleBlue,
      GoogleTheme.googleGreen,
      GoogleTheme.ndisTeal,
      GoogleTheme.googleRed,
      GoogleTheme.ndisPurple,
    ];
    return colors[index % colors.length];
  }

  String _getActivityTitle(int index) {
    const titles = [
      'Session Confirmed',
      'Receipt Processed',
      'New Team Member Added',
      'Payment Due Reminder',
      'Goal Completed',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    const subtitles = [
      'Your physiotherapy session for tomorrow has been confirmed',
      'Your receipt for \$85 has been processed and approved',
      'Sarah Johnson joined your support circle',
      'Your next payment of \$150 is due in 3 days',
      'Congratulations on completing your mobility goal!',
    ];
    return subtitles[index % subtitles.length];
  }

  // Event handlers
  Future<void> _handleRefresh() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 2));

    // Trigger rebuild to refresh data
    if (mounted) {
      setState(() {});
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  Widget _buildQuickActionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          ResponsiveGrid(
            mobileColumns: 3,
            tabletColumns: 4,
            desktopColumns: 4,
            spacing: 16,
            children: [
              QuickActionCard(
                icon: Icons.add_circle_outline,
                title: 'Book Session',
                color: GoogleTheme.googleBlue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.calendar);
                },
              ),
              QuickActionCard(
                icon: Icons.receipt_long,
                title: 'Add Receipt',
                color: GoogleTheme.googleGreen,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.budget);
                },
              ),
              QuickActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Ask Assistant',
                color: GoogleTheme.ndisTeal,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              QuickActionCard(
                icon: Icons.map_outlined,
                title: 'Find Services',
                color: GoogleTheme.ndisPurple,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/map');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showNotifications() {
    // TODO: Implement notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon')),
    );
  }

  void _showProfile() {
    // TODO: Implement profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile feature coming soon')),
    );
  }

  void _showAllActions() {
    // TODO: Implement all actions view
  }

  void _markAllAsRead() {
    // TODO: Implement mark all as read
    HapticFeedback.lightImpact();
  }

  void _showAllActivity() {
    // TODO: Implement activity history
  }

  void _handleActivityTap(int index) {
    // TODO: Handle activity item tap
    HapticFeedback.lightImpact();
  }

  void _showEventOptions(int index) {
    // TODO: Show event options
  }

  // Personalized quick action helpers
  IconData _iconForRec(PersonalizedRecommendation rec) {
    switch (rec.action) {
      case 'view_calendar':
        return Icons.calendar_today;
      case 'view_budget':
      case 'update_budget':
        return Icons.account_balance_wallet;
      case 'view_goal_progress':
        return Icons.checklist;
      case 'enable_high_contrast':
        return Icons.contrast;
      default:
        return Icons.star_outline;
    }
  }

  void _handlePersonalizedAction(PersonalizedRecommendation rec) {
    switch (rec.action) {
      case 'view_calendar':
        Navigator.pushNamed(context, Routes.calendar);
        break;
      case 'view_budget':
      case 'update_budget':
        Navigator.pushNamed(context, Routes.budget);
        break;
      case 'view_goal_progress':
        Navigator.pushNamed(context, '/checklist');
        break;
      case 'enable_high_contrast':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'High contrast setting available in Profile > Accessibility')),
        );
        break;
      default:
        break;
    }
  }
}
