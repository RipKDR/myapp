import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Glassmorphism effects for 2025 modern UI design
class GlassmorphismEffects {
  /// Creates a glassmorphism container with blur and transparency
  static Widget glassContainer({
    required final Widget child,
    final double blur = 10.0,
    final double opacity = 0.1,
    final Color? color,
    final BorderRadius? borderRadius,
    final EdgeInsets? padding,
    final EdgeInsets? margin,
    final BoxBorder? border,
    final List<BoxShadow>? shadows,
  }) => Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withValues(alpha: opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
              boxShadow: shadows ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );

  /// Creates a glassmorphism card with subtle effects
  static Widget glassCard({
    required final Widget child,
    final VoidCallback? onTap,
    final double blur = 8.0,
    final double opacity = 0.15,
    final Color? color,
    final BorderRadius? borderRadius,
    final EdgeInsets? padding,
    final EdgeInsets? margin,
    final bool enableHover = true,
  }) => _GlassCard(
      onTap: onTap,
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      enableHover: enableHover,
      child: child,
    );

  /// Creates a glassmorphism navigation bar
  static Widget glassNavigationBar({
    required final List<Widget> children,
    final double blur = 15.0,
    final double opacity = 0.2,
    final Color? backgroundColor,
    final EdgeInsets? padding,
  }) => ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: children,
          ),
        ),
      ),
    );

  /// Creates a glassmorphism modal overlay
  static Widget glassModal({
    required final Widget child,
    final double blur = 20.0,
    final double opacity = 0.3,
    final Color? backgroundColor,
    final VoidCallback? onDismiss,
  }) => _GlassModal(
      blur: blur,
      opacity: opacity,
      backgroundColor: backgroundColor,
      onDismiss: onDismiss,
      child: child,
    );

  /// Creates a glassmorphism floating action button
  static Widget glassFloatingActionButton({
    required final VoidCallback onPressed,
    required final Widget child,
    final double blur = 12.0,
    final double opacity = 0.2,
    final Color? backgroundColor,
    final String? tooltip,
  }) => _GlassFloatingActionButton(
      onPressed: onPressed,
      blur: blur,
      opacity: opacity,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      child: child,
    );
}

/// Glassmorphism card with hover effects
class _GlassCard extends StatefulWidget {

  const _GlassCard({
    required this.child,
    this.onTap,
    this.blur = 8.0,
    this.opacity = 0.15,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.enableHover = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool enableHover;

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity * 1.5,
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
    if (!widget.enableHover) return;

    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (final context, final child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onHover: _handleHover,
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(16),
                    child: Container(
                      padding: widget.padding ?? const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (widget.color ?? Colors.white)
                            .withValues(alpha: _opacityAnimation.value),
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Colors.white.withValues(alpha: _isHovered ? 0.3 : 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: AppTheme.calmingBlue.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                        ],
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
}

/// Glassmorphism modal overlay
class _GlassModal extends StatelessWidget {

  const _GlassModal({
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.3,
    this.backgroundColor,
    this.onDismiss,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;

  @override
  Widget build(final BuildContext context) => Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap from bubbling up
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: (backgroundColor ?? Colors.white)
                          .withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
}

/// Glassmorphism floating action button
class _GlassFloatingActionButton extends StatefulWidget {

  const _GlassFloatingActionButton({
    required this.onPressed,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.tooltip,
  });
  final VoidCallback onPressed;
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final String? tooltip;

  @override
  State<_GlassFloatingActionButton> createState() =>
      _GlassFloatingActionButtonState();
}

class _GlassFloatingActionButtonState extends State<_GlassFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity * 1.5,
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
    _controller.forward();
  }

  void _handleTapUp(final TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (final context, final child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (widget.backgroundColor ?? AppTheme.calmingBlue)
                          .withValues(alpha: _opacityAnimation.value),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(child: widget.child),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
}

/// Glassmorphism app bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.blur = 15.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.centerTitle = false,
  });
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final bool centerTitle;

  @override
  Widget build(final BuildContext context) => ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          backgroundColor:
              (backgroundColor ?? Colors.white).withValues(alpha: opacity),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Glassmorphism bottom sheet
class GlassBottomSheet extends StatelessWidget {

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.borderRadius,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(final BuildContext context) => ClipRRect(
      borderRadius:
          borderRadius ?? const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
            borderRadius: borderRadius ??
                const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );

  /// Show glassmorphism bottom sheet
  static Future<T?> show<T>({
    required final BuildContext context,
    required final Widget child,
    final double blur = 15.0,
    final double opacity = 0.2,
    final Color? backgroundColor,
    final BorderRadius? borderRadius,
    final bool isDismissible = true,
    final bool enableDrag = true,
  }) => showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (final context) => GlassBottomSheet(
        blur: blur,
        opacity: opacity,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
}
