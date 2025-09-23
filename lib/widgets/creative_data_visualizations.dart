import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'creative_components.dart';

/// Advanced 3D data visualization components

/// 3D bar chart with interactive elements
class ThreeDBarChart extends StatefulWidget {

  const ThreeDBarChart({
    super.key,
    required this.data,
    this.height = 250,
    this.barWidth = 40,
  });
  final List<BarData> data;
  final double height;
  final double barWidth;

  @override
  State<ThreeDBarChart> createState() => _ThreeDBarChartState();
}

class _ThreeDBarChartState extends State<ThreeDBarChart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int? _selectedIndex;
  final List<AnimationController> _barControllers = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create individual controllers for each bar
    for (int i = 0; i < widget.data.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 800 + i * 100),
        vsync: this,
      );
      _barControllers.add(controller);
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final maxValue = widget.data.map((final d) => d.value).reduce(math.max);

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.data.asMap().entries.map((final entry) {
          final index = entry.key;
          final data = entry.value;
          final barHeight = (data.value / maxValue) * (widget.height - 50);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedIndex = index);
            },
            child: AnimatedBuilder(
              animation: _barControllers[index],
              builder: (final context, final child) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Value label with animation
                    AnimatedOpacity(
                      opacity: _selectedIndex == index ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: data.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: data.color.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '\$${data.value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3D bar
                    Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(-0.1)
                        ..rotateY(_selectedIndex == index ? 0.1 : 0),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Bar shadow
                          Container(
                            width: widget.barWidth,
                            height: barHeight * _barControllers[index].value,
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          // Main bar
                          Container(
                            width: widget.barWidth,
                            height: barHeight * _barControllers[index].value,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  data.color.withValues(alpha: 0.9),
                                  data.color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: data.color.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),

                          // Top face (3D effect)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: widget.barWidth,
                              height: 10,
                              decoration: BoxDecoration(
                                color: data.color.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Label
                    Text(
                      data.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: _selectedIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Interactive 3D pie chart with explosion effect
class ThreeDPieChart extends StatefulWidget {

  const ThreeDPieChart({
    super.key,
    required this.data,
    this.size = 200,
    this.thickness = 40,
  });
  final List<PieData> data;
  final double size;
  final double thickness;

  @override
  State<ThreeDPieChart> createState() => _ThreeDPieChartState();
}

class _ThreeDPieChartState extends State<ThreeDPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (final context, final child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(-0.3),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow layer
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _PieShadowPainter(
                    data: widget.data,
                    thickness: widget.thickness,
                  ),
                ),

                // Main pie chart
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ThreeDPiePainter(
                    data: widget.data,
                    thickness: widget.thickness,
                    animation: _animation.value,
                    selectedIndex: _selectedIndex,
                  ),
                ),

                // Interactive overlay
                ...List.generate(widget.data.length, _buildInteractiveSegment),

                // Center info
                GlassmorphicContainer(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  borderRadius: BorderRadius.circular(widget.size * 0.25),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '\$${widget.data.map((final d) => d.value).reduce((final a, final b) => a + b).toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
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
    );

  Widget _buildInteractiveSegment(final int index) {
    final total = widget.data.map((final d) => d.value).reduce((final a, final b) => a + b);
    double startAngle = -math.pi / 2;

    for (int i = 0; i < index; i++) {
      startAngle += (widget.data[i].value / total) * 2 * math.pi;
    }

    final sweepAngle = (widget.data[index].value / total) * 2 * math.pi;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = _selectedIndex == index ? null : index;
        });
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _InteractiveSegmentPainter(
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          isSelected: _selectedIndex == index,
        ),
      ),
    );
  }
}

class _ThreeDPiePainter extends CustomPainter {

  _ThreeDPiePainter({
    required this.data,
    required this.thickness,
    required this.animation,
    this.selectedIndex,
  });
  final List<PieData> data;
  final double thickness;
  final double animation;
  final int? selectedIndex;

  @override
  void paint(final Canvas canvas, final Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final total = data.map((final d) => d.value).reduce((final a, final b) => a + b);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi * animation;
      final isSelected = selectedIndex == i;
      final explodeOffset = isSelected ? 15.0 : 0.0;

      // Calculate offset for explosion effect
      final middleAngle = startAngle + sweepAngle / 2;
      final offsetX = explodeOffset * math.cos(middleAngle);
      final offsetY = explodeOffset * math.sin(middleAngle);
      final segmentCenter = Offset(center.dx + offsetX, center.dy + offsetY);

      // Draw 3D sides
      if (animation > 0.5) {
        _draw3DSides(
          canvas,
          segmentCenter,
          radius,
          startAngle,
          sweepAngle,
          data[i].color,
        );
      }

      // Draw top face
      final paint = Paint()
        ..color = data[i].color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(segmentCenter.dx, segmentCenter.dy)
        ..arcTo(
          Rect.fromCircle(center: segmentCenter, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: segmentCenter, radius: radius - thickness),
          startAngle + sweepAngle,
          -sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Add gradient overlay
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: segmentCenter, radius: radius))
        ..blendMode = BlendMode.overlay;

      canvas.drawPath(path, gradientPaint);

      startAngle += sweepAngle;
    }
  }

  void _draw3DSides(
    final Canvas canvas,
    final Offset center,
    final double radius,
    final double startAngle,
    final double sweepAngle,
    final Color color,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Draw outer edge
    final outerPath = Path();
    const steps = 20;
    final angleStep = sweepAngle / steps;

    for (int i = 0; i <= steps; i++) {
      final angle = startAngle + i * angleStep;
      final x1 = center.dx + radius * math.cos(angle);
      final y1 = center.dy + radius * math.sin(angle);
      final x2 = x1;
      final y2 = y1 + thickness * 0.3;

      if (i == 0) {
        outerPath.moveTo(x1, y1);
      } else {
        outerPath.lineTo(x1, y1);
      }

      if (i == steps) {
        outerPath.lineTo(x2, y2);
        for (int j = steps; j >= 0; j--) {
          final angle2 = startAngle + j * angleStep;
          final x3 = center.dx + radius * math.cos(angle2);
          final y3 = center.dy + radius * math.sin(angle2) + thickness * 0.3;
          outerPath.lineTo(x3, y3);
        }
      }
    }

    outerPath.close();
    canvas.drawPath(outerPath, paint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

class _PieShadowPainter extends CustomPainter {

  _PieShadowPainter({
    required this.data,
    required this.thickness,
  });
  final List<PieData> data;
  final double thickness;

  @override
  void paint(final Canvas canvas, final Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 20);
    final radius = math.min(size.width, size.height) / 2 - 20;

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => false;
}

class _InteractiveSegmentPainter extends CustomPainter {

  _InteractiveSegmentPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.isSelected,
  });
  final double startAngle;
  final double sweepAngle;
  final bool isSelected;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (!isSelected) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius + 5),
        startAngle,
        sweepAngle,
        false,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Wave chart with liquid animation
class LiquidWaveChart extends StatefulWidget {

  const LiquidWaveChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 150,
  });
  final List<double> values;
  final Color color;
  final double height;

  @override
  State<LiquidWaveChart> createState() => _LiquidWaveChartState();
}

class _LiquidWaveChartState extends State<LiquidWaveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (final context, final child) => CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _LiquidWavePainter(
            values: widget.values,
            color: widget.color,
            animation: _controller.value,
          ),
        ),
    );
}

class _LiquidWavePainter extends CustomPainter {

  _LiquidWavePainter({
    required this.values,
    required this.color,
    required this.animation,
  });
  final List<double> values;
  final Color color;
  final double animation;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final maxValue = values.reduce(math.max);
    final stepX = size.width / (values.length - 1);

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw wave with animation
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedValue = values[i] / maxValue;
      final waveHeight = 10 * math.sin(animation * 2 * math.pi + i * 0.5);
      final y =
          size.height - (normalizedValue * size.height * 0.8) + waveHeight;

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height -
            (values[i - 1] / maxValue * size.height * 0.8) +
            10 * math.sin(animation * 2 * math.pi + (i - 1) * 0.5);

        final controlX1 = prevX + stepX * 0.3;
        final controlY1 = prevY;
        final controlX2 = x - stepX * 0.3;
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();

    // Draw gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        color.withValues(alpha: 0.3),
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawPath(path, paint);

    // Draw wave line
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final linePath = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedValue = values[i] / maxValue;
      final waveHeight = 10 * math.sin(animation * 2 * math.pi + i * 0.5);
      final y =
          size.height - (normalizedValue * size.height * 0.8) + waveHeight;

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height -
            (values[i - 1] / maxValue * size.height * 0.8) +
            10 * math.sin(animation * 2 * math.pi + (i - 1) * 0.5);

        final controlX1 = prevX + stepX * 0.3;
        final controlY1 = prevY;
        final controlX2 = x - stepX * 0.3;
        final controlY2 = y;

        linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

// Data models
class BarData {

  BarData({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

class PieData {

  PieData({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}
