import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/google_theme.dart';

/// Dynamic AI-powered color system that adapts to user mood, time, and context
/// Implements 2025 trend of intelligent, responsive color schemes
class DynamicAIColorSystem {
  /// Generates mood-responsive colors based on user interaction patterns
  static ColorScheme generateMoodBasedColors({
    required BuildContext context,
    required MoodState userMood,
    Brightness brightness = Brightness.light,
  }) {
    Color primaryColor;
    Color secondaryColor;
    Color tertiaryColor;

    switch (userMood) {
      case MoodState.energetic:
        primaryColor = const Color(0xFFFF6B35); // Vibrant orange
        secondaryColor = const Color(0xFFFFD23F); // Bright yellow
        tertiaryColor = const Color(0xFFE63946); // Energetic red
        break;

      case MoodState.calm:
        primaryColor = const Color(0xFF4ECDC4); // Soothing teal
        secondaryColor = const Color(0xFF95E1D3); // Soft mint
        tertiaryColor = const Color(0xFFB8E6B8); // Peaceful green
        break;

      case MoodState.focused:
        primaryColor = const Color(0xFF6C5CE7); // Deep purple
        secondaryColor = const Color(0xFFA29BFE); // Light purple
        tertiaryColor = const Color(0xFF74B9FF); // Focus blue
        break;

      case MoodState.anxious:
        primaryColor = const Color(0xFF81C784); // Calming green
        secondaryColor = const Color(0xFFFFE082); // Warm yellow
        tertiaryColor = const Color(0xFF90CAF9); // Soothing blue
        break;

      case MoodState.motivated:
        primaryColor = const Color(0xFF1E88E5); // Confident blue
        secondaryColor = const Color(0xFF43A047); // Growth green
        tertiaryColor = const Color(0xFFFF7043); // Action orange
        break;

      case MoodState.neutral:
      default:
        primaryColor = GoogleTheme.googleBlue;
        secondaryColor = GoogleTheme.googleGreen;
        tertiaryColor = GoogleTheme.ndisTeal;
        break;
    }

    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
    );
  }

  /// Creates time-based adaptive color palettes
  static ColorScheme generateTimeBasedColors({
    required DateTime currentTime,
    Brightness brightness = Brightness.light,
  }) {
    final hour = currentTime.hour;
    Color primaryColor;
    Color accentColor;

    if (hour >= 5 && hour < 10) {
      // Morning - Energizing colors
      primaryColor = const Color(0xFFFFB74D); // Morning sun
      accentColor = const Color(0xFFFF8A65); // Warm orange
    } else if (hour >= 10 && hour < 14) {
      // Mid-day - Productive colors
      primaryColor = const Color(0xFF42A5F5); // Sky blue
      accentColor = const Color(0xFF66BB6A); // Fresh green
    } else if (hour >= 14 && hour < 18) {
      // Afternoon - Balanced colors
      primaryColor = const Color(0xFF5C6BC0); // Balanced purple
      accentColor = const Color(0xFF26A69A); // Teal accent
    } else if (hour >= 18 && hour < 22) {
      // Evening - Relaxing colors
      primaryColor = const Color(0xFF8D6E63); // Warm brown
      accentColor = const Color(0xFFAB47BC); // Soft purple
    } else {
      // Night - Calming colors
      primaryColor = const Color(0xFF37474F); // Night blue
      accentColor = const Color(0xFF546E7A); // Muted blue-gray
    }

    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      secondary: accentColor,
    );
  }

  /// Generates context-aware theme colors based on app section
  static ColorScheme generateContextualColors({
    required AppContext context,
    Brightness brightness = Brightness.light,
    bool isAccessibilityMode = false,
  }) {
    Color primaryColor;
    Color secondaryColor;

    switch (context) {
      case AppContext.budget:
        primaryColor = isAccessibilityMode
            ? const Color(0xFF2E7D32) // High contrast green
            : const Color(0xFF4CAF50); // Money green
        secondaryColor = const Color(0xFFFF9800); // Warning orange
        break;

      case AppContext.health:
        primaryColor = isAccessibilityMode
            ? const Color(0xFF1565C0) // High contrast blue
            : const Color(0xFF2196F3); // Medical blue
        secondaryColor = const Color(0xFFE91E63); // Health pink
        break;

      case AppContext.appointments:
        primaryColor = isAccessibilityMode
            ? const Color(0xFF7B1FA2) // High contrast purple
            : const Color(0xFF9C27B0); // Calendar purple
        secondaryColor = const Color(0xFF00BCD4); // Appointment cyan
        break;

      case AppContext.social:
        primaryColor = isAccessibilityMode
            ? const Color(0xFFE65100) // High contrast orange
            : const Color(0xFFFF5722); // Social orange
        secondaryColor = const Color(0xFF607D8B); // Social gray
        break;

      case AppContext.settings:
        primaryColor = isAccessibilityMode
            ? const Color(0xFF424242) // High contrast gray
            : const Color(0xFF757575); // Settings gray
        secondaryColor = const Color(0xFF3F51B5); // Settings indigo
        break;

      case AppContext.dashboard:
      default:
        primaryColor = isAccessibilityMode
            ? const Color(0xFF0D47A1) // High contrast blue
            : GoogleTheme.googleBlue;
        secondaryColor = GoogleTheme.googleGreen;
        break;
    }

    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      secondary: secondaryColor,
    );
  }

  /// Creates animated color transitions between different states
  static AnimatedContainer buildColorTransitionContainer({
    required Widget child,
    required ColorScheme colorScheme,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
            colorScheme.tertiary.withOpacity(0.1),
          ],
        ),
      ),
      child: child,
    );
  }

  /// Generates harmonious color combinations using color theory
  static List<Color> generateHarmoniousColors({
    required Color baseColor,
    ColorHarmony harmony = ColorHarmony.complementary,
    int count = 5,
  }) {
    final hsl = HSLColor.fromColor(baseColor);
    final colors = <Color>[];

    switch (harmony) {
      case ColorHarmony.complementary:
        colors.add(baseColor);
        colors.add(HSLColor.fromAHSL(
          hsl.alpha,
          (hsl.hue + 180) % 360,
          hsl.saturation,
          hsl.lightness,
        ).toColor());
        break;

      case ColorHarmony.triadic:
        colors.add(baseColor);
        colors.add(HSLColor.fromAHSL(
          hsl.alpha,
          (hsl.hue + 120) % 360,
          hsl.saturation,
          hsl.lightness,
        ).toColor());
        colors.add(HSLColor.fromAHSL(
          hsl.alpha,
          (hsl.hue + 240) % 360,
          hsl.saturation,
          hsl.lightness,
        ).toColor());
        break;

      case ColorHarmony.analogous:
        for (int i = 0; i < count; i++) {
          colors.add(HSLColor.fromAHSL(
            hsl.alpha,
            (hsl.hue + (i * 30)) % 360,
            hsl.saturation,
            hsl.lightness,
          ).toColor());
        }
        break;

      case ColorHarmony.monochromatic:
        for (int i = 0; i < count; i++) {
          colors.add(HSLColor.fromAHSL(
            hsl.alpha,
            hsl.hue,
            hsl.saturation,
            (hsl.lightness + (i * 0.15)) % 1.0,
          ).toColor());
        }
        break;
    }

    return colors;
  }

  /// Creates a smart color picker that suggests optimal colors
  static Widget buildSmartColorPicker({
    required BuildContext context,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
    bool showHarmonyOptions = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Color Selection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 16),

          // Current color display
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (showHarmonyOptions) ...[
            Text(
              'Harmonious Colors',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),

            const SizedBox(height: 8),

            // Color harmony options
            Wrap(
              spacing: 8,
              children: ColorHarmony.values.map((harmony) {
                final colors = generateHarmoniousColors(
                  baseColor: currentColor,
                  harmony: harmony,
                  count: 3,
                );

                return GestureDetector(
                  onTap: () => onColorChanged(colors.first),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors.take(3).toList(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        harmony.name.substring(0, 3).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Enumeration for different mood states
enum MoodState {
  energetic,
  calm,
  focused,
  anxious,
  motivated,
  neutral,
}

/// Enumeration for different app contexts
enum AppContext {
  dashboard,
  budget,
  health,
  appointments,
  social,
  settings,
}

/// Enumeration for color harmony types
enum ColorHarmony {
  complementary,
  triadic,
  analogous,
  monochromatic,
}
