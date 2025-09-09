import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'responsive_layout.dart';

/// Modern dashboard card with clean design and smooth animations
class ModernDashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final String? trend;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLoading;
  final bool showTrend;
  final TrendDirection? trendDirection;
  final List<Widget>? actions;

  const ModernDashboardCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trend,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.trailing,
    this.isLoading = false,
    this.showTrend = false,
    this.trendDirection,
    this.actions,
  });

  @override
  State<ModernDashboardCard> createState() => _ModernDashboardCardState();
}

enum TrendDirection { up, down, neutral }

class _ModernDashboardCardState extends State<ModernDashboardCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(ModernDashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (widget.onTap == null) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverController,
        _pressController,
        _loadingController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: _handleHoverEnter,
            onExit: _handleHoverExit,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withOpacity(0.1),
                      blurRadius: 10 + _elevationAnimation.value,
                      offset: Offset(0, 4 + _elevationAnimation.value / 2),
                    ),
                  ],
                  border: Border.all(
                    color: scheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background gradient
                      if (_isHovered)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (widget.iconColor ?? scheme.primary)
                                    .withOpacity(0.05),
                                (widget.iconColor ?? scheme.primary)
                                    .withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                      // Main content
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              children: [
                                // Icon container
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (widget.iconColor ?? scheme.primary)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          (widget.iconColor ?? scheme.primary)
                                              .withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    size: isMobile ? 24 : 28,
                                    color: widget.iconColor ?? scheme.primary,
                                  ),
                                ),

                                const Spacer(),

                                // Trailing widget or trend
                                if (widget.trailing != null)
                                  widget.trailing!
                                else if (widget.showTrend &&
                                    widget.trend != null)
                                  _TrendIndicator(
                                    trend: widget.trend!,
                                    direction: widget.trendDirection ??
                                        TrendDirection.neutral,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Title
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Subtitle
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            // Value
                            if (widget.value != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                widget.value!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: widget.iconColor ?? scheme.primary,
                                    ),
                              ),
                            ],

                            // Actions
                            if (widget.actions != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: widget.actions!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Loading overlay
                      if (widget.isLoading)
                        Container(
                          decoration: BoxDecoration(
                            color: scheme.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: widget.iconColor ?? scheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Trend indicator widget
class _TrendIndicator extends StatelessWidget {
  final String trend;
  final TrendDirection direction;

  const _TrendIndicator({
    required this.trend,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color color;
    IconData icon;

    switch (direction) {
      case TrendDirection.up:
        color = Colors.green;
        icon = Icons.trending_up;
        break;
      case TrendDirection.down:
        color = Colors.red;
        icon = Icons.trending_down;
        break;
      case TrendDirection.neutral:
        color = scheme.onSurfaceVariant;
        icon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            trend,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Quick action button for dashboard cards
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: color ?? scheme.primary,
        ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color ?? scheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(0, 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
