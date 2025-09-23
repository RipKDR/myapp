import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Advanced card component with sophisticated animations, accessibility features,
/// and responsive design patterns following Material 3 design principles.
class AdvancedCard extends StatefulWidget {

  const AdvancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.semanticLabel,
    this.tooltip,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.badge,
    this.animationDuration = AnimationDuration.normal,
    this.enableHoverEffects = true,
    this.enablePressEffects = true,
    this.enableFocusEffects = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isLoading;
  final bool isDisabled;
  final String? semanticLabel;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Widget? badge;
  final AnimationDuration animationDuration;
  final bool enableHoverEffects;
  final bool enablePressEffects;
  final bool enableFocusEffects;

  @override
  State<AdvancedCard> createState() => _AdvancedCardState();
}

enum AnimationDuration { fast, normal, slow }

class _AdvancedCardState extends State<AdvancedCard>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late AnimationController _focusController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _borderAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final duration = _getDuration();

    _pressController = AnimationController(
      duration: duration,
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: Duration(milliseconds: duration.inMilliseconds + 100),
      vsync: this,
    );

    _focusController = AnimationController(
      duration: Duration(milliseconds: duration.inMilliseconds + 50),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _borderAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  Duration _getDuration() {
    switch (widget.animationDuration) {
      case AnimationDuration.fast:
        return const Duration(milliseconds: 100);
      case AnimationDuration.normal:
        return const Duration(milliseconds: 150);
      case AnimationDuration.slow:
        return const Duration(milliseconds: 200);
    }
  }

  @override
  void didUpdateWidget(final AdvancedCard oldWidget) {
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
    _pressController.dispose();
    _hoverController.dispose();
    _focusController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(final TapDownDetails details) {
    if (widget.isDisabled || !widget.enablePressEffects) return;
    
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(final TapUpDetails details) {
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

  void _handleHoverEnter(final PointerEnterEvent event) {
    if (widget.isDisabled || !widget.enableHoverEffects) return;
    
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit(final PointerExitEvent event) {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  void _handleFocusChange(final bool hasFocus) {
    if (widget.isDisabled || !widget.enableFocusEffects) return;
    
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHighContrast = Theme.of(context).brightness == Brightness.light
        ? scheme.primary == const Color(0xFF000080)
        : scheme.primary == const Color(0xFF3B82F6);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pressController,
        _hoverController,
        _focusController,
        _loadingController,
      ]),
      builder: (final context, final child) {
        final scale = widget.enablePressEffects ? _scaleAnimation.value : 1.0;
        final elevation = (widget.elevation ?? 0) + 
            (widget.enableHoverEffects ? _elevationAnimation.value : 0);
        final borderOpacity = widget.enableFocusEffects ? _borderAnimation.value : 0.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Stack(
              children: [
                // Main card
                Semantics(
                  button: widget.onTap != null,
                  label: widget.semanticLabel,
                  child: Tooltip(
                    message: widget.tooltip ?? '',
                    child: Focus(
                      onFocusChange: _handleFocusChange,
                      child: MouseRegion(
                        onEnter: _handleHoverEnter,
                        onExit: _handleHoverExit,
                        child: Material(
                          color: widget.backgroundColor ?? 
                              (widget.isSelected 
                                  ? scheme.primaryContainer 
                                  : scheme.surface),
                          elevation: elevation,
                          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.borderColor ??
                                    (widget.isSelected
                                        ? scheme.primary
                                        : scheme.primary.withValues(alpha: borderOpacity)),
                                width: widget.isSelected || borderOpacity > 0 
                                    ? (isHighContrast ? 3 : 2) 
                                    : 0,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                              onTap: widget.isDisabled ? null : widget.onTap,
                              onLongPress: widget.isDisabled ? null : widget.onLongPress,
                              onTapDown: _handleTapDown,
                              onTapUp: _handleTapUp,
                              onTapCancel: _handleTapCancel,
                              child: Opacity(
                                opacity: widget.isDisabled ? 0.6 : 1.0,
                                child: Container(
                                  padding: widget.padding ?? const EdgeInsets.all(16),
                                  child: widget.child,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Loading overlay
                if (widget.isLoading)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.8),
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Badge
                if (widget.badge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: widget.badge!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Status badge for advanced cards
class StatusBadge extends StatelessWidget {

  const StatusBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.style = BadgeStyle.filled,
  });
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final BadgeStyle style;

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style == BadgeStyle.filled 
            ? (backgroundColor ?? scheme.primary)
            : Colors.transparent,
        border: style == BadgeStyle.outlined 
            ? Border.all(color: backgroundColor ?? scheme.primary)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: style == BadgeStyle.filled 
                  ? (textColor ?? scheme.onPrimary)
                  : (textColor ?? scheme.primary),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: style == BadgeStyle.filled 
                  ? (textColor ?? scheme.onPrimary)
                  : (textColor ?? scheme.primary),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeStyle { filled, outlined }
