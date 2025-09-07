import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ndis_connect/main.dart';
import 'package:ndis_connect/controllers/auth_controller.dart';
import 'package:ndis_connect/controllers/settings_controller.dart';
import 'package:ndis_connect/controllers/gamification_controller.dart';

void main() {
  group('NDIS Connect Widget Tests', () {
    testWidgets('App launches and shows loading screen',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsController()),
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => GamificationController()),
          ],
          child: const NDISConnectApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify that the app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Settings controller initializes correctly',
        (WidgetTester tester) async {
      final settingsController = SettingsController();

      // Test initial state
      expect(settingsController.themeMode, ThemeMode.system);
      expect(settingsController.highContrast, false);
      expect(settingsController.textScale, 1.0);
      expect(settingsController.reduceMotion, false);
    });

    testWidgets('Auth controller initializes correctly',
        (WidgetTester tester) async {
      final authController = AuthController();

      // Test initial state
      expect(authController.isAuthenticated, false);
      expect(authController.currentUser, null);
      expect(authController.userRole, null);
    });

    testWidgets('Gamification controller initializes correctly',
        (WidgetTester tester) async {
      final gamificationController = GamificationController();

      // Test initial state
      expect(gamificationController.points, 0);
      expect(gamificationController.streakDays, 0);
      expect(gamificationController.badges, isEmpty);
    });

    testWidgets('Settings can be toggled', (WidgetTester tester) async {
      final settingsController = SettingsController();

      // Test theme mode change
      await settingsController.setThemeMode(ThemeMode.dark);
      expect(settingsController.themeMode, ThemeMode.dark);

      // Test high contrast toggle
      await settingsController.setHighContrast(true);
      expect(settingsController.highContrast, true);

      // Test text scale
      await settingsController.setTextScale(1.5);
      expect(settingsController.textScale, 1.5);

      // Test reduced motion
      await settingsController.setReduceMotion(true);
      expect(settingsController.reduceMotion, true);
    });

    testWidgets('Gamification points can be added',
        (WidgetTester tester) async {
      final gamificationController = GamificationController();

      // Test adding points
      await gamificationController.addPoints(10);
      expect(gamificationController.points, 10);

      // Test streak increment
      await gamificationController.incrementStreak();
      expect(gamificationController.streakDays, 1);
    });
  });
}
