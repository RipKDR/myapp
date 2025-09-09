import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Glassmorphism effects for 2025 modern UI design
class GlassmorphismEffects {
  /// Creates a glassmorphism container with blur and transparency
  static Widget glassContainer({
    required Widget child,
    double blur = 10.0,
    double opacity = 0.1,
    Color? color,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxBorder? border,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
              boxShadow: shadows ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
  }

  /// Creates a glassmorphism card with subtle effects
  static Widget glassCard({
    required Widget child,
    VoidCallback? onTap,
    double blur = 8.0,
    double opacity = 0.15,
    Color? color,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool enableHover = true,
  }) {
    return _GlassCard(
      child: child,
      onTap: onTap,
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      enableHover: enableHover,
    );
  }

  /// Creates a glassmorphism navigation bar
  static Widget glassNavigationBar({
    required List<Widget> children,
    double blur = 15.0,
    double opacity = 0.2,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withOpacity(opacity),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
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
  }

  /// Creates a glassmorphism modal overlay
  static Widget glassModal({
    required Widget child,
    double blur = 20.0,
    double opacity = 0.3,
    Color? backgroundColor,
    VoidCallback? onDismiss,
  }) {
    return _GlassModal(
      child: child,
      blur: blur,
      opacity: opacity,
      backgroundColor: backgroundColor,
      onDismiss: onDismiss,
    );
  }

  /// Creates a glassmorphism floating action button
  static Widget glassFloatingActionButton({
    required VoidCallback onPressed,
    required Widget child,
    double blur = 12.0,
    double opacity = 0.2,
    Color? backgroundColor,
    String? tooltip,
  }) {
    return _GlassFloatingActionButton(
      onPressed: onPressed,
      child: child,
      blur: blur,
      opacity: opacity,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
    );
  }
}

/// Glassmorphism card with hover effects
class _GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool enableHover;

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
      begin: 1.0,
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

  void _handleHover(bool isHovered) {
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
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
                            .withOpacity(_opacityAnimation.value),
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Colors.white.withOpacity(_isHovered ? 0.3 : 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: AppTheme.calmingBlue.withOpacity(0.2),
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
        );
      },
    );
  }
}

/// Glassmorphism modal overlay
class _GlassModal extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;

  const _GlassModal({
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.3,
    this.backgroundColor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap from bubbling up
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (backgroundColor ?? Colors.white)
                          .withOpacity(opacity),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
}

/// Glassmorphism floating action button
class _GlassFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final String? tooltip;

  const _GlassFloatingActionButton({
    required this.onPressed,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.tooltip,
  });

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
      begin: 1.0,
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

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
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
                          .withOpacity(_opacityAnimation.value),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
        );
      },
    );
  }
}

/// Glassmorphism app bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final bool centerTitle;

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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          backgroundColor:
              (backgroundColor ?? Colors.white).withOpacity(opacity),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Glassmorphism bottom sheet
class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          borderRadius ?? const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withOpacity(opacity),
            borderRadius: borderRadius ??
                const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Show glassmorphism bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double blur = 15.0,
    double opacity = 0.2,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBottomSheet(
        blur: blur,
        opacity: opacity,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
