import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ErrorService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize error handling
  static Future<void> initialize() async {
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      log(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );
      _crashlytics.recordFlutterFatalError(details);
    };

    // Set up async error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      log('Platform Error: $error', error: error, stackTrace: stack);
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Record non-fatal errors
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) async {
    try {
      log(
        'Error recorded: $exception',
        error: exception,
        stackTrace: stackTrace,
      );

      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      log('Failed to record error: $e');
    }
  }

  // Set user context for crash reports
  static Future<void> setUserContext({
    required String userId,
    String? role,
    String? email,
  }) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      if (role != null) await _crashlytics.setCustomKey('user_role', role);
      if (email != null) await _crashlytics.setCustomKey('user_email', email);
    } catch (e) {
      log('Failed to set user context: $e');
    }
  }

  // Log custom events
  static Future<void> logEvent(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    try {
      log('Event: $message', error: data);
      await _crashlytics.log(message);

      if (data != null) {
        for (final entry in data.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }
    } catch (e) {
      log('Failed to log event: $e');
    }
  }

  // Show user-friendly error messages
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success messages
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  // Show info messages
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  // Handle network errors
  static String getNetworkErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please check your account permissions.';
    } else if (error.toString().contains('not found')) {
      return 'Resource not found. Please refresh and try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Handle Firebase errors
  static String getFirebaseErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('user-not-found')) {
      return 'User account not found. Please sign in again.';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorString.contains('email-already-in-use')) {
      return 'This email is already registered. Please use a different email.';
    } else if (errorString.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid email address. Please check your email format.';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'Authentication error. Please try again.';
    }
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
                child: Text(actionText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        );
      },
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
