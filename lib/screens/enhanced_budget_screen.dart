import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/financial_visualization_components.dart';
import '../widgets/advanced_dashboard_components.dart';
import '../widgets/enhanced_form_components.dart';
import '../widgets/trending_2025_components.dart';
import '../widgets/neo_brutalism_components.dart';
import '../widgets/advanced_glassmorphism_2025.dart';
import '../widgets/cinematic_data_storytelling.dart';
import '../widgets/advanced_financial_2025.dart';

/// Enhanced budget management screen with advanced financial visualizations
/// Following 2025 design trends with sophisticated NDIS funding management
class EnhancedBudgetScreen extends StatefulWidget {
  const EnhancedBudgetScreen({super.key});

  @override
  State<EnhancedBudgetScreen> createState() => _EnhancedBudgetScreenState();
}

class _EnhancedBudgetScreenState extends State<EnhancedBudgetScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerController;
  late AnimationController _contentController;

  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  // Enhanced NDIS budget data with 2025+ features
  final List<NDISBudgetCategory> _budgetCategories = [
    NDISBudgetCategory(
      name: 'Core Supports',
      allocated: 12000,
      spent: 8400,
      color: GoogleTheme.googleBlue,
      description: 'Assistance with daily personal activities and self-care',
      type: NDISCategoryType.coreSupports,
    ),
    NDISBudgetCategory(
      name: 'Capacity Building',
      allocated: 8000,
      spent: 5200,
      color: GoogleTheme.googleGreen,
      description: 'Support to build independence and life skills',
      type: NDISCategoryType.capacityBuilding,
    ),
    NDISBudgetCategory(
      name: 'Capital Supports',
      allocated: 5000,
      spent: 1800,
      color: GoogleTheme.ndisTeal,
      description: 'Assistive technology and home modifications',
      type: NDISCategoryType.capitalSupports,
    ),
    NDISBudgetCategory(
      name: 'Transport',
      allocated: 3000,
      spent: 2100,
      color: GoogleTheme.ndisPurple,
      description: 'Transport to access community and services',
      type: NDISCategoryType.transport,
    ),
  ];

  // Enhanced spending events for cinematic storytelling
  final List<SpendingEvent> _spendingEvents = [
    SpendingEvent(
      title: 'Physiotherapy Session',
      description: 'FlexCare Physiotherapy - Session #12',
      amount: 89.50,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: SpendingEventType.expense,
    ),
    SpendingEvent(
      title: 'OT Assessment',
      description: 'Ability OT Services - Home modification assessment',
      amount: 125.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: SpendingEventType.expense,
    ),
    SpendingEvent(
      title: 'Plan Review Approved',
      description: 'Additional capacity building funding approved',
      amount: 2000.00,
      date: DateTime.now().subtract(const Duration(days: 14)),
      type: SpendingEventType.budgetIncrease,
    ),
  ];

  // AI-generated spending insights
  final List<SpendingInsight> _spendingInsights = [
    SpendingInsight(
      title: 'Excellent Budget Management',
      description:
          'Your spending pace ensures full budget utilization by plan end',
      icon: Icons.thumb_up,
      priority: InsightPriority.low,
      actionable: false,
    ),
    SpendingInsight(
      title: 'Transport Budget Alert',
      description:
          'Transport category is 70% used. Consider booking transport-included sessions',
      icon: Icons.warning,
      priority: InsightPriority.medium,
      actionable: true,
    ),
    SpendingInsight(
      title: 'Capital Supports Opportunity',
      description:
          'You have \$3,200 unused in Capital Supports. Review assistive technology options',
      icon: Icons.lightbulb,
      priority: InsightPriority.high,
      actionable: true,
    ),
  ];

  final List<SpendingDataPoint> _spendingTrend = [
    SpendingDataPoint(
        date: DateTime.now().subtract(const Duration(days: 30)), amount: 1200),
    SpendingDataPoint(
        date: DateTime.now().subtract(const Duration(days: 25)), amount: 1800),
    SpendingDataPoint(
        date: DateTime.now().subtract(const Duration(days: 20)), amount: 1600),
    SpendingDataPoint(
        date: DateTime.now().subtract(const Duration(days: 15)), amount: 2200),
    SpendingDataPoint(
        date: DateTime.now().subtract(const Duration(days: 10)), amount: 1900),
    SpendingDataPoint(
        date: DateTime.now().subtract(const Duration(days: 5)), amount: 2400),
    SpendingDataPoint(date: DateTime.now(), amount: 2800),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupScrollListener();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 150;
      if (shouldShow != _showAppBarTitle) {
        setState(() => _showAppBarTitle = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(context),
          ];
        },
        body: AnimatedBuilder(
          animation: _contentController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _contentController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _contentController,
                  curve: Curves.easeOutCubic,
                )),
                child: Column(
                  children: [
                    _buildTabBar(context),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(context),
                          _buildCategoriesTab(context),
                          _buildTransactionsTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: AdvancedGlassmorphism2025.buildFloatingGlassButton(
        icon: Icons.add,
        onPressed: _showEnhancedAddExpenseDialog,
        backgroundColor: GoogleTheme.googleGreen,
        size: 56.0,
        isPulsing: false,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final totalAllocated =
        _budgetCategories.fold<double>(0, (sum, cat) => sum + cat.allocated);
    final totalSpent =
        _budgetCategories.fold<double>(0, (sum, cat) => sum + cat.spent);
    final utilizationRate = totalSpent / totalAllocated;

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Text('Budget Management'),
      ),
      actions: [
        // Voice budget queries
        Trending2025Components.buildInteractiveButton(
          label: 'Voice',
          onPressed: _activateVoiceBudgetQuery,
          icon: Icons.mic,
          isPrimary: false,
          backgroundColor: GoogleTheme.googleGreen,
          hasRippleEffect: true,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showBudgetSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Budget Settings',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: NeoBrutalismComponents.buildStrikingHeader(
          context: context,
          title: 'NDIS Budget Control',
          subtitle: 'Smart financial management',
          backgroundColor: GoogleTheme.googleGreen,
          trailing: CinematicDataStoryTelling.buildAnimatedDataStory(
            context: context,
            title: 'Budget Health',
            value: '${(utilizationRate * 100).toStringAsFixed(0)}%',
            previousValue:
                '${((utilizationRate - 0.05) * 100).toStringAsFixed(0)}%',
            trendDescription:
                utilizationRate < 0.8 ? 'Excellent control' : 'Monitor closely',
            icon: Icons.account_balance_wallet,
            color: utilizationRate < 0.8
                ? GoogleTheme.googleGreen
                : GoogleTheme.googleYellow,
            showCelebration: utilizationRate < 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: GoogleTheme.googleBlue,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: GoogleTheme.googleBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Categories'),
          Tab(text: 'Transactions'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget visualization
          _buildBudgetVisualization(context),

          const SizedBox(height: 24),

          // Spending trend
          _buildSpendingTrend(context),

          const SizedBox(height: 24),

          // Quick insights
          if (isMobile)
            _buildMobileInsights(context)
          else
            _buildDesktopInsights(context),
        ],
      ),
    );
  }

  Widget _buildBudgetVisualization(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (isMobile)
            Column(
              children: [
                BudgetDonutChart(
                  categories: _budgetCategories,
                  size: 200,
                  onSegmentTap: _showCategoryDetails,
                ),
                const SizedBox(height: 20),
                _buildBudgetSummary(),
              ],
            )
          else
            Row(
              children: [
                BudgetDonutChart(
                  categories: _budgetCategories,
                  size: 250,
                  onSegmentTap: _showCategoryDetails,
                ),
                const SizedBox(width: 32),
                Expanded(child: _buildBudgetSummary()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final theme = Theme.of(context);
    final totalAllocated =
        _budgetCategories.fold<double>(0, (sum, cat) => sum + cat.allocated);
    final totalSpent =
        _budgetCategories.fold<double>(0, (sum, cat) => sum + cat.spent);
    final utilizationRate = (totalSpent / totalAllocated * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Utilization Rate',
          value: '${utilizationRate.toStringAsFixed(1)}%',
          subtitle: 'of total budget',
          icon: Icons.analytics,
          color: utilizationRate > 80
              ? GoogleTheme.googleRed
              : GoogleTheme.googleGreen,
          customContent: LinearProgressIndicator(
            value: utilizationRate / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              utilizationRate > 80
                  ? GoogleTheme.googleRed
                  : GoogleTheme.googleGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickStats(),
      ],
    );
  }

  Widget _buildQuickStats() {
    final theme = Theme.of(context);
    final overBudgetCategories =
        _budgetCategories.where((cat) => cat.isOverBudget).length;
    final nearLimitCategories = _budgetCategories
        .where((cat) => cat.progress > 0.8 && !cat.isOverBudget)
        .length;

    return Column(
      children: [
        _buildStatRow('Categories Over Budget', overBudgetCategories.toString(),
            GoogleTheme.googleRed),
        const SizedBox(height: 8),
        _buildStatRow('Categories Near Limit', nearLimitCategories.toString(),
            GoogleTheme.googleYellow),
        const SizedBox(height: 8),
        _buildStatRow('Days Until Plan End', '127', GoogleTheme.googleBlue),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingTrend(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Spending Trend',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showDetailedTrend,
                icon: const Icon(Icons.timeline, size: 16),
                label: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SpendingTrendChart(
            data: _spendingTrend,
            height: 200,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrendStat('This Week', '\$2,800', '+16.7%', true),
              _buildTrendStat('This Month', '\$8,400', '+12.3%', true),
              _buildTrendStat('Average', '\$1,950', 'per week', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendStat(
      String label, String value, String change, bool isPercentage) {
    final theme = Theme.of(context);
    final isPositive = isPercentage && change.startsWith('+');

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isPercentage) ...[
          const SizedBox(height: 2),
          Text(
            change,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isPositive ? GoogleTheme.googleRed : GoogleTheme.googleGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          const SizedBox(height: 2),
          Text(
            change,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileInsights(BuildContext context) {
    return Column(
      children: [
        _buildInsightCard(
            'Budget Alert',
            'Core Supports category is 70% utilized',
            GoogleTheme.googleYellow,
            Icons.warning_amber),
        const SizedBox(height: 16),
        _buildInsightCard(
            'Recommendation',
            'Consider reviewing transport expenses',
            GoogleTheme.googleBlue,
            Icons.lightbulb_outline),
        const SizedBox(height: 16),
        _buildInsightCard('Achievement', 'Stayed within budget for 3 months',
            GoogleTheme.googleGreen, Icons.celebration),
      ],
    );
  }

  Widget _buildDesktopInsights(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildInsightCard(
                'Budget Alert',
                'Core Supports category is 70% utilized',
                GoogleTheme.googleYellow,
                Icons.warning_amber)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildInsightCard(
                'Recommendation',
                'Consider reviewing transport expenses',
                GoogleTheme.googleBlue,
                Icons.lightbulb_outline)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildInsightCard(
                'Achievement',
                'Stayed within budget for 3 months',
                GoogleTheme.googleGreen,
                Icons.celebration)),
      ],
    );
  }

  Widget _buildInsightCard(
      String title, String description, Color color, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _budgetCategories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BudgetCategoryBar(
              category: category,
              onTap: () => _showCategoryDetails(category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _showTransactionFilters,
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
              ),
            ],
          ),
        ),

        // Transactions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10, // Mock data
            itemBuilder: (context, index) {
              return _buildTransactionItem(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final mockTransactions = [
      {
        'title': 'Physiotherapy Session',
        'amount': -150.0,
        'category': 'Core Supports',
        'date': 'Today'
      },
      {
        'title': 'Transport Allowance',
        'amount': -45.0,
        'category': 'Transport',
        'date': 'Yesterday'
      },
      {
        'title': 'Equipment Purchase',
        'amount': -320.0,
        'category': 'Capital Supports',
        'date': '2 days ago'
      },
      {
        'title': 'Skill Building Workshop',
        'amount': -200.0,
        'category': 'Capacity Building',
        'date': '3 days ago'
      },
      {
        'title': 'Budget Adjustment',
        'amount': 500.0,
        'category': 'Core Supports',
        'date': '1 week ago'
      },
    ];

    final transaction = mockTransactions[index % mockTransactions.length];
    final isExpense = (transaction['amount'] as double) < 0;
    final color = isExpense ? GoogleTheme.googleRed : GoogleTheme.googleGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction['category']} • ${transaction['date']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}\$${(transaction['amount'] as double).abs().toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _showCategoryDetails(BudgetCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoryDetailsSheet(category),
    );
  }

  Widget _buildCategoryDetailsSheet(BudgetCategory category) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (category.description != null) ...[
            Text(
              category.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
          ],
          BudgetCategoryBar(
            category: category,
            isInteractive: false,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: EnhancedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddExpenseDialog(category: category);
                  },
                  child: const Text('Add Expense'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Show category transactions
                  },
                  isSecondary: true,
                  child: const Text('View History'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog({BudgetCategory? category}) {
    showDialog(
      context: context,
      builder: (context) => _buildAddExpenseDialog(category),
    );
  }

  Widget _buildAddExpenseDialog(BudgetCategory? category) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EnhancedTextField(
            controller: TextEditingController(),
            label: 'Description',
            hint: 'Enter expense description',
            prefixIcon: Icons.description,
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: TextEditingController(),
            label: 'Amount',
            hint: 'Enter amount',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            value: category?.name,
            items: _budgetCategories.map((cat) {
              return DropdownMenuItem(
                value: cat.name,
                child: Text(cat.name),
              );
            }).toList(),
            onChanged: (value) {},
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        EnhancedButton(
          onPressed: () {
            Navigator.pop(context);
            _addExpense();
          },
          child: const Text('Add Expense'),
        ),
      ],
    );
  }

  void _addExpense() {
    // TODO: Implement add expense functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully')),
    );
  }

  void _showBudgetSettings() {
    // TODO: Implement budget settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget settings feature coming soon')),
    );
  }

  void _exportBudgetReport() {
    // TODO: Implement export functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget report exported')),
    );
  }

  void _showDetailedTrend() {
    // TODO: Implement detailed trend view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed trend view coming soon')),
    );
  }

  void _showTransactionFilters() {
    // TODO: Implement transaction filters
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction filters coming soon')),
    );
  }
}
