import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Advanced animation components for creative UI enhancements

/// Ripple animation widget that creates expanding circles
class RippleAnimation extends StatefulWidget {

  const RippleAnimation({
    super.key,
    required this.child,
    this.color = const Color(0xFF1A73E8),
    this.duration = const Duration(seconds: 2),
    this.maxRadius = 100,
  });
  final Widget child;
  final Color color;
  final Duration duration;
  final double maxRadius;

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _ripples = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create multiple ripples with delays
    for (int i = 0; i < 3; i++) {
      _ripples.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              i * 0.3,
              0.6 + i * 0.2,
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Stack(
      alignment: Alignment.center,
      children: [
        // Ripple effects
        ..._ripples
            .map((final ripple) => AnimatedBuilder(
                  animation: ripple,
                  builder: (final context, final child) => Container(
                      width: widget.maxRadius * 2 * ripple.value,
                      height: widget.maxRadius * 2 * ripple.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color.withValues(alpha: 1 - ripple.value),
                          width: 3 * (1 - ripple.value),
                        ),
                      ),
                    ),
                ))
            ,

        // Child widget
        widget.child,
      ],
    );
}

/// Particle burst animation for celebratory moments
class ParticleBurst extends StatefulWidget {

  const ParticleBurst({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.colors = const [
      Color(0xFF1A73E8),
      Color(0xFF34A853),
      Color(0xFFFBBC04),
      Color(0xFFEA4335),
    ],
    this.onComplete,
    this.trigger = false,
  });
  final Widget child;
  final int particleCount;
  final List<Color> colors;
  final VoidCallback? onComplete;
  final bool trigger;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.addStatusListener((final status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _initializeParticles();
  }

  @override
  void didUpdateWidget(final ParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _burst();
    }
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle(
        angle: _random.nextDouble() * 2 * math.pi,
        velocity: 200 + _random.nextDouble() * 200,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: 4 + _random.nextDouble() * 4,
      ));
    }
  }

  void _burst() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (widget.trigger)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (final context, final child) => CustomPaint(
                  size: const Size(300, 300),
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                ),
            ),
          ),
      ],
    );
}

class _Particle {

  _Particle({
    required this.angle,
    required this.velocity,
    required this.color,
    required this.size,
  });
  final double angle;
  final double velocity;
  final Color color;
  final double size;
}

class _ParticlePainter extends CustomPainter {

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(final Canvas canvas, final Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final distance = particle.velocity * progress;
      final x = center.dx + distance * math.cos(particle.angle);
      final y = center.dy +
          distance * math.sin(particle.angle) +
          (progress * progress * 100); // Gravity effect

      final opacity = 1 - progress;
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Morphing shape animation
class MorphingShape extends StatefulWidget {

  const MorphingShape({
    super.key,
    this.size = 100,
    this.color = const Color(0xFF1A73E8),
    this.duration = const Duration(seconds: 3),
  });
  final double size;
  final Color color;
  final Duration duration;

  @override
  State<MorphingShape> createState() => _MorphingShapeState();
}

class _MorphingShapeState extends State<MorphingShape>
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
      end: 1,
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

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (final context, final child) => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _MorphingShapePainter(
            color: widget.color,
            progress: _animation.value,
          ),
        ),
    );
}

class _MorphingShapePainter extends CustomPainter {

  _MorphingShapePainter({
    required this.color,
    required this.progress,
  });
  final Color color;
  final double progress;

  @override
  void paint(final Canvas canvas, final Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final path = Path();

    // Morph between different shapes based on progress
    const sides = 6;
    for (int i = 0; i < sides; i++) {
      final angle = (i / sides) * 2 * math.pi - math.pi / 2;
      final morphAngle = angle + progress * 2 * math.pi;

      // Add variation to radius for organic feel
      final radiusVariation = radius * (1 + 0.3 * math.sin(morphAngle * 3));

      final x = center.dx + radiusVariation * math.cos(morphAngle);
      final y = center.dy + radiusVariation * math.sin(morphAngle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Use quadratic bezier for smooth curves
        final prevAngle = ((i - 1) / sides) * 2 * math.pi - math.pi / 2;
        final prevMorphAngle = prevAngle + progress * 2 * math.pi;
        final prevRadiusVariation =
            radius * (1 + 0.3 * math.sin(prevMorphAngle * 3));

        final prevX =
            center.dx + prevRadiusVariation * math.cos(prevMorphAngle);
        final prevY =
            center.dy + prevRadiusVariation * math.sin(prevMorphAngle);

        final controlX =
            (prevX + x) / 2 + 10 * math.sin(progress * 2 * math.pi);
        final controlY =
            (prevY + y) / 2 + 10 * math.cos(progress * 2 * math.pi);

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    path.close();

    // Add gradient effect
    final gradient = RadialGradient(
      colors: [
        color.withValues(alpha: 0.8),
        color,
      ],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );

    canvas.drawPath(path, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Holographic effect widget
class HolographicCard extends StatefulWidget {

  const HolographicCard({
    super.key,
    required this.child,
    this.width = 300,
    this.height = 200,
    this.borderRadius,
  });
  final Widget child;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0;
  double _rotationY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
      onPanUpdate: (final details) {
        setState(() {
          _rotationY =
              (details.localPosition.dx - widget.width / 2) / widget.width;
          _rotationX =
              -(details.localPosition.dy - widget.height / 2) / widget.height;
        });
      },
      onPanEnd: (_) {
        setState(() {
          _rotationX = 0;
          _rotationY = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotationX * 0.3)
          ..rotateY(_rotationY * 0.3),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            child: Stack(
              children: [
                // Base content
                widget.child,

                // Holographic overlay
                AnimatedBuilder(
                  animation: _controller,
                  builder: (final context, final child) => CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: _HolographicPainter(
                        progress: _controller.value,
                        rotationX: _rotationX,
                        rotationY: _rotationY,
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

class _HolographicPainter extends CustomPainter {

  _HolographicPainter({
    required this.progress,
    required this.rotationX,
    required this.rotationY,
  });
  final double progress;
  final double rotationX;
  final double rotationY;

  @override
  void paint(final Canvas canvas, final Size size) {
    // Create holographic gradient effect
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Calculate angle based on rotation
    final angle = math.atan2(rotationY, rotationX);

    // Create animated gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      transform: GradientRotation(angle + progress * 2 * math.pi),
      colors: [
        Colors.red.withValues(alpha: 0.3),
        Colors.orange.withValues(alpha: 0.3),
        Colors.yellow.withValues(alpha: 0.3),
        Colors.green.withValues(alpha: 0.3),
        Colors.blue.withValues(alpha: 0.3),
        Colors.indigo.withValues(alpha: 0.3),
        Colors.purple.withValues(alpha: 0.3),
        Colors.red.withValues(alpha: 0.3),
      ],
      stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 0.95, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.overlay;

    canvas.drawRect(rect, paint);

    // Add shimmer effect
    final shimmerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      transform: GradientRotation(progress * 2 * math.pi),
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.2),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final shimmerPaint = Paint()
      ..shader = shimmerGradient.createShader(rect)
      ..blendMode = BlendMode.overlay;

    canvas.drawRect(rect, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Floating bubbles background animation
class FloatingBubbles extends StatefulWidget {

  const FloatingBubbles({
    super.key,
    this.bubbleCount = 15,
    this.colors = const [
      Color(0xFF1A73E8),
      Color(0xFF34A853),
      Color(0xFFFBBC04),
      Color(0xFFEA4335),
    ],
    required this.child,
  });
  final int bubbleCount;
  final List<Color> colors;
  final Widget child;

  @override
  State<FloatingBubbles> createState() => _FloatingBubblesState();
}

class _FloatingBubblesState extends State<FloatingBubbles>
    with TickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeBubbles();
  }

  void _initializeBubbles() {
    for (int i = 0; i < widget.bubbleCount; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 10 + _random.nextInt(10)),
        vsync: this,
      )..repeat();

      _bubbles.add(_Bubble(
        controller: controller,
        size: 20 + _random.nextDouble() * 60,
        color: widget.colors[_random.nextInt(widget.colors.length)]
            .withValues(alpha: 0.3),
        initialX: _random.nextDouble(),
        wobbleAmount: 50 + _random.nextDouble() * 100,
      ));
    }
  }

  @override
  void dispose() {
    for (final bubble in _bubbles) {
      bubble.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Stack(
      children: [
        // Bubbles
        ..._bubbles
            .map((final bubble) => AnimatedBuilder(
                  animation: bubble.controller,
                  builder: (final context, final child) {
                    final progress = bubble.controller.value;
                    final wobble =
                        math.sin(progress * 2 * math.pi) * bubble.wobbleAmount;

                    return Positioned(
                      left:
                          bubble.initialX * MediaQuery.of(context).size.width +
                              wobble,
                      bottom: progress *
                          (MediaQuery.of(context).size.height + bubble.size),
                      child: Container(
                        width: bubble.size,
                        height: bubble.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bubble.color,
                          boxShadow: [
                            BoxShadow(
                              color: bubble.color.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ))
            ,

        // Child content
        widget.child,
      ],
    );
}

class _Bubble {

  _Bubble({
    required this.controller,
    required this.size,
    required this.color,
    required this.initialX,
    required this.wobbleAmount,
  });
  final AnimationController controller;
  final double size;
  final Color color;
  final double initialX;
  final double wobbleAmount;
}
