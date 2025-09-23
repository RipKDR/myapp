import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ndis_connect/controllers/auth_controller.dart';
import 'package:ndis_connect/services/auth_service.dart';
import 'package:ndis_connect/services/error_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthService, ErrorService, User])
void main() {
  group('AuthController Tests', () {
    late AuthController authController;
    late MockAuthService mockAuthService;
    late MockErrorService mockErrorService;
    late MockUser mockUser;

    setUp(() {
      mockAuthService = MockAuthService();
      mockErrorService = MockErrorService();
      mockUser = MockUser();
      
      authController = AuthController();
      // Inject mock services (would need dependency injection setup)
    });

    group('Authentication State', () {
      test('should initialize with unauthenticated state', () {
        expect(authController.isAuthenticated, false);
        expect(authController.currentUser, null);
        expect(authController.isLoading, false);
      });

      test('should update state when user signs in', () async {
        // Arrange
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.displayName).thenReturn('Test User');
        when(mockAuthService.signInWithEmailAndPassword('test@example.com', 'password'))
            .thenAnswer((_) async => mockUser);

        // Act
        await authController.signInWithEmailAndPassword('test@example.com', 'password');

        // Assert
        expect(authController.isAuthenticated, true);
        expect(authController.currentUser, isNotNull);
        expect(authController.isLoading, false);
      });

      test('should handle sign in errors gracefully', () async {
        // Arrange
        when(mockAuthService.signInWithEmailAndPassword('invalid@example.com', 'wrong'))
            .thenThrow(Exception('Invalid credentials'));

        // Act
        await authController.signInWithEmailAndPassword('invalid@example.com', 'wrong');

        // Assert
        expect(authController.isAuthenticated, false);
        expect(authController.currentUser, null);
        expect(authController.errorMessage, isNotNull);
      });
    });

    group('User Registration', () {
      test('should register new user successfully', () async {
        // Arrange
        when(mockUser.uid).thenReturn('new-user-uid');
        when(mockUser.email).thenReturn('newuser@example.com');
        when(mockAuthService.createUserWithEmailAndPassword('newuser@example.com', 'password'))
            .thenAnswer((_) async => mockUser);

        // Act
        await authController.createUserWithEmailAndPassword('newuser@example.com', 'password');

        // Assert
        expect(authController.isAuthenticated, true);
        expect(authController.currentUser?.email, 'newuser@example.com');
      });

      test('should validate email format during registration', () async {
        // Act & Assert
        expect(
          () => authController.createUserWithEmailAndPassword('invalid-email', 'password'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate password strength during registration', () async {
        // Act & Assert
        expect(
          () => authController.createUserWithEmailAndPassword('test@example.com', '123'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Password Reset', () {
      test('should send password reset email successfully', () async {
        // Arrange
        when(mockAuthService.sendPasswordResetEmail('test@example.com'))
            .thenAnswer((_) async => true);

        // Act
        final result = await authController.sendPasswordResetEmail('test@example.com');

        // Assert
        expect(result, true);
        verify(mockAuthService.sendPasswordResetEmail('test@example.com')).called(1);
      });

      test('should handle password reset errors', () async {
        // Arrange
        when(mockAuthService.sendPasswordResetEmail('nonexistent@example.com'))
            .thenThrow(Exception('User not found'));

        // Act
        final result = await authController.sendPasswordResetEmail('nonexistent@example.com');

        // Assert
        expect(result, false);
        expect(authController.errorMessage, isNotNull);
      });
    });

    group('Sign Out', () {
      test('should sign out user successfully', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async => true);

        // Act
        await authController.signOut();

        // Assert
        expect(authController.isAuthenticated, false);
        expect(authController.currentUser, null);
        verify(mockAuthService.signOut()).called(1);
      });
    });

    group('User Profile Management', () {
      test('should update user profile successfully', () async {
        // Arrange
        when(mockUser.uid).thenReturn('test-uid');
        when(mockAuthService.updateUserProfile({
          'displayName': 'Updated Name',
          'photoURL': 'https://example.com/photo.jpg'
        })).thenAnswer((_) async => true);

        // Act
        final result = await authController.updateUserProfile({
          'displayName': 'Updated Name',
          'photoURL': 'https://example.com/photo.jpg'
        });

        // Assert
        expect(result, true);
        verify(mockAuthService.updateUserProfile(any)).called(1);
      });
    });

    group('Loading States', () {
      test('should set loading state during authentication operations', () async {
        // Arrange
        when(mockAuthService.signInWithEmailAndPassword('test@example.com', 'password'))
            .thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(const Duration(milliseconds: 100));
          return mockUser;
        });

        // Act
        final future = authController.signInWithEmailAndPassword('test@example.com', 'password');
        
        // Assert loading state
        expect(authController.isLoading, true);
        
        await future;
        
        // Assert loading state cleared
        expect(authController.isLoading, false);
      });
    });

    group('Error Handling', () {
      test('should clear error messages on successful operations', () async {
        // Arrange
        authController.errorMessage = 'Previous error';
        when(mockAuthService.signInWithEmailAndPassword('test@example.com', 'password'))
            .thenAnswer((_) async => mockUser);

        // Act
        await authController.signInWithEmailAndPassword('test@example.com', 'password');

        // Assert
        expect(authController.errorMessage, null);
      });

      test('should preserve error messages on failed operations', () async {
        // Arrange
        when(mockAuthService.signInWithEmailAndPassword('test@example.com', 'wrong'))
            .thenThrow(Exception('Invalid password'));

        // Act
        await authController.signInWithEmailAndPassword('test@example.com', 'wrong');

        // Assert
        expect(authController.errorMessage, isNotNull);
        expect(authController.errorMessage, contains('Invalid password'));
      });
    });
  });
}
