import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Google Material Design 3 inspired theme with NDIS integration
/// Following Google's design principles: Clean, accessible, and intuitive
class GoogleTheme {
  // Google Material Design color palette
  static const Color googleBlue = Color(0xFF1A73E8);
  static const Color googleBlueLight = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleGreenLight = Color(0xFF0F9D58);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC04);
  static const Color googleGrey = Color(0xFF5F6368);
  static const Color googleGreyLight = Color(0xFF9AA0A6);

  // Surface colors following Google's approach
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF202124);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF303134);
  static const Color surfaceContainer = Color(0xFFF1F3F4);
  static const Color surfaceContainerDark = Color(0xFF3C4043);

  // NDIS colors adapted to Google style
  static const Color ndisBlue = googleBlue;
  static const Color ndisTeal = googleGreenLight;
  static const Color ndisGreen = googleGreen;
  static const Color ndisOrange = Color(0xFFFF9800);
  static const Color ndisPurple = Color(0xFF9C27B0);

  static ThemeData lightTheme({final bool highContrast = false}) {
    final colorScheme = ColorScheme.light(
      primary: highContrast ? const Color(0xFF0D47A1) : googleBlue,
      primaryContainer: googleBlue.withValues(alpha: 0.1),
      onPrimaryContainer: googleBlue,
      secondary: googleGreen,
      onSecondary: Colors.white,
      secondaryContainer: googleGreen.withValues(alpha: 0.1),
      onSecondaryContainer: googleGreen,
      tertiary: googleYellow,
      onTertiary: Colors.black,
      tertiaryContainer: googleYellow.withValues(alpha: 0.1),
      onTertiaryContainer: googleYellow.withValues(alpha: 0.8),
      error: googleRed,
      errorContainer: googleRed.withValues(alpha: 0.1),
      onErrorContainer: googleRed,
      surface: highContrast ? Colors.white : surfaceLight,
      onSurface: highContrast ? Colors.black : const Color(0xFF202124),
      surfaceContainerHighest:
          highContrast ? Colors.grey[100] : surfaceContainer,
      outline: googleGrey.withValues(alpha: 0.2),
      outlineVariant: googleGrey.withValues(alpha: 0.1),
      shadow: Colors.black.withValues(alpha: 0.1),
      surfaceTint: googleBlue.withValues(alpha: 0.05),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Google uses Roboto as primary font
      fontFamily: 'Roboto',

      // Text theme following Google's typography
      textTheme: _buildTextTheme(colorScheme, highContrast),

      // App bar theme - clean and minimal like Google
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card theme - Google's elevated cards
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: highContrast ? 2 : 1,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: highContrast ? googleGrey : colorScheme.outline,
            width: highContrast ? 1 : 0.5,
          ),
        ),
        margin: const EdgeInsets.all(4),
      ),

      // Button themes - Google's Material You buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: highContrast ? 2 : 1,
          shadowColor: colorScheme.shadow,
          surfaceTintColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Google's pill buttons
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Input decoration - Google's clean input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
      ),

      // Chip theme - Google's modern chips
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // FAB theme - Google's floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Navigation theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 0.5,
        space: 1,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((final states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((final states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }

  static ThemeData darkTheme({final bool highContrast = false}) {
    final colorScheme = ColorScheme.dark(
      primary: highContrast ? googleBlueLight : googleBlue,
      onPrimary: Colors.white,
      primaryContainer: googleBlue.withValues(alpha: 0.2),
      onPrimaryContainer: googleBlueLight,
      secondary: googleGreen,
      secondaryContainer: googleGreen.withValues(alpha: 0.2),
      onSecondaryContainer: googleGreen,
      tertiary: googleYellow,
      onTertiary: Colors.black,
      tertiaryContainer: googleYellow.withValues(alpha: 0.2),
      onTertiaryContainer: googleYellow,
      error: googleRed,
      onError: Colors.white,
      errorContainer: googleRed.withValues(alpha: 0.2),
      onErrorContainer: googleRed,
      surface: highContrast ? Colors.black : surfaceDark,
      onSurface: highContrast ? Colors.white : Colors.white,
      surfaceContainerHighest:
          highContrast ? Colors.grey[800] : surfaceContainerDark,
      outline: googleGreyLight.withValues(alpha: 0.3),
      outlineVariant: googleGreyLight.withValues(alpha: 0.2),
      shadow: Colors.black.withValues(alpha: 0.3),
      surfaceTint: googleBlue.withValues(alpha: 0.1),
    );

    return lightTheme(highContrast: highContrast).copyWith(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  static TextTheme _buildTextTheme(final ColorScheme colorScheme, final bool highContrast) => TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurfaceVariant,
        fontFamily: 'Roboto',
        height: 1.3,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
    );
}
