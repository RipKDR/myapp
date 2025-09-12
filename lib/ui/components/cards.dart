import 'package:flutter/material.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/radius.dart';

/// Base Card Component
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(NDISSpacing.cardPadding),
    this.margin = const EdgeInsets.all(NDISSpacing.sm),
    this.elevation,
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      child: Material(
        color: color ?? theme.colorScheme.surface,
        elevation: elevation ?? 1,
        shadowColor: theme.colorScheme.shadow,
        borderRadius: borderRadius ?? BorderRadius.circular(NDSRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(NDSRadius.card),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Budget Progress Card
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.title,
    required this.amount,
    required this.spent,
    required this.remaining,
    this.category,
    this.onTap,
    this.color,
  });

  final String title;
  final double amount;
  final double spent;
  final double remaining;
  final String? category;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final progress = amount > 0 ? spent / amount : 0.0;
    final isOverBudget = spent > amount;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NDISSpacing.sm,
                    vertical: NDISSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (color ?? theme.colorScheme.primary).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(NDSRadius.xs),
                  ),
                  child: Text(
                    category!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color ?? theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: NDISSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${amount.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Total Budget',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${spent.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOverBudget
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Spent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NDISSpacing.lg),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget
                  ? theme.colorScheme.error
                  : (color ?? theme.colorScheme.primary),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: NDISSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% used',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${remaining.toStringAsFixed(0)} remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOverBudget
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isOverBudget
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Appointment Card
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    this.provider,
    this.location,
    this.status = AppointmentStatus.scheduled,
    this.onTap,
  });

  final String title;
  final DateTime date;
  final String time;
  final String? provider;
  final String? location;
  final AppointmentStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: NDISSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: NDISSpacing.iconSm,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: NDISSpacing.sm),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: NDISSpacing.lg),
              Icon(
                Icons.access_time,
                size: NDISSpacing.iconSm,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: NDISSpacing.sm),
              Text(
                time,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (provider != null) ...[
            const SizedBox(height: NDISSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: NDISSpacing.iconSm,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: NDISSpacing.sm),
                Text(
                  provider!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (location != null) ...[
            const SizedBox(height: NDISSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: NDISSpacing.iconSm,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: NDISSpacing.sm),
                Expanded(
                  child: Text(
                    location!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Status Chip Widget
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case AppointmentStatus.scheduled:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        text = 'Scheduled';
        break;
      case AppointmentStatus.completed:
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        text = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NDISSpacing.sm,
        vertical: NDISSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NDSRadius.xs),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Appointment Status Enum
enum AppointmentStatus { scheduled, completed, cancelled }
