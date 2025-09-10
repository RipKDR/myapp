import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Advanced glassmorphism effects for 2025+ design trends
/// Features multi-layer blur effects, dynamic transparency, and floating panels
class AdvancedGlassmorphism2025 {
  /// Creates an ultra-modern glass container with multiple blur layers
  static Widget buildUltraGlassContainer({
    required final Widget child,
    final double? width,
    final double? height,
    final EdgeInsets? padding,
    final BorderRadius? borderRadius,
    final Color? backgroundColor,
    final double blurIntensity = 20.0,
    final bool hasFloatingEffect = false,
    final List<Color>? gradientColors,
  }) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: hasFloatingEffect
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ??
                    [
                      backgroundColor?.withValues(alpha: 0.3) ??
                          Colors.white.withValues(alpha: 0.3),
                      backgroundColor?.withValues(alpha: 0.1) ??
                          Colors.white.withValues(alpha: 0.1),
                    ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
      ),
    );

  /// Creates a dynamic glass card that responds to interactions
  static Widget buildInteractiveGlassCard({
    required final BuildContext context,
    required final Widget child,
    final VoidCallback? onTap,
    final bool isPressed = false,
    final Color? accentColor,
    final double elevation = 1.0,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..scale(isPressed ? 0.98 : 1.0)
        ..rotateX(isPressed ? 0.02 : 0.0),
      child: GestureDetector(
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (accentColor ?? colorScheme.primary).withValues(alpha: 0.2),
                blurRadius: 30 * elevation,
                offset: Offset(0, 10 * elevation),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.1),
                      (accentColor ?? colorScheme.primary).withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a floating glass action button with dynamic blur
  static Widget buildFloatingGlassButton({
    required final IconData icon,
    required final VoidCallback onPressed,
    final Color? backgroundColor,
    final Color? iconColor,
    final double size = 56.0,
    final bool isPulsing = false,
  }) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (backgroundColor ?? GoogleTheme.googleBlue).withValues(alpha: 0.4),
              blurRadius: isPulsing ? 40 : 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    (backgroundColor ?? GoogleTheme.googleBlue)
                        .withValues(alpha: 0.6),
                    (backgroundColor ?? GoogleTheme.googleBlue)
                        .withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onPressed();
                  },
                  borderRadius: BorderRadius.circular(size / 2),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor ?? Colors.white,
                      size: size * 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  /// Creates a glass navigation bar with floating effect
  static Widget buildGlassNavigationBar({
    required final BuildContext context,
    required final List<BottomNavigationBarItem> items,
    required final int currentIndex,
    required final void Function(int) onTap,
    final Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (final index) {
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconTheme(
                          data: IconThemeData(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          child: items[index].icon,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].label ?? '',
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a glass modal overlay with advanced blur effects
  static Widget buildGlassModalOverlay({
    required final BuildContext context,
    required final Widget child,
    final VoidCallback? onDismiss,
    final double blurIntensity = 15.0,
  }) => Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop with blur
          GestureDetector(
            onTap: onDismiss,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurIntensity,
                sigmaY: blurIntensity,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Modal content
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 600,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  /// Creates animated glass ripple effects
  static Widget buildGlassRippleEffect({
    required final Widget child,
    final Color? rippleColor,
    final Duration duration = const Duration(milliseconds: 600),
  }) => AnimatedContainer(
      duration: duration,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple layers
          for (int i = 0; i < 3; i++)
            AnimatedContainer(
              duration:
                  Duration(milliseconds: duration.inMilliseconds + (i * 200)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      (rippleColor ?? Colors.blue).withValues(alpha: 0.3 - (i * 0.1)),
                  width: 2,
                ),
              ),
            ),

          // Main content
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
}
