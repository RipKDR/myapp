import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ndis_connect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NDIS Connect App Integration Tests', () {
    testWidgets('Complete user authentication flow', (
      final tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test 1: User Registration Flow
      await _testUserRegistration(tester);

      // Test 2: User Login Flow
      await _testUserLogin(tester);

      // Test 3: Dashboard Navigation
      await _testDashboardNavigation(tester);

      // Test 4: Appointment Booking Flow
      await _testAppointmentBooking(tester);

      // Test 5: Budget Tracking Flow
      await _testBudgetTracking(tester);

      // Test 6: Chat Assistant Flow
      await _testChatAssistant(tester);

      // Test 7: Settings and Profile Management
      await _testSettingsAndProfile(tester);

      // Test 8: Logout Flow
      await _testLogout(tester);
    });

    testWidgets('Offline functionality test', (final tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test offline capabilities
      await _testOfflineFunctionality(tester);
    });

    testWidgets('Accessibility features test', (final tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test accessibility features
      await _testAccessibilityFeatures(tester);
    });
  });
}

/// Test user registration flow
Future<void> _testUserRegistration(final WidgetTester tester) async {
  // Navigate to registration
  if (find.text('Create Account').evaluate().isNotEmpty) {
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
  }

  // Fill registration form
  await tester.enterText(find.byType(TextField).at(0), 'testuser@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'SecurePassword123!');
  await tester.enterText(find.byType(TextField).at(2), 'SecurePassword123!');

  // Submit registration
  await tester.tap(find.text('Sign Up'));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify registration success or handle existing user
  if (find.text('Account created successfully').evaluate().isNotEmpty) {
    expect(find.text('Account created successfully'), findsOneWidget);
  } else if (find.text('Email already exists').evaluate().isNotEmpty) {
    // User already exists, continue with login
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
  }
}

/// Test user login flow
Future<void> _testUserLogin(final WidgetTester tester) async {
  // Fill login form
  await tester.enterText(find.byType(TextField).at(0), 'testuser@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'SecurePassword123!');

  // Submit login
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify successful login
  expect(find.text('Welcome'), findsOneWidget);
}

/// Test dashboard navigation
Future<void> _testDashboardNavigation(final WidgetTester tester) async {
  // Navigate to different dashboard sections
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();
  expect(find.text('Appointments'), findsOneWidget);

  await tester.tap(find.text('Budget'));
  await tester.pumpAndSettle();
  expect(find.text('Budget Overview'), findsOneWidget);

  await tester.tap(find.find.text('Chat'));
  await tester.pumpAndSettle();
  expect(find.text('AI Assistant'), findsOneWidget);

  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
  expect(find.text('Settings'), findsOneWidget);
}

/// Test appointment booking flow
Future<void> _testAppointmentBooking(final WidgetTester tester) async {
  // Navigate to calendar
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();

  // Tap on a date to create appointment
  await tester.tap(find.byType(CalendarDatePicker).first);
  await tester.pumpAndSettle();

  // Fill appointment form
  await tester.enterText(find.byType(TextField).at(0), 'Physiotherapy Session');
  await tester.enterText(find.byType(TextField).at(1), 'Weekly physio session');

  // Select time
  await tester.tap(find.text('Select Time'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('10:00 AM'));
  await tester.pumpAndSettle();

  // Save appointment
  await tester.tap(find.text('Save Appointment'));
  await tester.pumpAndSettle();

  // Verify appointment created
  expect(find.text('Appointment created successfully'), findsOneWidget);
}

/// Test budget tracking flow
Future<void> _testBudgetTracking(final WidgetTester tester) async {
  // Navigate to budget screen
  await tester.tap(find.text('Budget'));
  await tester.pumpAndSettle();

  // Add budget entry
  await tester.tap(find.text('Add Entry'));
  await tester.pumpAndSettle();

  // Fill budget form
  await tester.enterText(find.byType(TextField).at(0), '100.00');
  await tester.enterText(find.byType(TextField).at(1), 'Physiotherapy');

  // Select category
  await tester.tap(find.text('Select Category'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Health Services'));
  await tester.pumpAndSettle();

  // Save budget entry
  await tester.tap(find.text('Save Entry'));
  await tester.pumpAndSettle();

  // Verify budget entry added
  expect(find.text('Budget entry added'), findsOneWidget);
}

/// Test chat assistant flow
Future<void> _testChatAssistant(final WidgetTester tester) async {
  // Navigate to chat
  await tester.tap(find.text('Chat'));
  await tester.pumpAndSettle();

  // Send a message
  await tester.enterText(
    find.byType(TextField),
    'How can I book an appointment?',
  );
  await tester.tap(find.text('Send'));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify AI response
  expect(find.text('How can I book an appointment?'), findsOneWidget);
  // AI response should appear
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Test settings and profile management
Future<void> _testSettingsAndProfile(final WidgetTester tester) async {
  // Navigate to profile/settings
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();

  // Test accessibility settings
  await tester.tap(find.text('Accessibility'));
  await tester.pumpAndSettle();

  // Toggle high contrast
  await tester.tap(find.byType(Switch).first);
  await tester.pumpAndSettle();

  // Adjust text scale
  await tester.tap(find.text('Text Size'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Large'));
  await tester.pumpAndSettle();

  // Go back to profile
  await tester.tap(find.text('Back'));
  await tester.pumpAndSettle();

  // Test profile editing
  await tester.tap(find.text('Edit Profile'));
  await tester.pumpAndSettle();

  // Update profile information
  await tester.enterText(find.byType(TextField).at(0), 'Updated Name');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  // Verify profile updated
  expect(find.text('Profile updated successfully'), findsOneWidget);
}

/// Test logout flow
Future<void> _testLogout(final WidgetTester tester) async {
  // Navigate to profile
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();

  // Tap logout
  await tester.tap(find.text('Logout'));
  await tester.pumpAndSettle();

  // Confirm logout
  await tester.tap(find.text('Yes'));
  await tester.pumpAndSettle();

  // Verify returned to login screen
  expect(find.text('Sign In'), findsOneWidget);
}

/// Test offline functionality
Future<void> _testOfflineFunctionality(final WidgetTester tester) async {
  // Simulate offline mode (this would require network mocking)
  // For now, test that app doesn't crash when network is unavailable

  // Navigate to different screens while "offline"
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Budget'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Chat'));
  await tester.pumpAndSettle();

  // Verify app still functions
  expect(find.text('Offline Mode'), findsOneWidget);
}

/// Test accessibility features
Future<void> _testAccessibilityFeatures(final WidgetTester tester) async {
  // Test screen reader support
  final semantics = tester.binding.pipelineOwner.semanticsOwner;
  expect(semantics, isNotNull);

  // Test high contrast mode
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Accessibility'));
  await tester.pumpAndSettle();

  await tester.tap(find.byType(Switch).first); // High contrast toggle
  await tester.pumpAndSettle();

  // Test text scaling
  await tester.tap(find.text('Text Size'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Extra Large'));
  await tester.pumpAndSettle();

  // Test reduced motion
  await tester.tap(find.byType(Switch).at(1)); // Reduced motion toggle
  await tester.pumpAndSettle();

  // Verify accessibility features are applied
  final mediaQuery = MediaQuery.of(tester.element(find.byType(MaterialApp)));
  expect(mediaQuery.textScaler.scale(1), greaterThan(1.0));
}
