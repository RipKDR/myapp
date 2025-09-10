import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Neo-brutalism design components for cutting-edge 2025+ visual appeal
/// Features bold, striking elements with high contrast and geometric shapes
class NeoBrutalismComponents {
  /// Creates a bold, striking header with neo-brutalism styling
  static Widget buildStrikingHeader({
    required final BuildContext context,
    required final String title,
    required final String subtitle,
    final Color? backgroundColor,
    final Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Bold background shape
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: backgroundColor ?? GoogleTheme.googleBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(8, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
          ),

          // Geometric accent shapes
          Positioned(
            top: 10,
            right: 20,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.yellow,
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        const Shadow(
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trailing widget
          if (trailing != null)
            Positioned(
              top: 20,
              right: 20,
              child: trailing,
            ),
        ],
      ),
    );
  }

  /// Creates a brutalist-style action button with sharp edges and bold colors
  static Widget buildBrutalistButton({
    required final VoidCallback onPressed,
    required final String label,
    required final Color color,
    final IconData? icon,
    final bool isSecondary = false,
  }) => GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.white : color,
          border: Border.all(
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSecondary ? Colors.black : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isSecondary ? Colors.black : Colors.white,
                letterSpacing: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

  /// Creates a brutalist-style metric card with bold geometric design
  static Widget buildBrutalistMetricCard({
    required final BuildContext context,
    required final String title,
    required final String value,
    required final String unit,
    required final IconData icon,
    required final Color accentColor,
    final VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.mediumImpact();
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 3),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              offset: const Offset(8, 8),
            ),
            const BoxShadow(
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    border: Border.all(width: 2),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a brutalist-style navigation pill
  static Widget buildBrutalistNavPill({
    required final String label,
    required final bool isSelected,
    required final VoidCallback onTap,
    required final Color accentColor,
  }) => GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          border: Border.all(
            width: 2,
          ),
          borderRadius: BorderRadius.circular(0), // Sharp corners
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    offset: Offset(4, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.black,
            letterSpacing: 1,
            fontSize: 12,
          ),
        ),
      ),
    );

  /// Creates a brutalist-style alert/notification banner
  static Widget buildBrutalistAlert({
    required final String message,
    required final IconData icon,
    required final Color backgroundColor,
    final VoidCallback? onDismiss,
  }) => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(width: 3),
        boxShadow: const [
          BoxShadow(
            offset: Offset(6, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.8,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
}
