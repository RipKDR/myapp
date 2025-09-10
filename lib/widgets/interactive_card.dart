import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

/// Interactive wrapper that adds subtle press/hover motion and optional haptics.
class InteractiveCard extends StatefulWidget {

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 120),
    this.pressScale = 0.98,
    this.hoverTranslateY = -2,
  });
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressScale;
  final double hoverTranslateY;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1, end: widget.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: (final d) {
          _handleTapUp(d);
          if (!settings.disableHaptics) {
            HapticFeedback.selectionClick();
          }
          widget.onTap?.call();
        },
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (final context, final child) {
            final translateY = _isHovered ? widget.hoverTranslateY : 0.0;
            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
