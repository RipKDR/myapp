import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/budget.dart';

class BudgetPieChart extends StatelessWidget {
  const BudgetPieChart({super.key, required this.data});
  final BudgetOverview data;

  @override
  Widget build(final BuildContext context) {
    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.pink,
      Colors.amber,
    ];
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _PiePainter(data, colors),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (int i = 0; i < data.buckets.length; i++)
              _Legend(color: colors[i % colors.length], label: data.buckets[i].name),
          ],
        )
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(final BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.data, this.colors);
  final BudgetOverview data;
  final List<Color> colors;

  @override
  void paint(final Canvas canvas, final Size size) {
    final total = data.totalAllocated == 0 ? 1.0 : data.totalAllocated;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - 8;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = radius;
    double start = -math.pi / 2;
    for (int i = 0; i < data.buckets.length; i++) {
      final b = data.buckets[i];
      final sweep = (b.allocated / total) * 2 * math.pi;
      paint.color = colors[i % colors.length].withValues(alpha: 0.85);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius/2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant final _PiePainter oldDelegate) => oldDelegate.data != data;
}
