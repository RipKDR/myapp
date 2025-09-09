import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../widgets/budget_pie.dart';
import '../widgets/advanced_data_visualization.dart';
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
  Widget build(BuildContext context) {
    final overview = _mockBudget();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedView = value),
            itemBuilder: (context) => _views.map((view) {
              return PopupMenuItem(
                value: view,
                child: Row(
                  children: [
                    Icon(
                      _getViewIcon(view),
                      size: 18,
                      color: _selectedView == view ? AppTheme.ndisBlue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      view,
                      style: TextStyle(
                        color: _selectedView == view ? AppTheme.ndisBlue : null,
                        fontWeight:
                            _selectedView == view ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced Budget Summary with Glassmorphism
            GlassmorphismEffects.glassContainer(
              blur: 10.0,
              opacity: 0.15,
              margin: const EdgeInsets.all(16),
              child: _buildEnhancedBudgetHeader(context, overview),
            ),
            
            // Advanced Data Visualizations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Interactive Budget Flow Chart
                  AdvancedDataVisualization.buildBudgetFlowChart(
                    totalBudget: overview.totalAllocated,
                    usedBudget: overview.totalSpent,
                    categories: _getBudgetCategories(overview),
                    title: 'Budget Flow Analysis',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Health Progress Ring for Budget Health
                  GlassmorphismEffects.glassCard(
                    child: Column(
                      children: [
                        Text(
                          'Budget Health Score',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: AdvancedDataVisualization.buildHealthProgressRing(
                            primaryValue: (overview.totalAllocated - overview.totalSpent) / overview.totalAllocated,
                            secondaryValue: overview.totalSpent / overview.totalAllocated,
                            primaryLabel: 'Available',
                            secondaryLabel: 'Used',
                            primaryColor: AppTheme.trustGreen,
                            secondaryColor: AppTheme.warmAccent,
                            size: 140,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Trend Chart for Spending
                  AdvancedDataVisualization.buildTrendChart(
                    data: _getSpendingTrendData(),
                    title: 'Spending Trends',
                    subtitle: 'Monthly spending patterns',
                    accentColor: AppTheme.calmingBlue,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Health Metrics Dashboard
                  AdvancedDataVisualization.buildHealthScoreDashboard(
                    metrics: _getBudgetHealthMetrics(overview),
                    title: 'Budget Health Metrics',
                    subtitle: 'Key indicators for your NDIS plan',
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Content based on selected view
            Container(
              height: 400,
              child: _selectedView == 'Overview'
                  ? _OverviewView(
                      overview: overview, controller: _chartController)
                  : _selectedView == 'Detailed'
                      ? _DetailedView(
                          overview: overview, controller: _progressController)
                      : _TrendsView(overview: overview),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getViewIcon(String view) {
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
  Widget _buildEnhancedBudgetHeader(BuildContext context, BudgetOverview overview) {
    final totalAllocated = overview.buckets.fold(0.0, (sum, bucket) => sum + bucket.allocated);
    final totalSpent = overview.buckets.fold(0.0, (sum, bucket) => sum + bucket.spent);
    final remaining = totalAllocated - totalSpent;
    final percentage = (remaining / totalAllocated * 100).round();
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.trustGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
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
                color: percentage > 30 ? AppTheme.trustGreen.withOpacity(0.1) : AppTheme.warmAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$percentage% remaining',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: percentage > 30 ? AppTheme.trustGreen : AppTheme.warmAccent,
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

  Widget _buildBudgetMetric(BuildContext context, String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
  }

  /// Get budget categories for flow chart
  List<BudgetCategory> _getBudgetCategories(BudgetOverview overview) {
    return overview.buckets.map((bucket) {
      Color color;
      switch (bucket.name.toLowerCase()) {
        case 'core':
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
      
      return BudgetCategory(
        name: bucket.name,
        amount: bucket.spent,
        color: color,
      );
    }).toList();
  }

  /// Get spending trend data
  List<ChartDataPoint> _getSpendingTrendData() {
    return [
      ChartDataPoint(value: 2500, label: 'Jan'),
      ChartDataPoint(value: 3200, label: 'Feb'),
      ChartDataPoint(value: 2800, label: 'Mar'),
      ChartDataPoint(value: 3500, label: 'Apr'),
      ChartDataPoint(value: 3100, label: 'May'),
      ChartDataPoint(value: 2900, label: 'Jun'),
    ];
  }

  /// Get budget health metrics
  List<HealthMetric> _getBudgetHealthMetrics(BudgetOverview overview) {
    final totalAllocated = overview.buckets.fold(0.0, (sum, bucket) => sum + bucket.allocated);
    final totalSpent = overview.buckets.fold(0.0, (sum, bucket) => sum + bucket.spent);
    final utilizationRate = (totalSpent / totalAllocated * 100);
    
    return [
      HealthMetric(
        title: 'Utilization Rate',
        subtitle: 'Percentage of budget used',
        value: '${utilizationRate.toStringAsFixed(1)}%',
        icon: Icons.pie_chart,
        color: utilizationRate > 80 ? AppTheme.warmAccent : AppTheme.trustGreen,
        trend: 5.2,
      ),
      HealthMetric(
        title: 'Monthly Average',
        subtitle: 'Average spending per month',
        value: '\$${(totalSpent / 6).toStringAsFixed(0)}',
        icon: Icons.calendar_month,
        color: AppTheme.calmingBlue,
        trend: -2.1,
      ),
      HealthMetric(
        title: 'Projected Balance',
        subtitle: 'Estimated remaining at plan end',
        value: '\$${((totalAllocated - totalSpent) * 0.8).toStringAsFixed(0)}',
        icon: Icons.trending_down,
        color: AppTheme.empathyPurple,
        trend: null,
      ),
    ];
  }
}

// Simplified view classes
class _OverviewView extends StatelessWidget {
  final BudgetOverview overview;
  final AnimationController controller;

  const _OverviewView({required this.overview, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Overview View', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Budget overview content would go here'),
        ],
      ),
    );
  }
}

class _DetailedView extends StatelessWidget {
  final BudgetOverview overview;
  final AnimationController controller;

  const _DetailedView({required this.overview, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Detailed View', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Detailed budget breakdown would go here'),
        ],
      ),
    );
  }
}

class _TrendsView extends StatelessWidget {
  final BudgetOverview overview;

  const _TrendsView({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Trends View', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Budget trends and analytics would go here'),
        ],
      ),
    );
  }
}

BudgetOverview _mockBudget() {
  return const BudgetOverview([
    BudgetBucket(name: 'Core', allocated: 12000, spent: 9800),
    BudgetBucket(name: 'Capacity', allocated: 8000, spent: 4200),
    BudgetBucket(name: 'Capital', allocated: 5000, spent: 1000),
  ]);
}
