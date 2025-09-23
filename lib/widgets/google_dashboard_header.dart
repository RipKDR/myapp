import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/gamification_controller.dart';
import '../theme/google_theme.dart';
import 'responsive_layout.dart';

/// Google-style dashboard header with clean design and user info
class GoogleDashboardHeader extends StatefulWidget {

  const GoogleDashboardHeader({
    super.key,
    required this.greeting,
    this.subtitle,
    this.avatar,
    this.actions,
    this.showStats = true,
    this.onProfileTap,
  });
  final String greeting;
  final String? subtitle;
  final Widget? avatar;
  final List<Widget>? actions;
  final bool showStats;
  final VoidCallback? onProfileTap;

  @override
  State<GoogleDashboardHeader> createState() => _GoogleDashboardHeaderState();
}

class _GoogleDashboardHeaderState extends State<GoogleDashboardHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = context.isMobile;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (final context, final child) => FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GoogleTheme.googleBlue.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with greeting and profile
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting
                            Text(
                              _getGreeting(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Profile section
                      Row(
                        children: [
                          if (widget.actions != null) ...widget.actions!,
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onProfileTap,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      GoogleTheme.googleBlue.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: widget.avatar ??
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        GoogleTheme.googleBlue.withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.person,
                                      color: GoogleTheme.googleBlue,
                                      size: 24,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Stats section
                  if (widget.showStats) ...[
                    const SizedBox(height: 24),
                    _buildStatsSection(context),
                  ],
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildStatsSection(final BuildContext context) {
    final gamification = context.watch<GamificationController>();
    final isMobile = context.isMobile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GoogleTheme.googleGrey.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: _buildStatItems(gamification),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildStatItems(gamification),
            ),
    );
  }

  List<Widget> _buildStatItems(final GamificationController gamification) => [
      _StatItem(
        icon: Icons.local_fire_department,
        label: 'Daily Streak',
        value: '${gamification.streakDays}',
        color: GoogleTheme.googleRed,
        subtitle: 'days',
      ),
      if (context.isMobile)
        const SizedBox(height: 16)
      else
        const SizedBox(width: 24),
      _StatItem(
        icon: Icons.emoji_events,
        label: 'Total Points',
        value: '${gamification.points}',
        color: GoogleTheme.googleYellow,
        subtitle: 'earned',
      ),
      if (context.isMobile)
        const SizedBox(height: 16)
      else
        const SizedBox(width: 24),
      const _StatItem(
        icon: Icons.trending_up,
        label: 'This Week',
        value: '3',
        color: GoogleTheme.googleGreen,
        subtitle: 'sessions',
      ),
    ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    return '$timeGreeting, ${widget.greeting}';
  }
}

class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 24 : 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Google-style quick actions bar
class GoogleQuickActions extends StatelessWidget {

  const GoogleQuickActions({
    super.key,
    required this.actions,
    this.padding,
  });
  final List<QuickAction> actions;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: actions.map((final action) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: action.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: action.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )).toList(),
      ),
    );
  }
}

/// Quick action data model
class QuickAction {

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
