import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import '../services/advanced_analytics_service.dart';
import '../controllers/gamification_controller.dart';

/// Advanced Analytics Dashboard with comprehensive data visualization,
/// predictive analytics, and personalized insights
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final AdvancedAnalyticsService _analyticsService = AdvancedAnalyticsService();

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  AnalyticsDashboard? _dashboard;
  BudgetForecast? _budgetForecast;
  UserBehaviorInsights? _behaviorInsights;
  List<PersonalizedRecommendation> _recommendations = [];

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Load analytics data in parallel
      final results = await Future.wait([
        _analyticsService.getUserAnalyticsDashboard(),
        _analyticsService.getBudgetForecast(),
        _analyticsService.getUserBehaviorInsights(),
        _analyticsService.getPersonalizedRecommendations(),
      ]);

      setState(() {
        _dashboard = results[0] as AnalyticsDashboard;
        _budgetForecast = results[1] as BudgetForecast;
        _behaviorInsights = results[2] as UserBehaviorInsights;
        _recommendations = results[3] as List<PersonalizedRecommendation>;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAnalytics,
            tooltip: 'Share Analytics',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Performance'),
            Tab(icon: Icon(Icons.insights), text: 'Insights'),
            Tab(icon: Icon(Icons.recommend), text: 'Recommendations'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPerformanceTab(),
          _buildInsightsTab(),
          _buildRecommendationsTab(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildShimmerCard(height: 200),
          const SizedBox(height: 16),
          _buildShimmerCard(height: 150),
          const SizedBox(height: 16),
          _buildShimmerCard(height: 300),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/error.json', width: 200, height: 200),
          const SizedBox(height: 24),
          Text(
            'Failed to Load Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unexpected error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAnalyticsData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_dashboard == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildBudgetOverview(),
          const SizedBox(height: 24),
          _buildAppointmentOverview(),
          const SizedBox(height: 24),
          _buildProviderOverview(),
          const SizedBox(height: 24),
          _buildSupportCircleOverview(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final gamification = context.watch<GamificationController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Points',
                    gamification.points.toString(),
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Level',
                    gamification.level.toString(),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Streak',
                    '${gamification.streakDays} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    if (_dashboard?.budgetAnalytics == null) return const SizedBox.shrink();

    final budget = _dashboard!.budgetAnalytics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBudgetGauge(
                    'Total Spent',
                    budget.totalSpent,
                    budget.totalSpent + budget.totalRemaining,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBudgetGauge(
                    'Remaining',
                    budget.totalRemaining,
                    budget.totalSpent + budget.totalRemaining,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryBreakdown(budget.categoryBreakdown),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetGauge(
    String title,
    double value,
    double max,
    Color color,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: max,
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: value, color: color),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(value: value, enableAnimation: true),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      '\$${value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.5,
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Map<String, double> breakdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...breakdown.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(entry.key)),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value:
                        entry.value / breakdown.values.reduce((a, b) => a + b),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 8),
                Text('\$${entry.value.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentOverview() {
    if (_dashboard?.appointmentAnalytics == null)
      return const SizedBox.shrink();

    final appointments = _dashboard!.appointmentAnalytics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    appointments.totalAppointments.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Upcoming',
                    appointments.upcomingAppointments.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    appointments.completedAppointments.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderOverview() {
    if (_dashboard?.providerAnalytics == null) return const SizedBox.shrink();

    final providers = _dashboard!.providerAnalytics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Searches',
                    providers.totalSearches.toString(),
                    Icons.search,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Results',
                    providers.averageResults.toString(),
                    Icons.list,
                    Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTopSearchTerms(providers.topSearchTerms),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSearchTerms(List<String> searchTerms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Search Terms',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: searchTerms
              .take(5)
              .map(
                (term) => Chip(
                  label: Text(term),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSupportCircleOverview() {
    if (_dashboard?.supportCircleAnalytics == null)
      return const SizedBox.shrink();

    final support = _dashboard!.supportCircleAnalytics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support Circle Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Circles',
                    support.totalCircles.toString(),
                    Icons.group,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Members',
                    support.activeMembers.toString(),
                    Icons.people,
                    Colors.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Events',
                    support.collaborationEvents.toString(),
                    Icons.event,
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_dashboard?.performanceMetrics == null) return const SizedBox.shrink();

    final performance = _dashboard!.performanceMetrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceOverview(performance),
          const SizedBox(height: 24),
          _buildResponseTimeChart(performance.averageResponseTimes),
          const SizedBox(height: 24),
          _buildSlowestOperations(performance.slowestOperations),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(PerformanceMetrics performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Response',
                    '${performance.averageResponseTimes.values.isNotEmpty ? performance.averageResponseTimes.values.reduce((a, b) => a + b) / performance.averageResponseTimes.length : 0}ms',
                    Icons.speed,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Slow Operations',
                    performance.slowestOperations.length.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTimeChart(Map<String, double> responseTimes) {
    if (responseTimes.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Response Times',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: responseTimes.values.isNotEmpty
                      ? responseTimes.values.reduce((a, b) => a > b ? a : b) *
                            1.2
                      : 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < responseTimes.keys.length) {
                            return Text(
                              responseTimes.keys.elementAt(index),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}ms'),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: responseTimes.entries.map((entry) {
                    final index = responseTimes.keys.toList().indexOf(
                      entry.key,
                    );
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: _getColorForIndex(index),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlowestOperations(List<String> operations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slowest Operations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...operations
                .take(5)
                .map(
                  (operation) => ListTile(
                    leading: const Icon(Icons.timer, color: Colors.orange),
                    title: Text(operation),
                    subtitle: const Text('Needs optimization'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsTab() {
    if (_behaviorInsights == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsagePatterns(_behaviorInsights!.usagePatterns),
          const SizedBox(height: 24),
          _buildEngagementMetrics(_behaviorInsights!.engagementMetrics),
          const SizedBox(height: 24),
          _buildAccessibilityUsage(_behaviorInsights!.accessibilityUsage),
          const SizedBox(height: 24),
          _buildFeatureAdoption(_behaviorInsights!.featureAdoption),
        ],
      ),
    );
  }

  Widget _buildUsagePatterns(UsagePatterns patterns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Patterns',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Session Duration',
                    '${patterns.sessionDuration} min',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Frequency',
                    '${patterns.frequency}/week',
                    Icons.repeat,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics(EngagementMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement Metrics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Daily Minutes',
                    metrics.dailyActiveMinutes.toString(),
                    Icons.access_time,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Retention',
                    '${(metrics.weeklyRetention * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilityUsage(AccessibilityUsage usage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility Usage',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Enabled Features',
                    usage.enabledFeatures.length.toString(),
                    Icons.accessibility,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Effectiveness',
                    '${(usage.effectiveness * 100).toStringAsFixed(1)}%',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureAdoption(FeatureAdoption adoption) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Adoption',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Adopted',
                    adoption.adoptedFeatures.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    adoption.pendingFeatures.length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_budgetForecast != null) ...[
            _buildBudgetForecastCard(_budgetForecast!),
            const SizedBox(height: 24),
          ],
          _buildRecommendationsList(_recommendations),
        ],
      ),
    );
  }

  Widget _buildBudgetForecastCard(BudgetForecast forecast) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Forecast',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Current Spending',
                    '\$${forecast.currentSpending.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Projected',
                    '\$${forecast.projectedSpending.toStringAsFixed(0)}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Budget Exhaustion: ${_formatDate(forecast.budgetExhaustionDate)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Confidence: ${(forecast.confidence * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(
    List<PersonalizedRecommendation> recommendations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Recommendations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...recommendations.map(
              (recommendation) => _buildRecommendationTile(recommendation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(PersonalizedRecommendation recommendation) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPriorityColor(recommendation.priority),
        child: Icon(
          _getRecommendationIcon(recommendation.type),
          color: Colors.white,
        ),
      ),
      title: Text(recommendation.title),
      subtitle: Text(recommendation.description),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: () => _handleRecommendationAction(recommendation),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  Color _getPriorityColor(double priority) {
    if (priority >= 0.8) return Colors.red;
    if (priority >= 0.6) return Colors.orange;
    if (priority >= 0.4) return Colors.yellow;
    return Colors.green;
  }

  IconData _getRecommendationIcon(String type) {
    switch (type) {
      case 'budget':
        return Icons.account_balance_wallet;
      case 'appointment':
        return Icons.calendar_today;
      case 'provider':
        return Icons.person_search;
      case 'accessibility':
        return Icons.accessibility;
      default:
        return Icons.lightbulb;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleRecommendationAction(PersonalizedRecommendation recommendation) {
    // Handle recommendation action based on type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action: ${recommendation.action}'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _shareAnalytics() {
    // Implement analytics sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics sharing feature coming soon!')),
    );
  }
}
