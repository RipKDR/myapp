import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import '../theme/app_theme.dart';

/// Modern dashboard layout with responsive grid and smooth animations
class ModernDashboardLayout extends StatefulWidget {

  const ModernDashboardLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.header,
    required this.children,
    this.padding,
    this.floatingActionButton,
    this.actions,
    this.showAppBar = true,
    this.backgroundColor,
  });
  final String title;
  final String? subtitle;
  final Widget? header;
  final List<Widget> children;
  final EdgeInsets? padding;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showAppBar;
  final Color? backgroundColor;

  @override
  State<ModernDashboardLayout> createState() => _ModernDashboardLayoutState();
}

class _ModernDashboardLayoutState extends State<ModernDashboardLayout>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < widget.children.length; i++) {
      final delay = i * 0.1;

      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 0.8 + delay, curve: Curves.easeOutCubic),
        )),
      );

      _fadeAnimations.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 0.6 + delay, curve: Curves.easeOut),
        )),
      );
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? scheme.surface,
      appBar: widget.showAppBar ? _buildAppBar(context) : null,
      floatingActionButton: widget.floatingActionButton,
      body: ResponsiveContainer(
        padding: widget.padding ?? EdgeInsets.zero,
        child: CustomScrollView(
          slivers: [
            // Header section
            if (widget.header != null)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (final context, final child) => FadeTransition(
                      opacity: _fadeAnimations.isNotEmpty
                          ? _fadeAnimations[0]
                          : const AlwaysStoppedAnimation(1),
                      child: SlideTransition(
                        position: _slideAnimations.isNotEmpty
                            ? _slideAnimations[0]
                            : const AlwaysStoppedAnimation(Offset.zero),
                        child: widget.header,
                      ),
                    ),
                ),
              ),

            // Dashboard grid
            ResponsiveSliverGrid(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              largeDesktopColumns: 4,
              padding: const EdgeInsets.all(16),
              children: widget.children.asMap().entries.map((final entry) {
                final index = entry.key;
                final child = entry.value;

                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (final context, _) {
                    final slideIndex =
                        index < _slideAnimations.length ? index : 0;
                    final fadeIndex =
                        index < _fadeAnimations.length ? index : 0;

                    return FadeTransition(
                      opacity: _fadeAnimations.isNotEmpty
                          ? _fadeAnimations[fadeIndex]
                          : const AlwaysStoppedAnimation(1),
                      child: SlideTransition(
                        position: _slideAnimations.isNotEmpty
                            ? _slideAnimations[slideIndex]
                            : const AlwaysStoppedAnimation(Offset.zero),
                        child: child,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.ndisBlue.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
      actions: widget.actions,
      centerTitle: false,
    );
  }
}

/// Responsive sliver grid for dashboard layouts
class ResponsiveSliverGrid extends StatelessWidget {

  const ResponsiveSliverGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
    this.childAspectRatio,
  });
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final double? childAspectRatio;

  @override
  Widget build(final BuildContext context) => SliverLayoutBuilder(
      builder: (final context, final constraints) {
        final breakpoint =
            ScreenBreakpoint.fromWidth(constraints.crossAxisExtent);

        int columns;
        switch (breakpoint) {
          case ScreenBreakpoint.mobile:
            columns = mobileColumns ?? 1;
            break;
          case ScreenBreakpoint.tablet:
            columns = tabletColumns ?? mobileColumns ?? 2;
            break;
          case ScreenBreakpoint.desktop:
            columns = desktopColumns ?? tabletColumns ?? mobileColumns ?? 3;
            break;
          case ScreenBreakpoint.largeDesktop:
            columns = largeDesktopColumns ??
                desktopColumns ??
                tabletColumns ??
                mobileColumns ??
                4;
            break;
        }

        return SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: childAspectRatio ?? _getAspectRatio(breakpoint),
            ),
            delegate: SliverChildBuilderDelegate(
              (final context, final index) => children[index],
              childCount: children.length,
            ),
          ),
        );
      },
    );

  double _getAspectRatio(final ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 1.4;
      case ScreenBreakpoint.tablet:
        return 1.2;
      case ScreenBreakpoint.desktop:
      case ScreenBreakpoint.largeDesktop:
        return 1.1;
    }
  }
}

/// Dashboard stats overview widget
class DashboardStatsOverview extends StatelessWidget {

  const DashboardStatsOverview({
    super.key,
    required this.stats,
    this.padding,
  });
  final List<DashboardStat> stats;
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) => Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );

  Widget _buildMobileLayout(final BuildContext context) => Column(
      children: stats
          .map(
            (final stat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StatCard(stat: stat),
            ),
          )
          .toList(),
    );

  Widget _buildTabletLayout(final BuildContext context) => Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats
          .map(
            (final stat) => SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: _StatCard(stat: stat),
            ),
          )
          .toList(),
    );

  Widget _buildDesktopLayout(final BuildContext context) => Row(
      children: stats
          .map(
            (final stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _StatCard(stat: stat),
              ),
            ),
          )
          .toList(),
    );
}

/// Individual stat card
class _StatCard extends StatelessWidget {

  const _StatCard({required this.stat});
  final DashboardStat stat;

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stat.icon,
                color: stat.color ?? scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stat.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: stat.color ?? scheme.primary,
                ),
          ),
          if (stat.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              stat.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dashboard stat data model
class DashboardStat {

  const DashboardStat({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
  });
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
}
