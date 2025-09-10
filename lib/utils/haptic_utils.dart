import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

/// Utility class for managing haptic feedback with accessibility considerations
class HapticUtils {
  /// Provides light haptic feedback for button taps and selections
  static Future<void> lightImpact(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Provides medium haptic feedback for important interactions
  static Future<void> mediumImpact(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Provides heavy haptic feedback for critical actions
  static Future<void> heavyImpact(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Provides selection feedback for sliders and pickers
  static Future<void> selectionClick(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Provides error haptic feedback pattern
  static Future<void> errorFeedback(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    }
  }

  /// Provides success haptic feedback pattern
  static Future<void> successFeedback(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    }
  }

  /// Provides notification haptic feedback
  static Future<void> notificationFeedback(final BuildContext context) async {
    final settings = context.read<SettingsController>();
    if (!settings.reduceMotion && !settings.disableHaptics) {
      await HapticFeedback.mediumImpact();
    }
  }
}

/// Enhanced button widget with haptic feedback and micro-interactions
class HapticButton extends StatefulWidget {

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.isDestructive = false,
    this.isPrimary = false,
    this.semanticLabel,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool isDestructive;
  final bool isPrimary;
  final String? semanticLabel;

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) * 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(final TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      HapticUtils.lightImpact(context);
    }
  }

  void _handleTapUp(final TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      if (widget.isDestructive) {
        HapticUtils.heavyImpact(context);
      } else if (widget.isPrimary) {
        HapticUtils.mediumImpact(context);
      } else {
        HapticUtils.lightImpact(context);
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.onPressed != null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (final context, final child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              color: widget.backgroundColor ??
                  (widget.isPrimary
                      ? colorScheme.primary
                      : widget.isDestructive
                          ? colorScheme.error
                          : colorScheme.surface),
              child: InkWell(
                onTap: widget.onPressed != null ? _handleTap : null,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: DefaultTextStyle(
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: widget.foregroundColor ??
                          (widget.isPrimary
                              ? colorScheme.onPrimary
                              : widget.isDestructive
                                  ? colorScheme.onError
                                  : colorScheme.onSurface),
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
      ),
    );
  }
}

/// Enhanced card widget with subtle hover and press animations
class InteractiveCard extends StatefulWidget {

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.enableHoverEffect = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableHoverEffect;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 1.0,
      end: (widget.elevation ?? 1.0) * 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(final bool isHovered) {
    if (!widget.enableHoverEffect) return;

    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      HapticUtils.lightImpact(context);
      widget.onTap!();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (final context, final child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              color: widget.backgroundColor ?? colorScheme.surface,
              child: InkWell(
                onTap: widget.onTap != null ? _handleTap : null,
                onHover: _handleHover,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
    );
  }
}
