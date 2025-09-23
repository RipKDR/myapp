import 'package:flutter/material.dart';

/// NDIS Connect Design System - Typography Tokens
/// Following Google Material Design 3 typography scale
class NDSTypography {
  // Font families
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Roboto';
  static const String monospaceFont = 'RobotoMono';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display styles (large headlines)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: regular,
    letterSpacing: -0.25,
    height: 1.12,
    fontFamily: primaryFont,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.16,
    fontFamily: primaryFont,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.22,
    fontFamily: primaryFont,
  );

  // Headline styles (section headers)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.25,
    fontFamily: primaryFont,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.29,
    fontFamily: primaryFont,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.33,
    fontFamily: primaryFont,
  );

  // Title styles (card headers, list items)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.27,
    fontFamily: primaryFont,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.15,
    height: 1.50,
    fontFamily: primaryFont,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: primaryFont,
  );

  // Body styles (main content)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.50,
    fontFamily: primaryFont,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.43,
    fontFamily: primaryFont,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    height: 1.33,
    fontFamily: primaryFont,
  );

  // Label styles (buttons, chips, form labels)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: primaryFont,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.33,
    fontFamily: primaryFont,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.45,
    fontFamily: primaryFont,
  );

  // NDIS specific styles
  static const TextStyle budgetAmount = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: -0.5,
    height: 1.2,
    fontFamily: primaryFont,
  );

  static const TextStyle budgetCategory = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: primaryFont,
  );

  static const TextStyle statusLabel = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.33,
    fontFamily: primaryFont,
  );

  // Accessibility helpers
  static TextStyle withColor(final TextStyle style, final Color color) => style.copyWith(color: color);

  static TextStyle withWeight(final TextStyle style, final FontWeight weight) => style.copyWith(fontWeight: weight);

  static TextStyle withSize(final TextStyle style, final double size) => style.copyWith(fontSize: size);

  // High contrast versions
  static TextStyle getHighContrast(final TextStyle style, final bool isHighContrast) {
    if (!isHighContrast) return style;
    return style.copyWith(fontWeight: FontWeight.w600);
  }
}
