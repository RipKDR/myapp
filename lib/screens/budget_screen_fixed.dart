import 'package:flutter/material.dart';
import 'package:ndis_connect/models/budget.dart';
import '../widgets/advanced_data_visualization.dart'
    as advanced_data_visualization;
import '../widgets/glassmorphism_effects.dart';
import '../theme/app_theme.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _chartController;
  String _selectedView = 'Overview';
  final List<String> _views = ['Overview', 'Detailed', 'Trends'];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _chartController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final overview = _mockBudget();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (final value) => setState(() => _selectedView = value),
            itemBuilder: (final context) => _views
                .map(
                  (final view) => PopupMenuItem(
                    value: view,
                    child: Row(
                      children: [
                        Icon(
                          _getViewIcon(view),
                          size: 18,
                          color: _selectedView == view
                              ? AppTheme.ndisBlue
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          view,
                          style: TextStyle(
                            color: _selectedView == view
                                ? AppTheme.ndisBlue
                                : null,
                            fontWeight: _selectedView == view
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced Budget Summary with Glassmorphism
            GlassmorphismEffects.glassContainer(
              opacity: 0.15,
              margin: const EdgeInsets.all(16),
              child: _buildEnhancedBudgetHeader(context, _mockBudget()),
            ),

            // Advanced Data Visualizations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Interactive Budget Flow Chart
                  _buildBudgetFlowChart(
                    totalBudget: _mockBudget().totalAllocated,
                    usedBudget: _mockBudget().totalSpent,
                    categories: _getBudgetCategories(_mockBudget()),
                    title: 'Budget Flow Analysis',
                  ),

                  const SizedBox(height: 16),

                  // Health Progress Ring for Budget Health
                  GlassmorphismEffects.glassCard(
                    child: Column(
                      children: [
                        Text(
                          'Budget Health Score',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withValues(alpha: 0.1),
                            ),
                            child: const Center(
                              child: Text('Progress Ring\nPlaceholder'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Trend Chart for Spending
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Trend Chart\nPlaceholder'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Health Metrics Dashboard
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Health Metrics\nDashboard Placeholder'),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Content based on selected view
            SizedBox(
              height: 400,
              child: _selectedView == 'Overview'
                  ? _OverviewView(
                      overview: overview,
                      controller: _chartController,
                    )
                  : _selectedView == 'Detailed'
                  ? _DetailedView(
                      overview: overview,
                      controller: _progressController,
                    )
                  : _TrendsView(overview: overview),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getViewIcon(final String view) {
    switch (view) {
      case 'Overview':
        return Icons.pie_chart;
      case 'Detailed':
        return Icons.list;
      case 'Trends':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  /// Enhanced budget header with glassmorphism
  Widget _buildEnhancedBudgetHeader(
    final BuildContext context,
    final BudgetOverview overview,
  ) {
    final totalAllocated = overview.buckets.fold(
      0,
      (final sum, final bucket) => sum + bucket.allocated,
    );
    final totalSpent = overview.buckets.fold(
      0,
      (final sum, final bucket) => sum + bucket.spent,
    );
    final remaining = totalAllocated - totalSpent;
    final percentage = (remaining / totalAllocated * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.trustGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: AppTheme.trustGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NDIS Budget Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Plan period: 12 months remaining',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: percentage > 30
                    ? AppTheme.trustGreen.withValues(alpha: 0.1)
                    : AppTheme.warmAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$percentage% remaining',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: percentage > 30
                      ? AppTheme.trustGreen
                      : AppTheme.warmAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildBudgetMetric(
                context,
                'Total Budget',
                '\$${totalAllocated.toStringAsFixed(0)}',
                AppTheme.calmingBlue,
                Icons.account_balance,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBudgetMetric(
                context,
                'Used',
                '\$${totalSpent.toStringAsFixed(0)}',
                AppTheme.warmAccent,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBudgetMetric(
                context,
                'Remaining',
                '\$${remaining.toStringAsFixed(0)}',
                AppTheme.trustGreen,
                Icons.savings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetMetric(
    final BuildContext context,
    final String label,
    final String value,
    final Color color,
    final IconData icon,
  ) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  /// Get budget categories for flow chart
  List<advanced_data_visualization.BudgetCategory> _getBudgetCategories(
    final BudgetOverview overview,
  ) => overview.buckets.map((final bucket) {
    Color color;
    switch (bucket.name.toLowerCase()) {
      case 'trust':
        color = AppTheme.trustGreen;
        break;
      case 'capacity':
        color = AppTheme.calmingBlue;
        break;
      case 'capital':
        color = AppTheme.warmAccent;
        break;
      default:
        color = AppTheme.safetyGrey;
    }

    return advanced_data_visualization.BudgetCategory(
      name: bucket.name,
      amount: bucket.allocated,
      color: color,
    );
  }).toList();

  /// Get spending trend data
  List<advanced_data_visualization.ChartDataPoint> _getSpendingTrendData() => [
    advanced_data_visualization.ChartDataPoint(value: 2500, label: 'Jan'),
    advanced_data_visualization.ChartDataPoint(value: 3200, label: 'Feb'),
    advanced_data_visualization.ChartDataPoint(value: 2800, label: 'Mar'),
    advanced_data_visualization.ChartDataPoint(value: 3500, label: 'Apr'),
    advanced_data_visualization.ChartDataPoint(value: 3100, label: 'May'),
    advanced_data_visualization.ChartDataPoint(value: 2900, label: 'Jun'),
  ];

  /// Get budget health metrics
  List<advanced_data_visualization.HealthMetric> _getBudgetHealthMetrics(
    final BudgetOverview overview,
  ) {
    final totalAllocated = overview.buckets.fold(
      0,
      (final sum, final bucket) => sum + bucket.allocated,
    );
    final totalSpent = overview.buckets.fold(
      0,
      (final sum, final bucket) => sum + bucket.spent,
    );
    final utilizationRate = totalSpent / totalAllocated * 100;

    return [
      advanced_data_visualization.HealthMetric(
        title: 'Utilization Rate',
        subtitle: 'Percentage of budget used',
        value: '${utilizationRate.toStringAsFixed(1)}%',
        icon: Icons.pie_chart,
        color: utilizationRate > 80 ? AppTheme.warmAccent : AppTheme.trustGreen,
        trend: 5.2,
      ),
      advanced_data_visualization.HealthMetric(
        title: 'Monthly Average',
        subtitle: 'Average spending per month',
        value: '\$${(totalSpent / 6).toStringAsFixed(0)}',
        icon: Icons.calendar_month,
        color: AppTheme.calmingBlue,
        trend: -2.1,
      ),
      advanced_data_visualization.HealthMetric(
        title: 'Projected Balance',
        subtitle: 'Estimated remaining at plan end',
        value: '\$${((totalAllocated - totalSpent) * 0.8).toStringAsFixed(0)}',
        icon: Icons.trending_down,
        color: AppTheme.empathyPurple,
      ),
    ];
  }

  Widget _buildBudgetFlowChart({
    required final double totalBudget,
    required final double usedBudget,
    required final List<advanced_data_visualization.BudgetCategory> categories,
    required final String title,
  }) => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.blue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(child: Text('$title\nPlaceholder')),
  );

  Widget _buildSpendingAnalytics({
    required final double totalAllocated,
    required final double totalSpent,
    required final double remainingBudget,
    required final double utilizationRate,
    required final String title,
  }) => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.green.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(child: Text('$title\nPlaceholder')),
  );

  Widget _buildBudgetBreakdown({
    required final List<BudgetBucket> buckets,
    required final String title,
  }) => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(child: Text('$title\nPlaceholder')),
  );
}

// Simplified view classes
class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.overview, required this.controller});
  final BudgetOverview overview;
  final AnimationController controller;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Overview View', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const Text('Budget overview content would go here'),
      ],
    ),
  );
}

class _DetailedView extends StatelessWidget {
  const _DetailedView({required this.overview, required this.controller});
  final BudgetOverview overview;
  final AnimationController controller;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Detailed View', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const Text('Detailed budget breakdown would go here'),
      ],
    ),
  );
}

class _TrendsView extends StatelessWidget {
  const _TrendsView({required this.overview});
  final BudgetOverview overview;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Trends View', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const Text('Budget trends and analytics would go here'),
      ],
    ),
  );
}

BudgetOverview _mockBudget() => const BudgetOverview([
  BudgetBucket(name: 'Core', allocated: 12000, spent: 9800),
  BudgetBucket(name: 'Capacity', allocated: 8000, spent: 4200),
  BudgetBucket(name: 'Capital', allocated: 5000, spent: 1000),
]);
