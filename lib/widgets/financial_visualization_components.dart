import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/google_theme.dart';

/// Advanced financial visualization components for budget management
/// Following 2025 design trends with sophisticated data visualization

/// Enhanced budget donut chart with interactive segments
class BudgetDonutChart extends StatefulWidget {
  final List<BudgetCategory> categories;
  final double size;
  final double strokeWidth;
  final bool showLabels;
  final Function(BudgetCategory)? onSegmentTap;

  const BudgetDonutChart({
    super.key,
    required this.categories,
    this.size = 200,
    this.strokeWidth = 20,
    this.showLabels = true,
    this.onSegmentTap,
  });

  @override
  State<BudgetDonutChart> createState() => _BudgetDonutChartState();
}

class _BudgetDonutChartState extends State<BudgetDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: BudgetDonutPainter(
                  categories: widget.categories,
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  hoveredIndex: _hoveredIndex,
                ),
                child: widget.onSegmentTap != null
                    ? GestureDetector(
                        onTapUp: (details) => _handleTap(details),
                        child: Container(),
                      )
                    : null,
              ),
            );
          },
        ),
        if (widget.showLabels) ...[
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isHovered = _hoveredIndex == index;

        return GestureDetector(
          onTap: widget.onSegmentTap != null
              ? () => widget.onSegmentTap!(category)
              : null,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isHovered
                    ? category.color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHovered ? category.color : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight:
                              isHovered ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleTap(TapUpDetails details) {
    if (widget.onSegmentTap == null) return;

    final center = Offset(widget.size / 2, widget.size / 2);
    final tapPosition = details.localPosition;
    final distance = (tapPosition - center).distance;

    final innerRadius = (widget.size / 2) - widget.strokeWidth;
    final outerRadius = widget.size / 2;

    if (distance >= innerRadius && distance <= outerRadius) {
      final angle = math.atan2(
        tapPosition.dy - center.dy,
        tapPosition.dx - center.dx,
      );

      final normalizedAngle = (angle + math.pi / 2) % (2 * math.pi);

      double currentAngle = 0;
      final total =
          widget.categories.fold<double>(0, (sum, cat) => sum + cat.spent);

      for (int i = 0; i < widget.categories.length; i++) {
        final segmentAngle = (widget.categories[i].spent / total) * 2 * math.pi;

        if (normalizedAngle >= currentAngle &&
            normalizedAngle <= currentAngle + segmentAngle) {
          HapticFeedback.lightImpact();
          widget.onSegmentTap!(widget.categories[i]);
          break;
        }

        currentAngle += segmentAngle;
      }
    }
  }
}

/// Custom painter for budget donut chart
class BudgetDonutPainter extends CustomPainter {
  final List<BudgetCategory> categories;
  final double progress;
  final double strokeWidth;
  final int? hoveredIndex;

  BudgetDonutPainter({
    required this.categories,
    required this.progress,
    required this.strokeWidth,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final total = categories.fold<double>(0, (sum, cat) => sum + cat.spent);
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final sweepAngle = (category.spent / total) * 2 * math.pi * progress;
      final isHovered = hoveredIndex == i;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw shadow for hovered segment
      if (isHovered) {
        final shadowPaint = Paint()
          ..color = category.color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          shadowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(BudgetDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.categories != categories;
  }
}

/// Enhanced spending trend chart with multiple data series
class SpendingTrendChart extends StatefulWidget {
  final List<SpendingDataPoint> data;
  final double height;
  final Duration animationDuration;
  final bool showGrid;
  final bool showLabels;

  const SpendingTrendChart({
    super.key,
    required this.data,
    this.height = 200,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.showGrid = true,
    this.showLabels = true,
  });

  @override
  State<SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<SpendingTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: CustomPaint(
            painter: SpendingTrendPainter(
              data: widget.data,
              progress: _animation.value,
              showGrid: widget.showGrid,
              showLabels: widget.showLabels,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

/// Custom painter for spending trend chart
class SpendingTrendPainter extends CustomPainter {
  final List<SpendingDataPoint> data;
  final double progress;
  final bool showGrid;
  final bool showLabels;
  final TextStyle? textStyle;

  SpendingTrendPainter({
    required this.data,
    required this.progress,
    required this.showGrid,
    required this.showLabels,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = const EdgeInsets.all(20);
    final chartRect = Rect.fromLTRB(
      padding.left,
      padding.top,
      size.width - padding.right,
      size.height - padding.bottom,
    );

    // Find min/max values
    final maxValue = data.map((d) => d.amount).reduce(math.max);
    final minValue = data.map((d) => d.amount).reduce(math.min);
    final range = maxValue - minValue;

    if (range == 0) return;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, chartRect, maxValue, minValue);
    }

    // Draw trend line
    _drawTrendLine(canvas, chartRect, maxValue, minValue, range);

    // Draw data points
    _drawDataPoints(canvas, chartRect, maxValue, minValue, range);

    // Draw labels
    if (showLabels) {
      _drawLabels(canvas, chartRect, maxValue, minValue);
    }
  }

  void _drawGrid(
      Canvas canvas, Rect chartRect, double maxValue, double minValue) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartRect.top + (chartRect.height * i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    final visiblePoints = (data.length * progress).round();
    for (int i = 0;
        i < visiblePoints;
        i += (visiblePoints / 6).round().clamp(1, visiblePoints)) {
      final x = chartRect.left + (chartRect.width * i / (data.length - 1));
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }
  }

  void _drawTrendLine(Canvas canvas, Rect chartRect, double maxValue,
      double minValue, double range) {
    final linePaint = Paint()
      ..color = GoogleTheme.googleBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = GoogleTheme.googleBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final visiblePoints = (data.length * progress).round();

    for (int i = 0; i < visiblePoints; i++) {
      final x = chartRect.left + (chartRect.width * i / (data.length - 1));
      final y = chartRect.bottom -
          ((data[i].amount - minValue) / range) * chartRect.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartRect.bottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    if (visiblePoints > 0) {
      final lastX = chartRect.left +
          (chartRect.width * (visiblePoints - 1) / (data.length - 1));
      fillPath.lineTo(lastX, chartRect.bottom);
      fillPath.close();
    }

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawDataPoints(Canvas canvas, Rect chartRect, double maxValue,
      double minValue, double range) {
    final pointPaint = Paint()
      ..color = GoogleTheme.googleBlue
      ..style = PaintingStyle.fill;

    final visiblePoints = (data.length * progress).round();

    for (int i = 0; i < visiblePoints; i++) {
      final x = chartRect.left + (chartRect.width * i / (data.length - 1));
      final y = chartRect.bottom -
          ((data[i].amount - minValue) / range) * chartRect.height;

      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // White center
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawLabels(
      Canvas canvas, Rect chartRect, double maxValue, double minValue) {
    if (textStyle == null) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = minValue + ((maxValue - minValue) * (4 - i) / 4);
      final y = chartRect.top + (chartRect.height * i / 4);

      textPainter.text = TextSpan(
        text: '\$${value.toStringAsFixed(0)}',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
            chartRect.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(SpendingTrendPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showLabels != showLabels;
  }
}

/// Budget category progress bar with enhanced styling
class BudgetCategoryBar extends StatefulWidget {
  final BudgetCategory category;
  final bool showPercentage;
  final bool isInteractive;
  final VoidCallback? onTap;

  const BudgetCategoryBar({
    super.key,
    required this.category,
    this.showPercentage = true,
    this.isInteractive = true,
    this.onTap,
  });

  @override
  State<BudgetCategoryBar> createState() => _BudgetCategoryBarState();
}

class _BudgetCategoryBarState extends State<BudgetCategoryBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.category.spent / widget.category.allocated,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = widget.category.spent / widget.category.allocated;
    final isOverBudget = progress > 1.0;
    final displayColor =
        isOverBudget ? GoogleTheme.googleRed : widget.category.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered && widget.isInteractive
                ? displayColor.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered && widget.isInteractive
                  ? displayColor.withOpacity(0.2)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.showPercentage)
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: displayColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: displayColor.withOpacity(0.1),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(displayColor),
                          minHeight: 8,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Amount details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent: \$${widget.category.spent.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Budget: \$${widget.category.allocated.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              // Over budget warning
              if (isOverBudget) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: GoogleTheme.googleRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 14,
                        color: GoogleTheme.googleRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Over budget by \$${(widget.category.spent - widget.category.allocated).toStringAsFixed(0)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: GoogleTheme.googleRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Data models for financial components
class BudgetCategory {
  final String name;
  final double allocated;
  final double spent;
  final Color color;
  final String? description;

  const BudgetCategory({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.color,
    this.description,
  });

  double get remaining => allocated - spent;
  double get progress => spent / allocated;
  bool get isOverBudget => spent > allocated;
}

class SpendingDataPoint {
  final DateTime date;
  final double amount;
  final String? label;

  const SpendingDataPoint({
    required this.date,
    required this.amount,
    this.label,
  });
}
