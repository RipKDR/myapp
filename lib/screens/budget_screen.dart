import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../widgets/budget_pie.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = _mockBudget();
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BudgetPieChart(data: overview),
          const SizedBox(height: 16),
          for (final b in overview.buckets) _BucketTile(bucket: b),
          const SizedBox(height: 12),
          Card(
            color: Colors.orange.withValues(alpha: 0.08),
            child: const ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text('Alert: Core at 80%'),
              subtitle: Text('Consider adjusting bookings and rates.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BucketTile extends StatelessWidget {
  final BudgetBucket bucket;
  const _BucketTile({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final pct = (bucket.percentUsed * 100).round();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(bucket.name, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('$pct% used'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: bucket.percentUsed,
              color: pct >= 80 ? Colors.orange : scheme.primary,
            ),
            const SizedBox(height: 8),
            Text('Allocated: \$${bucket.allocated.toStringAsFixed(0)}'),
            Text('Spent: \$${bucket.spent.toStringAsFixed(0)}  •  Remaining: \$${bucket.remaining.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload invoice'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.price_change),
                  label: const Text('Compare rates'),
                ),
              ],
            )
          ],
        ),
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
