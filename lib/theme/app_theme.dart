import 'package:flutter/material.dart';

class AppTheme {
  // Google-inspired color palette with NDIS integration
  static const Color googleBlue = Color(0xFF1A73E8);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC04);
  static const Color googleGrey = Color(0xFF5F6368);
  static const Color googleLightGrey = Color(0xFFF8F9FA);

  // NDIS Brand Colors adapted with 2025 healthcare psychology
  static const Color ndisBlue = Color(0xFF1A73E8); // Trust & reliability
  static const Color ndisLightBlue = Color(0xFF4285F4);
  static const Color ndisTeal = Color(0xFF0F9D58); // Healing & growth
  static const Color ndisGreen = Color(0xFF34A853); // Wellness & success
  static const Color ndisOrange = Color(0xFFFF9800); // Energy & motivation
  static const Color ndisPurple = Color(0xFF9C27B0); // Innovation & care

  // 2025 Healthcare-optimized colors for emotional well-being
  static const Color calmingBlue = Color(0xFF6BA6F5); // Reduces anxiety
  static const Color trustGreen = Color(0xFF4CAF50); // Builds confidence
  static const Color warmAccent = Color(0xFFFFB74D); // Friendly & approachable
  static const Color empathyPurple =
      Color(0xFFBA68C8); // Understanding & support
  static const Color hopeBlue = Color(0xFF81C784); // Optimism & progress
  static const Color safetyGrey = Color(0xFF78909C); // Stability & security

  // High contrast variants
  static const Color ndisBlueHC = Color(0xFF0D47A1);
  static const Color ndisTealHC = Color(0xFF00695C);
  static const Color ndisGreenHC = Color(0xFF1B5E20);

  // Google-style surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF202124);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF303134);

  static ThemeData lightTheme({final bool highContrast = false}) {
    final seedColor = highContrast ? ndisBlueHC : googleBlue;
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: seedColor,
        secondary: highContrast ? ndisTealHC : googleGreen,
        tertiary: highContrast ? ndisGreenHC : googleYellow,
        surface: highContrast ? Colors.white : surfaceLight,
        surfaceContainerHighest:
            highContrast ? Colors.grey[200] : googleLightGrey,
        outline: googleGrey.withValues(alpha: 0.2),
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto', // Google's primary font
    );

    return base.copyWith(
      textTheme: highContrast
          ? _contrastText(base.textTheme)
          : _enhancedText(base.textTheme),
      cardTheme: CardThemeData(
        color: base.colorScheme.surface,
        elevation: highContrast ? 2 : 1,
        shadowColor:
            highContrast ? Colors.black : Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12), // Google-style rounded corners
          side: highContrast
              ? BorderSide(color: Colors.grey[400]!)
              : BorderSide(color: googleGrey.withValues(alpha: 0.1)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: base.colorScheme.surfaceContainerHighest,
        selectedColor: base.colorScheme.primaryContainer,
        labelStyle: base.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: highContrast ? Colors.black : base.colorScheme.outline,
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: base.colorScheme.primary,
            width: highContrast ? 3 : 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: highContrast ? 2 : 1,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: base.colorScheme.surface,
        selectedItemColor: base.colorScheme.primary,
        unselectedItemColor: base.colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData darkTheme({final bool highContrast = false}) {
    final seedColor = highContrast ? ndisLightBlue : ndisBlue;
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: seedColor,
        secondary: highContrast ? ndisTeal : ndisTeal,
        tertiary: highContrast ? ndisGreen : ndisGreen,
        surface: highContrast ? Colors.black : const Color(0xFF121212),
        surfaceContainerHighest:
            highContrast ? Colors.grey[800] : Colors.grey[900],
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Inter',
    );

    return base.copyWith(
      textTheme: highContrast
          ? _contrastTextDark(base.textTheme)
          : _enhancedText(base.textTheme),
      cardTheme: CardThemeData(
        color: base.colorScheme.surface,
        elevation: highContrast ? 2 : 0,
        shadowColor: highContrast ? Colors.white : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highContrast
              ? BorderSide(color: Colors.grey[600]!)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: base.colorScheme.surfaceContainerHighest,
        selectedColor: base.colorScheme.primaryContainer,
        labelStyle: base.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: highContrast ? Colors.white : base.colorScheme.outline,
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: base.colorScheme.primary,
            width: highContrast ? 3 : 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: highContrast ? 2 : 1,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: base.colorScheme.surface,
        selectedItemColor: base.colorScheme.primary,
        unselectedItemColor: base.colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static TextTheme _enhancedText(final TextTheme base) => base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );

  static TextTheme _contrastText(final TextTheme base) => base
        .apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          decorationColor: Colors.black,
        )
        .copyWith(
          bodyLarge: base.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        );

  static TextTheme _contrastTextDark(final TextTheme base) => base
        .apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          decorationColor: Colors.white,
        )
        .copyWith(
          bodyLarge: base.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        );
}
