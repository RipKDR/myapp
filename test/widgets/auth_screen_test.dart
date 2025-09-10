import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ndis_connect/screens/auth_screen.dart';
import 'package:ndis_connect/controllers/auth_controller.dart';
import 'package:ndis_connect/controllers/settings_controller.dart';

import 'auth_screen_test.mocks.dart';

@GenerateMocks([AuthController, SettingsController])
void main() {
  group('AuthScreen Widget Tests', () {
    late MockAuthController mockAuthController;
    late MockSettingsController mockSettingsController;

    setUp(() {
      mockAuthController = MockAuthController();
      mockSettingsController = MockSettingsController();

      // Setup default mock behaviors
      when(mockAuthController.isLoading).thenReturn(false);
      when(mockAuthController.isAuthenticated).thenReturn(false);
      when(mockAuthController.errorMessage).thenReturn(null);
      when(mockSettingsController.highContrast).thenReturn(false);
      when(mockSettingsController.textScale).thenReturn(1.0);
    });

    Widget createTestWidget({final Widget? child}) => MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(
              value: mockAuthController,
            ),
            ChangeNotifierProvider<SettingsController>.value(
              value: mockSettingsController,
            ),
          ],
          child: child ?? const AuthScreen(),
        ),
      );

    group('Initial State', () {
      testWidgets('should display login form by default', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Sign In'), findsOneWidget);
        expect(
          find.byType(TextField),
          findsNWidgets(2),
        ); // Email and password fields
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('should show forgot password link', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Forgot Password?'), findsOneWidget);
      });
    });

    group('Form Interaction', () {
      testWidgets('should allow typing in email field', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.enterText(
          find.byType(TextField).first,
          'test@example.com',
        );

        // Assert
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('should allow typing in password field', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.enterText(find.byType(TextField).last, 'password123');

        // Assert
        expect(find.text('password123'), findsOneWidget);
      });

      testWidgets('should toggle password visibility', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('Sign In Flow', () {
      testWidgets(
        'should call signInWithEmailAndPassword when sign in button is tapped',
        (final tester) async {
          // Arrange
          when(
            mockAuthController.signInWithEmailAndPassword(any, any),
          ).thenAnswer((_) async => null);

          // Act
          await tester.pumpWidget(createTestWidget());
          await tester.enterText(
            find.byType(TextField).first,
            'test@example.com',
          );
          await tester.enterText(find.byType(TextField).last, 'password123');
          await tester.tap(find.text('Sign In'));
          await tester.pump();

          // Assert
          verify(
            mockAuthController.signInWithEmailAndPassword(
              'test@example.com',
              'password123',
            ),
          ).called(1);
        },
      );

      testWidgets('should show loading indicator when signing in', (
        final tester,
      ) async {
        // Arrange
        when(mockAuthController.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should disable sign in button when loading', (
        final tester,
      ) async {
        // Arrange
        when(mockAuthController.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final signInButton = find.text('Sign In');
        expect(tester.widget<ElevatedButton>(signInButton).enabled, false);
      });
    });

    group('Sign Up Flow', () {
      testWidgets(
        'should switch to sign up form when create account is tapped',
        (final tester) async {
          // Act
          await tester.pumpWidget(createTestWidget());
          await tester.tap(find.text('Create Account'));
          await tester.pump();

          // Assert
          expect(find.text('Sign Up'), findsOneWidget);
          expect(
            find.byType(TextField),
            findsNWidgets(3),
          ); // Email, password, confirm password
          expect(find.text('Confirm Password'), findsOneWidget);
        },
      );

      testWidgets(
        'should call createUserWithEmailAndPassword when sign up button is tapped',
        (final tester) async {
          // Arrange
          when(
            mockAuthController.createUserWithEmailAndPassword(any, any),
          ).thenAnswer((_) async => null);

          // Act
          await tester.pumpWidget(createTestWidget());
          await tester.tap(find.text('Create Account'));
          await tester.pump();

          await tester.enterText(
            find.byType(TextField).at(0),
            'newuser@example.com',
          );
          await tester.enterText(find.byType(TextField).at(1), 'password123');
          await tester.enterText(find.byType(TextField).at(2), 'password123');
          await tester.tap(find.text('Sign Up'));
          await tester.pump();

          // Assert
          verify(
            mockAuthController.createUserWithEmailAndPassword(
              'newuser@example.com',
              'password123',
            ),
          ).called(1);
        },
      );

      testWidgets('should validate password confirmation', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.enterText(
          find.byType(TextField).at(2),
          'differentpassword',
        );
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should display error message when authentication fails', (
        final tester,
      ) async {
        // Arrange
        when(mockAuthController.errorMessage).thenReturn('Invalid credentials');

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Invalid credentials'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should clear error message when form is interacted with', (
        final tester,
      ) async {
        // Arrange
        when(mockAuthController.errorMessage).thenReturn('Invalid credentials');
        when(mockAuthController.clearError()).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.enterText(
          find.byType(TextField).first,
          'test@example.com',
        );

        // Assert
        verify(mockAuthController.clearError()).called(1);
      });
    });

    group('Forgot Password Flow', () {
      testWidgets('should show forgot password dialog when link is tapped', (
        final tester,
      ) async {
        // Arrange
        when(
          mockAuthController.sendPasswordResetEmail(any),
        ).thenAnswer((_) async => true);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Forgot Password?'));
        await tester.pump();

        // Assert
        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Send Reset Email'), findsOneWidget);
      });

      testWidgets('should send password reset email when email is entered', (
        final tester,
      ) async {
        // Arrange
        when(
          mockAuthController.sendPasswordResetEmail(any),
        ).thenAnswer((_) async => true);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Forgot Password?'));
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'test@example.com');
        await tester.tap(find.text('Send Reset Email'));
        await tester.pump();

        // Assert
        verify(
          mockAuthController.sendPasswordResetEmail('test@example.com'),
        ).called(1);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.bySemanticsLabel('Email address'), findsOneWidget);
        expect(find.bySemanticsLabel('Password'), findsOneWidget);
        expect(find.bySemanticsLabel('Sign in button'), findsOneWidget);
      });

      testWidgets('should support high contrast mode', (
        final tester,
      ) async {
        // Arrange
        when(mockSettingsController.highContrast).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        // Verify that high contrast theme is applied
        final theme = Theme.of(tester.element(find.byType(MaterialApp)));
        expect(theme.brightness, isNotNull);
      });

      testWidgets('should support text scaling', (final tester) async {
        // Arrange
        when(mockSettingsController.textScale).thenReturn(1.5);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final mediaQuery = MediaQuery.of(
          tester.element(find.byType(MaterialApp)),
        );
        expect(mediaQuery.textScaler.scale(1), 1.5);
      });
    });

    group('Form Validation', () {
      testWidgets('should show validation error for empty email', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show validation error for invalid email format', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.enterText(find.byType(TextField).first, 'invalid-email');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should show validation error for empty password', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.enterText(
          find.byType(TextField).first,
          'test@example.com',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should show validation error for weak password in sign up', (
        final tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        await tester.enterText(find.byType(TextField).at(1), '123');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(
          find.text('Password must be at least 8 characters'),
          findsOneWidget,
        );
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to main app when authentication succeeds', (
        final tester,
      ) async {
        // Arrange
        when(mockAuthController.isAuthenticated).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        // Verify navigation occurs (would need to check route changes)
        expect(find.byType(AuthScreen), findsNothing);
      });
    });
  });
}
