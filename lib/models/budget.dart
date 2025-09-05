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

