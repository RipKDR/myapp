import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../utils/haptic_utils.dart';

/// Advanced data visualization components for 2025 healthcare UX
class AdvancedDataVisualization {
  /// Creates an interactive health progress ring with multiple metrics
  static Widget buildHealthProgressRing({
    required final double primaryValue,
    required final double secondaryValue,
    required final String primaryLabel,
    required final String secondaryLabel,
    required final Color primaryColor,
    required final Color secondaryColor,
    final double size = 120,
    final double strokeWidth = 8,
    final bool showAnimation = true,
  }) => _HealthProgressRing(
      primaryValue: primaryValue,
      secondaryValue: secondaryValue,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      size: size,
      strokeWidth: strokeWidth,
      showAnimation: showAnimation,
    );

  /// Creates an interactive trend chart with touch interactions
  static Widget buildTrendChart({
    required final List<ChartDataPoint> data,
    required final String title,
    required final String subtitle,
    final Color? accentColor,
    final bool showTrend = true,
    final bool interactive = true,
  }) => _TrendChart(
      data: data,
      title: title,
      subtitle: subtitle,
      accentColor: accentColor ?? AppTheme.calmingBlue,
      showTrend: showTrend,
      interactive: interactive,
    );

  /// Creates a health score dashboard with multiple metrics
  static Widget buildHealthScoreDashboard({
    required final List<HealthMetric> metrics,
    required final String title,
    final String? subtitle,
  }) => _HealthScoreDashboard(
      metrics: metrics,
      title: title,
      subtitle: subtitle,
    );

  /// Creates an interactive budget flow visualization
  static Widget buildBudgetFlowChart({
    required final double totalBudget,
    required final double usedBudget,
    required final List<BudgetCategory> categories,
    required final String title,
  }) => _BudgetFlowChart(
      totalBudget: totalBudget,
      usedBudget: usedBudget,
      categories: categories,
      title: title,
    );
}

/// Interactive health progress ring with dual metrics
class _HealthProgressRing extends StatefulWidget {

  const _HealthProgressRing({
    required this.primaryValue,
    required this.secondaryValue,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.primaryColor,
    required this.secondaryColor,
    this.size = 120,
    this.strokeWidth = 8,
    this.showAnimation = true,
  });
  final double primaryValue;
  final double secondaryValue;
  final String primaryLabel;
  final String secondaryLabel;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;
  final double strokeWidth;
  final bool showAnimation;

  @override
  State<_HealthProgressRing> createState() => _HealthProgressRingState();
}

class _HealthProgressRingState extends State<_HealthProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _primaryAnimation = Tween<double>(
      begin: 0,
      end: widget.primaryValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
    ));

    _secondaryAnimation = Tween<double>(
      begin: 0,
      end: widget.secondaryValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.elasticOut),
    ));

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (final context, final child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticUtils.lightImpact(context);
              _showDetailedView(context);
            },
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _HealthRingPainter(
                  primaryProgress: _primaryAnimation.value,
                  secondaryProgress: _secondaryAnimation.value,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  strokeWidth: widget.strokeWidth,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(widget.primaryValue * 100).toInt()}%',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: widget.primaryColor,
                                ),
                      ),
                      Text(
                        widget.primaryLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );

  void _showDetailedView(final BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Health Progress Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMetricRow(
                widget.primaryLabel, widget.primaryValue, widget.primaryColor),
            const SizedBox(height: 8),
            _buildMetricRow(widget.secondaryLabel, widget.secondaryValue,
                widget.secondaryColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(final String label, final double value, final Color color) => Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text('${(value * 100).toInt()}%'),
      ],
    );
}

/// Custom painter for the health progress ring
class _HealthRingPainter extends CustomPainter {

  _HealthRingPainter({
    required this.primaryProgress,
    required this.secondaryProgress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
  });
  final double primaryProgress;
  final double secondaryProgress;
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  @override
  void paint(final Canvas canvas, final Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Primary progress arc
    final primaryPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final primarySweepAngle = 2 * math.pi * primaryProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      primarySweepAngle,
      false,
      primaryPaint,
    );

    // Secondary progress arc (offset)
    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = strokeWidth * 0.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondarySweepAngle = 2 * math.pi * secondaryProgress;
    final secondaryRadius = radius - strokeWidth * 0.8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: secondaryRadius),
      -math.pi / 2 + primarySweepAngle * 0.1, // Slight offset
      secondarySweepAngle,
      false,
      secondaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Interactive trend chart with touch interactions
class _TrendChart extends StatefulWidget {

  const _TrendChart({
    required this.data,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.showTrend = true,
    this.interactive = true,
  });
  final List<ChartDataPoint> data;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool showTrend;
  final bool interactive;

  @override
  State<_TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<_TrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: widget.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (final context, final child) => CustomPaint(
                  painter: _TrendChartPainter(
                    data: widget.data,
                    animation: _animation.value,
                    accentColor: widget.accentColor,
                    selectedIndex: _selectedIndex,
                    showTrend: widget.showTrend,
                  ),
                  child: widget.interactive
                      ? GestureDetector(
                          onTapDown: _handleTap,
                          child: Container(),
                        )
                      : null,
                ),
            ),
          ),
          if (_selectedIndex != null) ...[
            const SizedBox(height: 12),
            _buildSelectedPointInfo(),
          ],
        ],
      ),
    );

  void _handleTap(final TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    // Calculate which data point is closest to tap
    final chartWidth = box.size.width;
    final pointWidth = chartWidth / (widget.data.length - 1);

    final tappedIndex = (localPosition.dx / pointWidth).round()
        .clamp(0, widget.data.length - 1);

    setState(() {
      _selectedIndex = tappedIndex;
    });

    HapticUtils.selectionClick(context);
  }

  Widget _buildSelectedPointInfo() {
    if (_selectedIndex == null || _selectedIndex! >= widget.data.length) {
      return const SizedBox.shrink();
    }

    final point = widget.data[_selectedIndex!];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: widget.accentColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${point.label}: ${point.value}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the trend chart
class _TrendChartPainter extends CustomPainter {

  _TrendChartPainter({
    required this.data,
    required this.animation,
    required this.accentColor,
    this.selectedIndex,
    this.showTrend = true,
  });
  final List<ChartDataPoint> data;
  final double animation;
  final Color accentColor;
  final int? selectedIndex;
  final bool showTrend;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final selectedPointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Calculate points
    final points = <Offset>[];
    final maxValue = data.map((final d) => d.value).reduce(math.max);
    final minValue = data.map((final d) => d.value).reduce(math.min);
    final valueRange = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final normalizedValue =
          valueRange > 0 ? (data[i].value - minValue) / valueRange : 0.5;
      final y = size.height - (normalizedValue * (size.height - 40)) - 20;
      points.add(Offset(x, y));
    }

    // Draw trend line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        final currentPoint = points[i];
        final animatedPoint = Offset(
          currentPoint.dx,
          points[0].dy + (currentPoint.dy - points[0].dy) * animation,
        );
        path.lineTo(animatedPoint.dx, animatedPoint.dy);
      }

      canvas.drawPath(path, paint);
    }

    // Draw points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isSelected = selectedIndex == i;
      final radius = isSelected ? 6.0 : 4.0;

      canvas.drawCircle(
          point, radius, isSelected ? selectedPointPaint : pointPaint);

      // Draw selection ring for selected point
      if (isSelected) {
        final ringPaint = Paint()
          ..color = accentColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(point, radius + 3, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => true;
}

/// Health score dashboard with multiple metrics
class _HealthScoreDashboard extends StatelessWidget {

  const _HealthScoreDashboard({
    required this.metrics,
    required this.title,
    this.subtitle,
  });
  final List<HealthMetric> metrics;
  final String title;
  final String? subtitle;

  @override
  Widget build(final BuildContext context) => InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.trustGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: AppTheme.trustGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...metrics.map((final metric) => _buildMetricRow(context, metric)),
        ],
      ),
    );

  Widget _buildMetricRow(final BuildContext context, final HealthMetric metric) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              metric.icon,
              color: metric.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  metric.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metric.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: metric.color,
                    ),
              ),
              if (metric.trend != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      metric.trend! > 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 12,
                      color: metric.trend! > 0
                          ? AppTheme.trustGreen
                          : AppTheme.safetyGrey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${metric.trend!.abs().toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: metric.trend! > 0
                                ? AppTheme.trustGreen
                                : AppTheme.safetyGrey,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
}

/// Interactive budget flow chart
class _BudgetFlowChart extends StatefulWidget {

  const _BudgetFlowChart({
    required this.totalBudget,
    required this.usedBudget,
    required this.categories,
    required this.title,
  });
  final double totalBudget;
  final double usedBudget;
  final List<BudgetCategory> categories;
  final String title;

  @override
  State<_BudgetFlowChart> createState() => _BudgetFlowChartState();
}

class _BudgetFlowChartState extends State<_BudgetFlowChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final remainingBudget = widget.totalBudget - widget.usedBudget;
    final usedPercentage = widget.usedBudget / widget.totalBudget;

    return InteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warmAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.warmAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Budget overview
          Row(
            children: [
              Expanded(
                child: _buildBudgetSection(
                  context,
                  'Used',
                  widget.usedBudget,
                  usedPercentage,
                  AppTheme.trustGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBudgetSection(
                  context,
                  'Remaining',
                  remainingBudget,
                  1 - usedPercentage,
                  AppTheme.calmingBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category breakdown
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),

          ...widget.categories
              .map((final category) => _buildCategoryRow(context, category)),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(
    final BuildContext context,
    final String label,
    final double amount,
    final double percentage,
    final Color color,
  ) => AnimatedBuilder(
      animation: _animation,
      builder: (final context, final child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage * _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
    );

  Widget _buildCategoryRow(final BuildContext context, final BudgetCategory category) {
    final percentage = category.amount / widget.totalBudget;
    final isSelected = _selectedCategory == widget.categories.indexOf(category);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory =
              isSelected ? null : widget.categories.indexOf(category);
        });
        HapticUtils.lightImpact(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? category.color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: category.color.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}% of total budget',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${category.amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data models for visualization components
class ChartDataPoint {

  ChartDataPoint({
    required this.value,
    required this.label,
    this.date,
  });
  final double value;
  final String label;
  final DateTime? date;
}

class HealthMetric { // Percentage change

  HealthMetric({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend;
}

class BudgetCategory {

  BudgetCategory({
    required this.name,
    required this.amount,
    required this.color,
  });
  final String name;
  final double amount;
  final Color color;
}

class BudgetOverview {}
