import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme({bool highContrast = false}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      textTheme: highContrast ? _contrastText(base.textTheme) : base.textTheme,
      cardTheme: CardTheme(color: base.colorScheme.surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      chipTheme: base.chipTheme.copyWith(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }

  static ThemeData darkTheme({bool highContrast = false}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      textTheme: highContrast ? _contrastText(base.textTheme) : base.textTheme,
      cardTheme: CardTheme(color: base.colorScheme.surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      chipTheme: base.chipTheme.copyWith(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }

  static TextTheme _contrastText(TextTheme base) {
    return base.apply(
      fontWeightDelta: 2,
      bodyColor: Colors.black,
      displayColor: Colors.black,
      decorationColor: Colors.black,
    );
  }
}
