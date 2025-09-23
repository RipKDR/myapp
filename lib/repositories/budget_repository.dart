import '../models/budget.dart';
import '../services/firestore_service.dart';

class BudgetRepository {
  static const _col = 'budgets';

  // Save budget overview for user
  static Future<bool> saveOverview(final String userId, final BudgetOverview budget) async {
    final data = {
      'userId': userId,
      'buckets': budget.buckets
          .map(
            (final bucket) => {
              'name': bucket.name,
              'allocated': bucket.allocated,
              'spent': bucket.spent,
              'category': bucket.name.toLowerCase(),
            },
          )
          .toList(),
      'totalAllocated': budget.totalAllocated,
      'totalSpent': budget.totalSpent,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    return FirestoreService.save(_col, userId, data);
  }

  // Get budget overview for user
  static Future<BudgetOverview?> getOverview(final String userId) async {
    final data = await FirestoreService.get(_col, userId);
    if (data == null) return null;

    try {
      final buckets = (data['buckets'] as List)
          .map(
            (final bucket) => BudgetBucket(
              name: bucket['name'] as String,
              allocated: (bucket['allocated'] as num).toDouble(),
              spent: (bucket['spent'] as num).toDouble(),
            ),
          )
          .toList();

      return BudgetOverview(buckets);
    } catch (e) {
      return null;
    }
  }

  // Stream budget overview for user
  static Stream<BudgetOverview?> streamForUser(final String userId) => FirestoreService.query(_col, field: 'userId', value: userId).map((
      final list,
    ) {
      if (list.isEmpty) return null;

      try {
        final data = list.first;
        final buckets = (data['buckets'] as List)
            .map(
              (final bucket) => BudgetBucket(
                name: bucket['name'] as String,
                allocated: (bucket['allocated'] as num).toDouble(),
                spent: (bucket['spent'] as num).toDouble(),
              ),
            )
            .toList();

        return BudgetOverview(buckets);
      } catch (e) {
        return null;
      }
    });

  // Add expense to budget
  static Future<bool> addExpense(
    final String userId,
    final String category,
    final double amount,
    final String description,
  ) async {
    final budget = await getOverview(userId);
    if (budget == null) return false;

    // Find the bucket and update spent amount
    final updatedBuckets = budget.buckets.map((final bucket) {
      if (bucket.name.toLowerCase() == category.toLowerCase()) {
        return BudgetBucket(
          name: bucket.name,
          allocated: bucket.allocated,
          spent: bucket.spent + amount,
        );
      }
      return bucket;
    }).toList();

    final updatedBudget = BudgetOverview(updatedBuckets);
    return saveOverview(userId, updatedBudget);
  }

  // Update budget allocation
  static Future<bool> updateAllocation(
    final String userId,
    final String category,
    final double newAllocation,
  ) async {
    final budget = await getOverview(userId);
    if (budget == null) return false;

    final updatedBuckets = budget.buckets.map((final bucket) {
      if (bucket.name.toLowerCase() == category.toLowerCase()) {
        return BudgetBucket(
          name: bucket.name,
          allocated: newAllocation,
          spent: bucket.spent,
        );
      }
      return bucket;
    }).toList();

    final updatedBudget = BudgetOverview(updatedBuckets);
    return saveOverview(userId, updatedBudget);
  }

  // Get budget statistics
  static Future<Map<String, dynamic>> getStats(final String userId) async {
    final budget = await getOverview(userId);
    if (budget == null) {
      return {
        'totalAllocated': 0.0,
        'totalSpent': 0.0,
        'remaining': 0.0,
        'utilizationPercentage': 0.0,
        'buckets': <Map<String, dynamic>>[],
      };
    }

    final buckets = budget.buckets
        .map(
          (final bucket) => {
            'name': bucket.name,
            'allocated': bucket.allocated,
            'spent': bucket.spent,
            'remaining': bucket.allocated - bucket.spent,
            'utilizationPercentage': bucket.allocated > 0
                ? (bucket.spent / bucket.allocated) * 100
                : 0.0,
          },
        )
        .toList();

    return {
      'totalAllocated': budget.totalAllocated,
      'totalSpent': budget.totalSpent,
      'remaining': budget.totalAllocated - budget.totalSpent,
      'utilizationPercentage': budget.totalAllocated > 0
          ? (budget.totalSpent / budget.totalAllocated) * 100
          : 0.0,
      'buckets': buckets,
    };
  }

  // Check if budget is over 80% utilized (for alerts)
  static Future<bool> isOverUtilized(
    final String userId, {
    final double threshold = 0.8,
  }) async {
    final budget = await getOverview(userId);
    if (budget == null) return false;

    return budget.totalAllocated > 0 &&
        (budget.totalSpent / budget.totalAllocated) >= threshold;
  }

  // Get budget alerts
  static Future<List<String>> getAlerts(final String userId) async {
    final budget = await getOverview(userId);
    if (budget == null) return [];

    final alerts = <String>[];

    // Check overall utilization
    if (budget.totalAllocated > 0) {
      final utilization = budget.totalSpent / budget.totalAllocated;
      if (utilization >= 0.9) {
        alerts.add('Budget is 90% utilized. Consider reviewing your spending.');
      } else if (utilization >= 0.8) {
        alerts.add('Budget is 80% utilized. Monitor your spending closely.');
      }
    }

    // Check individual buckets
    for (final bucket in budget.buckets) {
      if (bucket.allocated > 0) {
        final utilization = bucket.spent / bucket.allocated;
        if (utilization >= 0.9) {
          alerts.add('${bucket.name} budget is 90% utilized.');
        } else if (utilization >= 0.8) {
          alerts.add('${bucket.name} budget is 80% utilized.');
        }
      }
    }

    return alerts;
  }
}
