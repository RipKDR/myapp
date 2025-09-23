class BudgetBucket {

  const BudgetBucket({
    required this.name,
    required this.allocated,
    required this.spent,
  });
  final String name; // e.g., Core, Capacity, Capital
  final double allocated;
  final double spent;

  double get remaining => (allocated - spent).clamp(0, allocated);
  double get percentUsed =>
      allocated == 0 ? 0 : (spent / allocated).clamp(0, 1);
}

class BudgetOverview {
  const BudgetOverview(this.buckets);
  final List<BudgetBucket> buckets;

  double get totalAllocated => buckets.fold(0, (final s, final b) => s + b.allocated);
  double get totalSpent => buckets.fold(0, (final s, final b) => s + b.spent);
}

// New Budget models to satisfy tests
class BudgetCategory {

  const BudgetCategory({
    required this.name,
    required this.allocatedAmount,
    required this.usedAmount,
  })  : assert(allocatedAmount >= 0),
        assert(usedAmount >= 0);
  final String name;
  final double allocatedAmount;
  final double usedAmount;

  double get remainingAmount =>
      (allocatedAmount - usedAmount).clamp(0, allocatedAmount);
  double get usagePercentage =>
      allocatedAmount == 0 ? 0 : (usedAmount / allocatedAmount).clamp(0, 1);

  BudgetCategory copyWith({final double? allocatedAmount, final double? usedAmount}) =>
      BudgetCategory(
        name: name,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        usedAmount: usedAmount ?? this.usedAmount,
      );
}

class Budget {

  Budget({
    required this.id,
    required this.participantId,
    required this.totalAmount,
    this.usedAmount = 0,
    final Map<String, BudgetCategory>? categories,
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
  final String id;
  final String participantId;
  final double totalAmount;
  final double usedAmount;
  final Map<String, BudgetCategory> categories;

  double get remainingAmount =>
      (totalAmount - usedAmount).clamp(0, totalAmount);
  double get usagePercentage =>
      totalAmount == 0 ? 0 : (usedAmount / totalAmount).clamp(0, 1);
  bool get isNearLimit => usagePercentage >= 0.8 && !isOverLimit;
  bool get isOverLimit => usedAmount > totalAmount;

  Budget copyWith({
    final String? id,
    final String? participantId,
    final double? totalAmount,
    final double? usedAmount,
    final Map<String, BudgetCategory>? categories,
  }) =>
      Budget(
        id: id ?? this.id,
        participantId: participantId ?? this.participantId,
        totalAmount: totalAmount ?? this.totalAmount,
        usedAmount: usedAmount ?? this.usedAmount,
        categories: categories ?? this.categories,
      );
}

// NDIS-specific budget category with additional properties
class NDISBudgetCategory extends BudgetCategory {

  const NDISBudgetCategory({
    required super.name,
    required super.allocatedAmount,
    required super.usedAmount,
    required this.ndisCode,
    required this.description,
    this.isCore = false,
    this.isCapacity = false,
    this.isCapital = false,
  });
  final String ndisCode;
  final String description;
  final bool isCore;
  final bool isCapacity;
  final bool isCapital;

  double get progress => usagePercentage;
  bool get isOverBudget => usedAmount > allocatedAmount;

  @override
  NDISBudgetCategory copyWith({
    final double? allocatedAmount,
    final double? usedAmount,
    final String? ndisCode,
    final String? description,
    final bool? isCore,
    final bool? isCapacity,
    final bool? isCapital,
  }) =>
      NDISBudgetCategory(
        name: name,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        usedAmount: usedAmount ?? this.usedAmount,
        ndisCode: ndisCode ?? this.ndisCode,
        description: description ?? this.description,
        isCore: isCore ?? this.isCore,
        isCapacity: isCapacity ?? this.isCapacity,
        isCapital: isCapital ?? this.isCapital,
      );
}
