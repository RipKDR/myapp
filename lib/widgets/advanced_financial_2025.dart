import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Advanced 2025+ financial visualization components for NDIS budget management
/// Features predictive analytics, interactive charts, and cinematic spending stories
class AdvancedFinancial2025 {
  /// Creates an interactive NDIS budget overview with predictive insights
  static Widget buildPredictiveBudgetOverview({
    required final BuildContext context,
    required final List<NDISBudgetCategory> categories,
    required final double totalAllocated,
    required final double totalSpent,
    final bool showPredictions = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final utilizationRate = totalSpent / totalAllocated;
    final daysRemaining = _calculateDaysRemaining();
    final projectedSpending =
        _calculateProjectedSpending(totalSpent, daysRemaining);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GoogleTheme.googleGreen.withValues(alpha: 0.1),
            Colors.transparent,
            GoogleTheme.googleBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GoogleTheme.googleGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial health indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getHealthColor(utilizationRate).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getHealthIcon(utilizationRate),
                  color: _getHealthColor(utilizationRate),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHealthMessage(utilizationRate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getHealthColor(utilizationRate),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan utilization: ${(utilizationRate * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Financial summary with cinematic elements
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  context: context,
                  label: 'Remaining',
                  value:
                      '\$${(totalAllocated - totalSpent).toStringAsFixed(0)}',
                  subtitle: 'of \$${totalAllocated.toStringAsFixed(0)}',
                  color: GoogleTheme.googleGreen,
                  trend: utilizationRate < 0.8 ? 'On Track' : 'Monitor',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFinancialMetric(
                  context: context,
                  label: 'Days Left',
                  value: daysRemaining.toString(),
                  subtitle: 'in current plan',
                  color: GoogleTheme.googleBlue,
                  trend: daysRemaining > 30 ? 'Plenty Time' : 'Review Soon',
                ),
              ),
            ],
          ),

          if (showPredictions) ...[
            const SizedBox(height: 24),

            // Predictive spending analysis
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GoogleTheme.googleYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GoogleTheme.googleYellow.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insights,
                    color: GoogleTheme.googleYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Budget Prediction',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: GoogleTheme.googleYellow,
                          ),
                        ),
                        Text(
                          'At current pace, you\'ll spend \$${projectedSpending.toStringAsFixed(0)} by plan end',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildFinancialMetric({
    required final BuildContext context,
    required final String label,
    required final String value,
    required final String subtitle,
    required final Color color,
    required final String trend,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            trend,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Creates cinematic spending story visualization
  static Widget buildSpendingStoryTimeline({
    required final BuildContext context,
    required final List<SpendingEvent> events,
    final Color? accentColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Spending Story',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    accentColor ?? GoogleTheme.googleGreen,
                    (accentColor ?? GoogleTheme.googleGreen).withValues(alpha: 0.7),
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
            ),
          ),

          const SizedBox(height: 20),

          // Timeline of spending events
          Column(
            children: events.map((final event) {
              final isPositive = event.type == SpendingEventType.budgetIncrease;
              final eventColor =
                  isPositive ? GoogleTheme.googleGreen : GoogleTheme.googleBlue;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: eventColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: eventColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getSpendingIcon(event.type),
                            color: eventColor,
                            size: 20,
                          ),
                        ),
                        if (events.last != event)
                          Container(
                            width: 2,
                            height: 30,
                            color: eventColor.withValues(alpha: 0.3),
                          ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Event details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${isPositive ? '+' : '-'}\$${event.amount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: eventColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatEventDate(event.date),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Creates an interactive spending category with voice control
  static Widget buildVoiceControlledBudgetCard({
    required final BuildContext context,
    required final NDISBudgetCategory category,
    final VoidCallback? onTap,
    final bool hasVoiceSupport = true,
  }) {
    final utilizationRate = category.spent / category.allocated;
    final isOverBudget = utilizationRate > 1.0;
    final isNearLimit = utilizationRate > 0.8;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: category.color.withValues(alpha: isOverBudget ? 0.6 : 0.2),
            width: isOverBudget ? 2 : 1,
          ),
          boxShadow: isOverBudget
              ? [
                  BoxShadow(
                    color: GoogleTheme.googleRed.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header with voice indicator
            Row(
              children: [
                Icon(
                  _getCategoryIcon(category.type),
                  color: category.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: category.color,
                        ),
                  ),
                ),
                if (hasVoiceSupport)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: GoogleTheme.googleGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: GoogleTheme.googleGreen,
                      size: 14,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Budget utilization bar with animation
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${category.spent.toStringAsFixed(0)} spent',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isOverBudget
                                ? GoogleTheme.googleRed
                                : category.color,
                          ),
                    ),
                    Text(
                      '\$${category.allocated.toStringAsFixed(0)} allocated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Animated progress bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: category.color.withValues(alpha: 0.2),
                  ),
                  child: Stack(
                    children: [
                      // Progress fill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1200),
                        width: (MediaQuery.of(context).size.width - 100) *
                            utilizationRate.clamp(0.0, 1.0),
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isOverBudget
                                ? [
                                    GoogleTheme.googleRed,
                                    GoogleTheme.googleRed.withValues(alpha: 0.8),
                                  ]
                                : [
                                    category.color,
                                    category.color.withValues(alpha: 0.8),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      // Warning indicator if over 80%
                      if (isNearLimit && !isOverBudget)
                        Positioned(
                          left: (MediaQuery.of(context).size.width - 100) * 0.8,
                          top: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: GoogleTheme.googleYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category description and voice tip
            Text(
              category.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),

            if (hasVoiceSupport) ...[
              const SizedBox(height: 8),
              Text(
                'Voice tip: "Show ${category.name.toLowerCase()}" or "Add expense to ${category.name.toLowerCase()}"',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: GoogleTheme.googleGreen,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates an intelligent spending insights dashboard
  static Widget buildIntelligentInsightsDashboard({
    required final BuildContext context,
    required final List<NDISBudgetCategory> categories,
    required final List<SpendingInsight> insights,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Powered Insights',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          // Insights list with priority ranking
          ...insights.map((final insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: insight.priority.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: insight.priority.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: insight.priority.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      insight.icon,
                      color: insight.priority.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (insight.actionable)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: insight.priority.color,
                    ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  // Helper methods
  static Color _getHealthColor(final double utilizationRate) {
    if (utilizationRate > 1.0) return GoogleTheme.googleRed;
    if (utilizationRate > 0.8) return GoogleTheme.googleYellow;
    return GoogleTheme.googleGreen;
  }

  static IconData _getHealthIcon(final double utilizationRate) {
    if (utilizationRate > 1.0) return Icons.warning;
    if (utilizationRate > 0.8) return Icons.info;
    return Icons.check_circle;
  }

  static String _getHealthMessage(final double utilizationRate) {
    if (utilizationRate > 1.0) return 'Budget Exceeded';
    if (utilizationRate > 0.8) return 'Monitor Spending';
    return 'Healthy Budget';
  }

  static int _calculateDaysRemaining() {
    final planEnd =
        DateTime.now().add(const Duration(days: 127)); // Mock plan end
    return planEnd.difference(DateTime.now()).inDays;
  }

  static double _calculateProjectedSpending(
      final double currentSpent, final int daysRemaining) {
    final dailyAverage =
        currentSpent / (365 - daysRemaining); // Assuming 365-day plan
    return currentSpent + (dailyAverage * daysRemaining);
  }

  static IconData _getCategoryIcon(final NDISCategoryType type) {
    switch (type) {
      case NDISCategoryType.coreSupports:
        return Icons.support;
      case NDISCategoryType.capacityBuilding:
        return Icons.trending_up;
      case NDISCategoryType.capitalSupports:
        return Icons.devices;
      case NDISCategoryType.transport:
        return Icons.directions_bus;
    }
  }

  static IconData _getSpendingIcon(final SpendingEventType type) {
    switch (type) {
      case SpendingEventType.expense:
        return Icons.shopping_cart;
      case SpendingEventType.budgetIncrease:
        return Icons.add_circle;
      case SpendingEventType.refund:
        return Icons.undo;
      case SpendingEventType.planReview:
        return Icons.rate_review;
    }
  }

  static String _formatEventDate(final DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Data models for advanced financial features
class NDISBudgetCategory {

  const NDISBudgetCategory({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.color,
    required this.description,
    required this.type,
  });
  final String name;
  final double allocated;
  final double spent;
  final Color color;
  final String description;
  final NDISCategoryType type;

  double get progress => allocated == 0 ? 0 : (spent / allocated).clamp(0, 1);
  bool get isOverBudget => spent > allocated;
}

class SpendingEvent {

  const SpendingEvent({
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final SpendingEventType type;
}

class SpendingInsight {

  const SpendingInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
    this.actionable = false,
  });
  final String title;
  final String description;
  final IconData icon;
  final InsightPriority priority;
  final bool actionable;
}

enum NDISCategoryType {
  coreSupports,
  capacityBuilding,
  capitalSupports,
  transport,
}

enum SpendingEventType {
  expense,
  budgetIncrease,
  refund,
  planReview,
}

enum InsightPriority {
  high,
  medium,
  low,
}

extension InsightPriorityColor on InsightPriority {
  Color get color {
    switch (this) {
      case InsightPriority.high:
        return GoogleTheme.googleRed;
      case InsightPriority.medium:
        return GoogleTheme.googleYellow;
      case InsightPriority.low:
        return GoogleTheme.googleGreen;
    }
  }
}
