import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/cards.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/empty_states.dart';

/// Budgets Screen
/// View and manage NDIS budget categories
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Budget Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ],
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBudgetList()),
        ],
      ),
    );

  Widget _buildFilterChips() {
    final filters = ['All', 'Core', 'Capacity', 'Capital'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (final context, final index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (final selected) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetList() {
    final budgets = _getFilteredBudgets();

    if (budgets.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet,
        title: 'No budgets found',
        description: 'No budgets match your current filter.',
        action: SecondaryButton(
          text: 'Clear Filter',
          onPressed: () => setState(() => _selectedFilter = 'All'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: budgets.length,
      itemBuilder: (final context, final index) {
        final budget = budgets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BudgetProgressCard(
            title: budget['title'],
            amount: budget['amount'],
            spent: budget['spent'],
            remaining: budget['remaining'],
            category: budget['category'],
            color: budget['color'],
            onTap: () => _showBudgetDetails(budget),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredBudgets() {
    final allBudgets = [
      {
        'title': 'Core Supports',
        'amount': 15000.0,
        'spent': 8500.0,
        'remaining': 6500.0,
        'category': 'Core',
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'title': 'Capacity Building',
        'amount': 8000.0,
        'spent': 3200.0,
        'remaining': 4800.0,
        'category': 'Capacity',
        'color': Theme.of(context).colorScheme.secondary,
      },
      {
        'title': 'Capital Supports',
        'amount': 5000.0,
        'spent': 0.0,
        'remaining': 5000.0,
        'category': 'Capital',
        'color': Theme.of(context).colorScheme.tertiary,
      },
      {
        'title': 'Assistance with Daily Life',
        'amount': 12000.0,
        'spent': 6800.0,
        'remaining': 5200.0,
        'category': 'Core',
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'title': 'Transport',
        'amount': 3000.0,
        'spent': 1200.0,
        'remaining': 1800.0,
        'category': 'Core',
        'color': Theme.of(context).colorScheme.primary,
      },
    ];

    if (_selectedFilter == 'All') {
      return allBudgets;
    }

    return allBudgets
        .where((final budget) => budget['category'] == _selectedFilter)
        .toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Filter Budgets'),
        content: const Text('Filter options will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBudgetDetails(final Map<String, dynamic> budget) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(budget['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Budget: \$${budget['amount'].toStringAsFixed(0)}'),
            Text('Spent: \$${budget['spent'].toStringAsFixed(0)}'),
            Text('Remaining: \$${budget['remaining'].toStringAsFixed(0)}'),
            Text('Category: ${budget['category']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
