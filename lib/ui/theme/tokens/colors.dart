import 'package:flutter/material.dart';

/// NDIS Connect Design System - Color Tokens
/// Following Google Material Design 3 with NDIS-specific adaptations
class NDISColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF1A73E8); // Google Blue
  static const Color primaryLight = Color(0xFF4285F4);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Secondary Colors
  static const Color secondary = Color(0xFF34A853); // Google Green
  static const Color secondaryLight = Color(0xFF0F9D58);
  static const Color secondaryDark = Color(0xFF137333);

  // Tertiary Colors
  static const Color tertiary = Color(0xFFFBBC04); // Google Yellow
  static const Color tertiaryLight = Color(0xFFFFD54F);
  static const Color tertiaryDark = Color(0xFFF57F17);

  // Semantic Colors
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF1A73E8);

  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  static const Color surfaceContainer = Color(0xFFF8F9FA);
  static const Color surfaceContainerHigh = Color(0xFFE8EAED);
  static const Color surfaceContainerHighest = Color(0xFFDADCE0);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);

  // Text Colors
  static const Color onSurface = Color(0xFF202124);
  static const Color onSurfaceVariant = Color(0xFF5F6368);
  static const Color onBackground = Color(0xFF202124);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFF000000);

  // Border Colors
  static const Color outline = Color(0xFFDADCE0);
  static const Color outlineVariant = Color(0xFFE8EAED);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);

  // High Contrast Colors (for accessibility)
  static const Color highContrastPrimary = Color(0xFF0D47A1);
  static const Color highContrastSecondary = Color(0xFF137333);
  static const Color highContrastError = Color(0xFFB71C1C);
  static const Color highContrastSurface = Color(0xFFFFFFFF);
  static const Color highContrastOnSurface = Color(0xFF000000);

  // Dark Theme Colors
  static const Color darkSurface = Color(0xFF202124);
  static const Color darkSurfaceVariant = Color(0xFF3C4043);
  static const Color darkSurfaceContainer = Color(0xFF2D2E30);
  static const Color darkBackground = Color(0xFF303134);
  static const Color darkOnSurface = Color(0xFFE8EAED);
  static const Color darkOnSurfaceVariant = Color(0xFF9AA0A6);
  static const Color darkOutline = Color(0xFF5F6368);

  // NDIS Specific Colors
  static const Color ndisBlue = primary;
  static const Color ndisTeal = Color(0xFF0F9D58);
  static const Color ndisGreen = secondary;
  static const Color ndisOrange = Color(0xFFFF9800);
  static const Color ndisPurple = Color(0xFF9C27B0);

  // Status Colors
  static const Color statusActive = success;
  static const Color statusPending = warning;
  static const Color statusInactive = neutral500;
  static const Color statusError = error;

  // Budget Category Colors
  static const Color budgetCore = primary;
  static const Color budgetCapacity = secondary;
  static const Color budgetCapital = tertiary;
  static const Color budgetSupport = ndisPurple;

  // Helper method to get color with opacity
  static Color withOpacity(final Color color, final double opacity) => color.withValues(alpha: opacity);

  // Helper method to get high contrast version
  static Color getHighContrast(final Color color, final bool isHighContrast) {
    if (!isHighContrast) return color;

    switch (color) {
      case primary:
        return highContrastPrimary;
      case secondary:
        return highContrastSecondary;
      case error:
        return highContrastError;
      case surface:
        return highContrastSurface;
      case onSurface:
        return highContrastOnSurface;
      default:
        return color;
    }
  }
}
