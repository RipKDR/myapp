import 'package:flutter/material.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/radius.dart';
import '../theme/tokens/typography.dart';

/// Primary Button - Main call-to-action
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(size),
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NDSRadius.button),
          ),
          padding: _getPadding(size),
          minimumSize: Size(0, _getHeight(size)),
        ),
        child: isLoading
            ? SizedBox(
                width: _getIconSize(size),
                height: _getIconSize(size),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize(size)),
                    const SizedBox(width: NDISSpacing.sm),
                  ],
                  Text(
                    text,
                    style: NDSTypography.labelLarge.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: _getFontSize(size),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return NDISSpacing.minTouchTarget;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.md,
          vertical: NDISSpacing.sm,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.xl,
          vertical: NDISSpacing.md,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.xxl,
          vertical: NDISSpacing.lg,
        );
    }
  }

  double _getIconSize(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return NDISSpacing.iconSm;
      case ButtonSize.medium:
        return NDISSpacing.iconMd;
      case ButtonSize.large:
        return NDISSpacing.iconLg;
    }
  }

  double _getFontSize(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }
}

/// Secondary Button - Secondary actions
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(size),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NDSRadius.button),
          ),
          padding: _getPadding(size),
          minimumSize: Size(0, _getHeight(size)),
        ),
        child: isLoading
            ? SizedBox(
                width: _getIconSize(size),
                height: _getIconSize(size),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize(size)),
                    const SizedBox(width: NDISSpacing.sm),
                  ],
                  Text(
                    text,
                    style: NDSTypography.labelLarge.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: _getFontSize(size),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return NDISSpacing.minTouchTarget;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.md,
          vertical: NDISSpacing.sm,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.xl,
          vertical: NDISSpacing.md,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.xxl,
          vertical: NDISSpacing.lg,
        );
    }
  }

  double _getIconSize(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return NDISSpacing.iconSm;
      case ButtonSize.medium:
        return NDISSpacing.iconMd;
      case ButtonSize.large:
        return NDISSpacing.iconLg;
    }
  }

  double _getFontSize(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }
}

/// App Text Button - Tertiary actions
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonSize size;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _getHeight(size),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(NDSRadius.button),
          child: Padding(
            padding: _getPadding(size),
            child: isLoading
                ? SizedBox(
                    width: _getIconSize(size),
                    height: _getIconSize(size),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: _getIconSize(size)),
                        const SizedBox(width: NDISSpacing.sm),
                      ],
                      Text(
                        text,
                        style: NDSTypography.labelLarge.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: _getFontSize(size),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  double _getHeight(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return NDISSpacing.minTouchTarget;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.md,
          vertical: NDISSpacing.sm,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.lg,
          vertical: NDISSpacing.sm,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: NDISSpacing.xl,
          vertical: NDISSpacing.md,
        );
    }
  }

  double _getIconSize(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return NDISSpacing.iconSm;
      case ButtonSize.medium:
        return NDISSpacing.iconMd;
      case ButtonSize.large:
        return NDISSpacing.iconLg;
    }
  }

  double _getFontSize(final ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }
}

/// Button Size Enum
enum ButtonSize { small, medium, large }
