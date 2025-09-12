import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens/colors.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';
import 'tokens/radius.dart';
import 'tokens/motion.dart';

/// NDIS Connect App Theme
/// Modern, accessible theme using design system tokens
class NDISAppTheme {
  static ThemeData lightTheme({final bool highContrast = false}) {
    final colorScheme = ColorScheme.light(
      primary: NDISColors.getHighContrast(NDISColors.primary, highContrast),
      primaryContainer: NDISColors.primaryLight.withValues(alpha: 0.1),
      onPrimaryContainer: NDISColors.primary,
      secondary: NDISColors.getHighContrast(NDISColors.secondary, highContrast),
      onSecondary: NDISColors.onSecondary,
      secondaryContainer: NDISColors.secondaryLight.withValues(alpha: 0.1),
      onSecondaryContainer: NDISColors.secondary,
      tertiary: NDISColors.tertiary,
      onTertiary: NDISColors.onTertiary,
      tertiaryContainer: NDISColors.tertiaryLight.withValues(alpha: 0.1),
      onTertiaryContainer: NDISColors.tertiary,
      error: NDISColors.getHighContrast(NDISColors.error, highContrast),
      errorContainer: NDISColors.error.withValues(alpha: 0.1),
      onErrorContainer: NDISColors.error,
      surface: NDISColors.getHighContrast(NDISColors.surface, highContrast),
      onSurface: NDISColors.getHighContrast(NDISColors.onSurface, highContrast),
      surfaceContainerHighest: NDISColors.surfaceContainerHighest,
      onSurfaceVariant: NDISColors.onSurfaceVariant,
      outline: NDISColors.outline,
      outlineVariant: NDISColors.outlineVariant,
      shadow: NDISColors.shadow,
      surfaceTint: NDISColors.primary.withValues(alpha: 0.05),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: NDSTypography.primaryFont,
      textTheme: _buildTextTheme(colorScheme, highContrast),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: NDSTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
          fontWeight: NDSTypography.medium,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: NDISSpacing.iconMd,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: NDISSpacing.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleSpacing: NDISSpacing.lg,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: highContrast ? 2 : 1,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NDSRadius.card),
          side: BorderSide(
            color: highContrast ? NDISColors.outline : colorScheme.outline,
            width: highContrast ? 1 : 0.5,
          ),
        ),
        margin: const EdgeInsets.all(NDISSpacing.sm),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: highContrast ? 2 : 1,
          shadowColor: colorScheme.shadow,
          surfaceTintColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NDSRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: NDISSpacing.xl,
            vertical: NDISSpacing.md,
          ),
          minimumSize: const Size(0, NDISSpacing.minTouchTarget),
          textStyle: NDSTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NDSRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: NDISSpacing.xl,
            vertical: NDISSpacing.md,
          ),
          minimumSize: const Size(0, NDISSpacing.minTouchTarget),
          textStyle: NDSTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NDSRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: NDISSpacing.xl,
            vertical: NDISSpacing.md,
          ),
          minimumSize: const Size(0, NDISSpacing.minTouchTarget),
          textStyle: NDSTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NDSRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: NDISSpacing.lg,
            vertical: NDISSpacing.sm,
          ),
          minimumSize: const Size(0, NDISSpacing.minTouchTarget),
          textStyle: NDSTypography.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NDSRadius.input),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NDSRadius.input),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NDSRadius.input),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NDSRadius.input),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NDISSpacing.lg,
          vertical: NDISSpacing.lg,
        ),
        labelStyle: NDSTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: NDSTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        labelStyle: NDSTypography.labelMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: NDSTypography.labelMedium.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NDSRadius.chip),
        ),
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: NDISSpacing.md,
          vertical: NDISSpacing.sm,
        ),
      ),

      // FAB Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NDSRadius.fab),
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(NDSTypography.labelSmall),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 0.5,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: NDISSpacing.iconMd,
      ),

      // Switch Theme
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

      // Page Transitions
      pageTransitionsTheme: NDSMotion.pageTransitions,
    );
  }

  static ThemeData darkTheme({final bool highContrast = false}) {
    final colorScheme = ColorScheme.dark(
      primary: NDISColors.getHighContrast(
        NDISColors.primaryLight,
        highContrast,
      ),
      onPrimary: Colors.white,
      primaryContainer: NDISColors.primary.withValues(alpha: 0.2),
      onPrimaryContainer: NDISColors.primaryLight,
      secondary: NDISColors.getHighContrast(NDISColors.secondary, highContrast),
      onSecondary: Colors.white,
      secondaryContainer: NDISColors.secondary.withValues(alpha: 0.2),
      onSecondaryContainer: NDISColors.secondary,
      tertiary: NDISColors.tertiary,
      onTertiary: Colors.black,
      tertiaryContainer: NDISColors.tertiary.withValues(alpha: 0.2),
      onTertiaryContainer: NDISColors.tertiary,
      error: NDISColors.getHighContrast(NDISColors.error, highContrast),
      onError: Colors.white,
      errorContainer: NDISColors.error.withValues(alpha: 0.2),
      onErrorContainer: NDISColors.error,
      surface: NDISColors.getHighContrast(NDISColors.darkSurface, highContrast),
      onSurface: NDISColors.getHighContrast(
        NDISColors.darkOnSurface,
        highContrast,
      ),
      surfaceContainerHighest: NDISColors.darkSurfaceContainer,
      onSurfaceVariant: NDISColors.darkOnSurfaceVariant,
      outline: NDISColors.darkOutline,
      outlineVariant: NDISColors.darkOutline.withValues(alpha: 0.5),
      shadow: NDISColors.shadowDark,
      surfaceTint: NDISColors.primary.withValues(alpha: 0.1),
    );

    return lightTheme(highContrast: highContrast).copyWith(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: NDSTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
          fontWeight: NDSTypography.medium,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: NDISSpacing.iconMd,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: NDISSpacing.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleSpacing: NDISSpacing.lg,
      ),
    );
  }

  static TextTheme _buildTextTheme(final ColorScheme colorScheme, final bool highContrast) => TextTheme(
      displayLarge: NDSTypography.getHighContrast(
        NDSTypography.displayLarge,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      displayMedium: NDSTypography.getHighContrast(
        NDSTypography.displayMedium,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      displaySmall: NDSTypography.getHighContrast(
        NDSTypography.displaySmall,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      headlineLarge: NDSTypography.getHighContrast(
        NDSTypography.headlineLarge,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      headlineMedium: NDSTypography.getHighContrast(
        NDSTypography.headlineMedium,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      headlineSmall: NDSTypography.getHighContrast(
        NDSTypography.headlineSmall,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      titleLarge: NDSTypography.getHighContrast(
        NDSTypography.titleLarge,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      titleMedium: NDSTypography.getHighContrast(
        NDSTypography.titleMedium,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      titleSmall: NDSTypography.getHighContrast(
        NDSTypography.titleSmall,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      bodyLarge: NDSTypography.getHighContrast(
        NDSTypography.bodyLarge,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      bodyMedium: NDSTypography.getHighContrast(
        NDSTypography.bodyMedium,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      bodySmall: NDSTypography.getHighContrast(
        NDSTypography.bodySmall,
        highContrast,
      ).copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: NDSTypography.getHighContrast(
        NDSTypography.labelLarge,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      labelMedium: NDSTypography.getHighContrast(
        NDSTypography.labelMedium,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
      labelSmall: NDSTypography.getHighContrast(
        NDSTypography.labelSmall,
        highContrast,
      ).copyWith(color: colorScheme.onSurface),
    );
}
