import 'package:flutter/material.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/radius.dart';
import '../theme/tokens/typography.dart';

/// Empty State Component
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.action,
    this.image,
  });

  final String title;
  final String description;
  final IconData? icon;
  final Widget? action;
  final Widget? image;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null) ...[
              image!,
              const SizedBox(height: NDISSpacing.xxl),
            ] else if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(NDISSpacing.xxl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(NDSRadius.lg),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: NDISSpacing.xxl),
            ],
            Text(
              title,
              style: NDSTypography.headlineSmall.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NDISSpacing.md),
            Text(
              description,
              style: NDSTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: NDISSpacing.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error State Component
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.description,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(NDISSpacing.xxl),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(NDSRadius.lg),
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: NDISSpacing.xxl),
            Text(
              title,
              style: NDSTypography.headlineSmall.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NDISSpacing.md),
            Text(
              description,
              style: NDSTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: NDISSpacing.xxl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading State Component
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Loading...',
    this.showProgress = true,
  });

  final String message;
  final bool showProgress;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showProgress)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            const SizedBox(height: NDISSpacing.xl),
            Text(
              message,
              style: NDSTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton Loading Component
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (final context, final child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(NDSRadius.sm),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(NDSRadius.sm),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surfaceContainerHigh,
                  theme.colorScheme.surfaceContainerHighest,
                ],
                stops: [
                  0.0,
                  _animation.value,
                  1.0,
                ],
              ),
            ),
          ),
        ),
    );
  }
}

/// Skeleton List Item
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
  });

  final bool showAvatar;
  final bool showSubtitle;

  @override
  Widget build(final BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NDISSpacing.lg,
        vertical: NDISSpacing.md,
      ),
      child: Row(
        children: [
          if (showAvatar) ...[
            const Skeleton(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            const SizedBox(width: NDISSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(width: double.infinity, height: 16),
                if (showSubtitle) ...[
                  const SizedBox(height: NDISSpacing.sm),
                  const Skeleton(width: 200, height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
}

/// Skeleton Card
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height = 120,
  });

  final double height;

  @override
  Widget build(final BuildContext context) => Container(
      margin: const EdgeInsets.all(NDISSpacing.sm),
      padding: const EdgeInsets.all(NDISSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(NDSRadius.card),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: double.infinity),
          SizedBox(height: NDISSpacing.md),
          Skeleton(width: 150, height: 16),
          SizedBox(height: NDISSpacing.lg),
          Skeleton(width: double.infinity, height: 8),
          SizedBox(height: NDISSpacing.sm),
          Skeleton(width: 100, height: 8),
        ],
      ),
    );
}
