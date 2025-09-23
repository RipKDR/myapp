import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ndis_connect/services/auth_service.dart';
import 'package:ndis_connect/services/error_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential, AuthCredential])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      authService = AuthService();
      // Inject mock Firebase Auth (would need dependency injection setup)
    });

    group('Email/Password Authentication', () {
      test('should sign in with valid credentials', () async {
        // Arrange
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.displayName).thenReturn('Test User');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, isNotNull);
        expect(result.uid, 'test-uid');
        expect(result.email, 'test@example.com');
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('should create user with email and password', () async {
        // Arrange
        when(mockUser.uid).thenReturn('new-user-uid');
        when(mockUser.email).thenReturn('newuser@example.com');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'newuser@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.createUserWithEmailAndPassword(
          'newuser@example.com',
          'password123',
        );

        // Assert
        expect(result, isNotNull);
        expect(result.uid, 'new-user-uid');
        expect(result.email, 'newuser@example.com');
        verify(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'newuser@example.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('should handle invalid credentials error', () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'invalid@example.com',
            password: 'wrongpassword',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this email',
          ),
        );

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            'invalid@example.com',
            'wrongpassword',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should handle weak password error', () async {
        // Arrange
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: '123',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'weak-password',
            message: 'Password is too weak',
          ),
        );

        // Act & Assert
        expect(
          () => authService.createUserWithEmailAndPassword(
            'test@example.com',
            '123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('Password Reset', () {
      test('should send password reset email successfully', () async {
        // Arrange
        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authService.sendPasswordResetEmail(
          'test@example.com',
        );

        // Assert
        expect(result, true);
        verify(
          mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'),
        ).called(1);
      });

      test('should handle invalid email for password reset', () async {
        // Arrange
        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: 'invalid-email'),
        ).thenThrow(
          FirebaseAuthException(
            code: 'invalid-email',
            message: 'Invalid email address',
          ),
        );

        // Act
        final result = await authService.sendPasswordResetEmail(
          'invalid-email',
        );

        // Assert
        expect(result, false);
      });
    });

    group('User Profile Management', () {
      test('should update user profile successfully', () async {
        // Arrange
        when(mockUser.updateDisplayName('New Name')).thenAnswer((_) async => null);
        when(
          mockUser.updatePhotoURL('https://example.com/photo.jpg'),
        ).thenAnswer((_) async => null);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.updateUserProfile({
          'displayName': 'New Name',
          'photoURL': 'https://example.com/photo.jpg',
        });

        // Assert
        expect(result, true);
        verify(mockUser.updateDisplayName('New Name')).called(1);
        verify(
          mockUser.updatePhotoURL('https://example.com/photo.jpg'),
        ).called(1);
      });

      test('should handle profile update errors', () async {
        // Arrange
        when(mockUser.updateDisplayName('New Name')).thenThrow(
          FirebaseAuthException(
            code: 'requires-recent-login',
            message: 'Please re-authenticate',
          ),
        );
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.updateUserProfile({
          'displayName': 'New Name',
        });

        // Assert
        expect(result, false);
      });
    });

    group('Sign Out', () {
      test('should sign out user successfully', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);

        // Act
        final result = await authService.signOut();

        // Assert
        expect(result, true);
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should handle sign out errors', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Network error',
          ),
        );

        // Act
        final result = await authService.signOut();

        // Assert
        expect(result, false);
      });
    });

    group('Authentication State', () {
      test('should return current user when authenticated', () {
        // Arrange
        when(mockUser.uid).thenReturn('current-user-uid');
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final currentUser = authService.currentUser;

        // Assert
        expect(currentUser, isNotNull);
        expect(currentUser?.uid, 'current-user-uid');
      });

      test('should return null when not authenticated', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final currentUser = authService.currentUser;

        // Assert
        expect(currentUser, null);
      });

      test('should listen to auth state changes', () async {
        // Arrange
        final authStateController = StreamController<User?>.broadcast();
        when(
          mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => authStateController.stream);

        // Act
        final authStateStream = authService.authStateChanges;

        // Assert
        expect(authStateStream, isNotNull);

        // Test state change
        authStateController.add(mockUser);
        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockFirebaseAuth.authStateChanges()).called(1);
      });
    });

    group('Email Verification', () {
      test('should send email verification', () async {
        // Arrange
        when(mockUser.sendEmailVerification()).thenAnswer((_) async => null);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.sendEmailVerification();

        // Assert
        expect(result, true);
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should check if email is verified', () {
        // Arrange
        when(mockUser.emailVerified).thenReturn(true);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final isVerified = authService.isEmailVerified;

        // Assert
        expect(isVerified, true);
      });
    });

    group('Input Validation', () {
      test('should validate email format', () {
        // Valid emails
        expect(authService.isValidEmail('test@example.com'), true);
        expect(authService.isValidEmail('user.name@domain.co.uk'), true);

        // Invalid emails
        expect(authService.isValidEmail('invalid-email'), false);
        expect(authService.isValidEmail('test@'), false);
        expect(authService.isValidEmail('@example.com'), false);
        expect(authService.isValidEmail(''), false);
      });

      test('should validate password strength', () {
        // Strong passwords
        expect(authService.isStrongPassword('Password123!'), true);
        expect(authService.isStrongPassword('MySecure@Pass1'), true);

        // Weak passwords
        expect(authService.isStrongPassword('123'), false);
        expect(authService.isStrongPassword('password'), false);
        expect(authService.isStrongPassword('PASSWORD'), false);
        expect(authService.isStrongPassword('Password'), false);
        expect(authService.isStrongPassword(''), false);
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            'test@example.com',
            'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should handle too many requests error', () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many attempts',
          ),
        );

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            'test@example.com',
            'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });
  });
}
