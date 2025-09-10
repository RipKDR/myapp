import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../theme/google_theme.dart';

/// Creative components with glassmorphism, 3D effects, and innovative interactions
/// Pushing the boundaries of modern UI design while maintaining usability

/// Glassmorphic container with frosted glass effect
class GlassmorphicContainer extends StatelessWidget {

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(final BuildContext context) => Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: border ??
                  Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
              boxShadow: boxShadow ??
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
}

/// 3D Flip card with perspective transformation
class Flip3DCard extends StatefulWidget {

  const Flip3DCard({
    super.key,
    required this.front,
    required this.back,
    this.width = 300,
    this.height = 200,
    this.duration = const Duration(milliseconds: 800),
  });
  final Widget front;
  final Widget back;
  final double width;
  final double height;
  final Duration duration;

  @override
  State<Flip3DCard> createState() => _Flip3DCardState();
}

class _Flip3DCardState extends State<Flip3DCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    HapticFeedback.mediumImpact();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (final context, final child) {
          final isShowingFront = _animation.value < 0.5;
          final angle = _animation.value * math.pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: isShowingFront
                  ? widget.front
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: widget.back,
                    ),
            ),
          );
        },
      ),
    );
}

/// Liquid button with morphing animation
class LiquidButton extends StatefulWidget {

  const LiquidButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF1A73E8),
    this.textColor = Colors.white,
    this.width = 200,
    this.height = 56,
    this.icon,
  });
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double width;
  final double height;
  final IconData? icon;

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _waveController;
  late Animation<double> _morphAnimation;
  late Animation<double> _waveAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _morphAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.elasticOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _morphController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _morphController.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _morphController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _morphController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphAnimation, _waveAnimation]),
        builder: (final context, final child) => Transform.scale(
            scale: _morphAnimation.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: CustomPaint(
                painter: _LiquidPainter(
                  color: widget.color,
                  wavePhase: _waveAnimation.value,
                  isPressed: _isPressed,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ),
    );
}

class _LiquidPainter extends CustomPainter {

  _LiquidPainter({
    required this.color,
    required this.wavePhase,
    required this.isPressed,
  });
  final Color color;
  final double wavePhase;
  final bool isPressed;

  @override
  void paint(final Canvas canvas, final Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = isPressed ? 8.0 : 4.0;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          waveHeight * math.sin((x / size.width * 2 * math.pi) + wavePhase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw morphing rounded rectangle
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(isPressed ? 20 : 28),
    );

    canvas.drawRRect(rrect, paint);

    // Add gradient overlay
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.2),
        Colors.transparent,
      ],
    );

    final gradientPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Parallax scrolling card with depth effect
class ParallaxCard extends StatefulWidget {

  const ParallaxCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.height = 200,
  });
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double height;

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  double _offsetX = 0;
  double _offsetY = 0;

  @override
  Widget build(final BuildContext context) => GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (final details) {
        setState(() {
          _offsetX = (details.localPosition.dx - 150) / 10;
          _offsetY = (details.localPosition.dy - 100) / 10;
        });
      },
      onPanEnd: (_) {
        setState(() {
          _offsetX = 0;
          _offsetY = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_offsetX * 0.01)
          ..rotateX(-_offsetY * 0.01),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(_offsetX / 2, _offsetY / 2 + 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Parallax background image
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  top: -20 - _offsetY,
                  left: -20 - _offsetX,
                  right: -20 + _offsetX,
                  bottom: -20 + _offsetY,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GoogleTheme.googleBlue,
                          GoogleTheme.googleGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Content overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GlassmorphicContainer(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

/// Animated gradient background with mesh effect
class AnimatedMeshGradient extends StatefulWidget {

  const AnimatedMeshGradient({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF1A73E8),
      Color(0xFF34A853),
      Color(0xFFFBBC04),
      Color(0xFFEA4335),
    ],
    this.duration = const Duration(seconds: 5),
  });
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (final context, final child) => CustomPaint(
          painter: _MeshGradientPainter(
            colors: widget.colors,
            phase: _animation.value,
          ),
          child: widget.child,
        ),
    );
}

class _MeshGradientPainter extends CustomPainter {

  _MeshGradientPainter({
    required this.colors,
    required this.phase,
  });
  final List<Color> colors;
  final double phase;

  @override
  void paint(final Canvas canvas, final Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create mesh grid
    const gridSize = 50.0;
    final columns = (size.width / gridSize).ceil();
    final rows = (size.height / gridSize).ceil();

    for (int i = 0; i < columns; i++) {
      for (int j = 0; j < rows; j++) {
        final x = i * gridSize;
        final y = j * gridSize;

        // Calculate color based on position and phase
        final colorIndex = ((i + j + phase) % colors.length).floor();
        final color = colors[colorIndex];

        // Add wave distortion
        final distortionX = 10 * math.sin(phase + i * 0.1);
        final distortionY = 10 * math.cos(phase + j * 0.1);

        final gradient = RadialGradient(
          radius: 1.5,
          colors: [
            color.withValues(alpha: 0.6),
            color.withValues(alpha: 0),
          ],
        );

        paint.shader = gradient.createShader(
          Rect.fromCircle(
            center: Offset(x + distortionX, y + distortionY),
            radius: gridSize * 1.5,
          ),
        );

        canvas.drawCircle(
          Offset(x + distortionX, y + distortionY),
          gridSize * 1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Neumorphic toggle switch with smooth animation
class NeumorphicSwitch extends StatefulWidget {

  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF1A73E8),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<NeumorphicSwitch> createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(final NeumorphicSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (final context, final child) => Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.lerp(
                widget.inactiveColor,
                widget.activeColor,
                _animation.value,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 6,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: _animation.value * 30,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
}

/// Floating action menu with orbital animation
class OrbitalActionMenu extends StatefulWidget {

  const OrbitalActionMenu({
    super.key,
    required this.actions,
    required this.child,
  });
  final List<OrbitalAction> actions;
  final Widget child;

  @override
  State<OrbitalActionMenu> createState() => _OrbitalActionMenuState();
}

class _OrbitalActionMenuState extends State<OrbitalActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbital items
          ...widget.actions.asMap().entries.map((final entry) {
            final index = entry.key;
            final action = entry.value;
            final angle = (index * 2 * math.pi) / widget.actions.length;

            return AnimatedBuilder(
              animation: _controller,
              builder: (final context, final child) {
                final radius = 80.0 * _controller.value;
                final x =
                    radius * math.cos(angle - _controller.value * math.pi);
                final y =
                    radius * math.sin(angle - _controller.value * math.pi);

                return Transform.translate(
                  offset: Offset(x, y),
                  child: ScaleTransition(
                    scale: _controller,
                    child: FloatingActionButton.small(
                      heroTag: 'orbital_$index',
                      onPressed: _isOpen ? action.onPressed : null,
                      backgroundColor: action.color,
                      child: Icon(action.icon, size: 20),
                    ),
                  ),
                );
              },
            );
          }),

          // Main button
          GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.identity()..rotateZ(_isOpen ? math.pi / 4 : 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
}

class OrbitalAction {

  OrbitalAction({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
}
