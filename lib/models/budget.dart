class BudgetBucket {
  final String name; // e.g., Core, Capacity, Capital
  final double allocated;
  final double spent;

  const BudgetBucket({
    required this.name,
    required this.allocated,
    required this.spent,
  });

  double get remaining => (allocated - spent).clamp(0, allocated);
  double get percentUsed => allocated == 0 ? 0 : (spent / allocated).clamp(0, 1);
}

class BudgetOverview {
  final List<BudgetBucket> buckets;
  const BudgetOverview(this.buckets);

  double get totalAllocated => buckets.fold(0, (s, b) => s + b.allocated);
  double get totalSpent => buckets.fold(0, (s, b) => s + b.spent);
}

// New Budget models to satisfy tests
class BudgetCategory {
  final String name;
  final double allocatedAmount;
  final double usedAmount;

  const BudgetCategory({
    required this.name,
    required this.allocatedAmount,
    required this.usedAmount,
  }) : assert(allocatedAmount >= 0), assert(usedAmount >= 0);

  double get remainingAmount => (allocatedAmount - usedAmount).clamp(0, allocatedAmount);
  double get usagePercentage => allocatedAmount == 0 ? 0 : (usedAmount / allocatedAmount).clamp(0, 1);

  BudgetCategory copyWith({double? allocatedAmount, double? usedAmount}) => BudgetCategory(
        name: name,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        usedAmount: usedAmount ?? this.usedAmount,
      );
}

class Budget {
  final String id;
  final String participantId;
  final double totalAmount;
  final double usedAmount;
  final Map<String, BudgetCategory> categories;

  Budget({
    required this.id,
    required this.participantId,
    required this.totalAmount,
    this.usedAmount = 0,
    Map<String, BudgetCategory>? categories,
  })  : categories = categories ?? const {},
        assert(id.isNotEmpty),
        assert(participantId.isNotEmpty) {
    if (totalAmount <= 0) {
      throw ArgumentError('totalAmount must be positive');
    }
    if (usedAmount < 0) {
      throw ArgumentError('usedAmount cannot be negative');
    }
  }

  double get remainingAmount => (totalAmount - usedAmount).clamp(0, totalAmount);
  double get usagePercentage => totalAmount == 0 ? 0 : (usedAmount / totalAmount).clamp(0, 1);
  bool get isNearLimit => usagePercentage >= 0.8 && !isOverLimit;
  bool get isOverLimit => usedAmount > totalAmount;

  Budget copyWith({
    String? id,
    String? participantId,
    double? totalAmount,
    double? usedAmount,
    Map<String, BudgetCategory>? categories,
  }) => Budget(
        id: id ?? this.id,
        participantId: participantId ?? this.participantId,
        totalAmount: totalAmount ?? this.totalAmount,
        usedAmount: usedAmount ?? this.usedAmount,
        categories: categories ?? this.categories,
      );
}
