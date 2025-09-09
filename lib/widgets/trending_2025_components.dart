import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/google_theme.dart';

/// Trending 2025 UI components based on latest design research
/// Incorporates dark mode, minimalism, microinteractions, VUI, and sustainable design
class Trending2025Components {
  /// Creates an energy-efficient dark mode toggle with smooth animations
  static Widget buildDarkModeToggle({
    required BuildContext context,
    required bool isDark,
    required ValueChanged<bool> onChanged,
    bool isAccessible = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!isDark);
        },
        child: Container(
          width: 64,
          height: 32,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? GoogleTheme.googleBlue.withOpacity(0.2)
                : Colors.grey.shade300,
            border: isAccessible
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.purple.shade900, Colors.blue.shade900]
                          : [Colors.orange.shade300, Colors.yellow.shade200],
                    ),
                  ),
                ),
              ),

              // Toggle indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark
                        ? Colors.purple.shade700
                        : Colors.orange.shade700,
                    size: 16,
                  ),
                ),
              ),

              // Accessibility label
              if (isAccessible)
                Positioned(
                  top: -24,
                  left: 0,
                  right: 0,
                  child: Text(
                    isDark ? 'Dark Mode On' : 'Light Mode On',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates minimalist functional cards with clean layouts and ample spacing
  static Widget buildMinimalistCard({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    double? elevation,
    EdgeInsets? padding,
    bool hasHoverEffect = true,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: elevation ?? 1,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        child: InkWell(
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          hoverColor:
              hasHoverEffect ? colorScheme.primary.withOpacity(0.05) : null,
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.08),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Creates delightful microinteractions for buttons and actions
  static Widget buildInteractiveButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isPrimary = true,
    bool hasRippleEffect = true,
    bool hasPulseAnimation = false,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onPressed();
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: hasRippleEffect
                ? (backgroundColor ?? GoogleTheme.googleBlue).withOpacity(0.2)
                : Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: backgroundColor ??
                    (isPrimary ? GoogleTheme.googleBlue : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: !isPrimary
                    ? Border.all(
                        color: backgroundColor ?? GoogleTheme.googleBlue,
                        width: 2,
                      )
                    : null,
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: (backgroundColor ?? GoogleTheme.googleBlue)
                              .withOpacity(0.3),
                          blurRadius: hasPulseAnimation ? 20 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: foregroundColor ??
                          (isPrimary
                              ? Colors.white
                              : backgroundColor ?? GoogleTheme.googleBlue),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: foregroundColor ??
                          (isPrimary
                              ? Colors.white
                              : backgroundColor ?? GoogleTheme.googleBlue),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Creates voice-enabled conversational interface component
  static Widget buildVoiceInterface({
    required BuildContext context,
    required bool isListening,
    required VoidCallback onVoiceToggle,
    String? transcribedText,
    bool isAccessible = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isListening
              ? GoogleTheme.googleRed.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.1),
          width: isListening ? 2 : 1,
        ),
        boxShadow: isListening
            ? [
                BoxShadow(
                  color: GoogleTheme.googleRed.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Voice button with animation
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  onVoiceToggle();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening
                        ? GoogleTheme.googleRed
                        : GoogleTheme.googleBlue,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening
                                ? GoogleTheme.googleRed
                                : GoogleTheme.googleBlue)
                            .withOpacity(0.3),
                        blurRadius: isListening ? 20 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isListening ? 1.1 : 1.0,
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Voice status and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isListening ? 'Listening...' : 'Tap to speak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isListening
                            ? GoogleTheme.googleRed
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (transcribedText != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transcribedText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Accessibility controls
          if (isAccessible) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Increase Speed'),
                  onDeleted: () {},
                  deleteIcon: const Icon(Icons.speed, size: 16),
                ),
                Chip(
                  label: const Text('Repeat'),
                  onDeleted: () {},
                  deleteIcon: const Icon(Icons.replay, size: 16),
                ),
                Chip(
                  label: const Text('Help'),
                  onDeleted: () {},
                  deleteIcon: const Icon(Icons.help_outline, size: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Creates sustainable and energy-efficient loading indicators
  static Widget buildEcoFriendlyLoader({
    required BuildContext context,
    double size = 40.0,
    Color? color,
    bool isMinimal = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final loaderColor = color ?? colorScheme.primary;

    if (isMinimal) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: loaderColor,
          backgroundColor: loaderColor.withOpacity(0.1),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            loaderColor.withOpacity(0.1),
            loaderColor,
            loaderColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.15),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  /// Creates inclusive and accessible information cards
  static Widget buildAccessibleInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    Color? accentColor,
    bool hasHighContrast = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = hasHighContrast ? Colors.white : colorScheme.surface;
    final textColor = hasHighContrast ? Colors.black : colorScheme.onSurface;

    return Semantics(
      label: '$title: $content',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasHighContrast
                  ? Colors.black
                  : colorScheme.outline.withOpacity(0.1),
              width: hasHighContrast ? 2 : 1,
            ),
            boxShadow: hasHighContrast
                ? [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        (accentColor ?? colorScheme.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: hasHighContrast
                        ? Border.all(color: Colors.black, width: 1)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: accentColor ?? colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: hasHighContrast ? 18 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasHighContrast
                            ? Colors.black87
                            : colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontSize: hasHighContrast ? 16 : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: hasHighContrast
                      ? Colors.black
                      : colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates modern glassmorphism effects with sustainability in mind
  static Widget buildSustainableGlass({
    required Widget child,
    double opacity = 0.1,
    double blur = 10.0,
    Color? backgroundColor,
    bool isEnergyEfficient = true,
  }) {
    if (isEnergyEfficient) {
      // Use lighter blur for energy efficiency
      return Container(
        decoration: BoxDecoration(
          color: (backgroundColor ?? Colors.white).withOpacity(opacity),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
