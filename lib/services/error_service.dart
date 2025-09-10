import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorService {
  static FirebaseCrashlytics? _crashlytics;
  static final Connectivity _connectivity = Connectivity();
  static final List<ErrorRecoveryAction> _recoveryActions = [];
  static final Map<String, int> _retryCounts = {};
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Initialize error handling
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web: Crashlytics not supported. Log errors to console instead.
      FlutterError.onError = (final details) {
        log(
          'Flutter Error: ${details.exception}',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      return;
    }

    // Initialize Crashlytics lazily on supported platforms
    _crashlytics = FirebaseCrashlytics.instance;

    // Set up Flutter error handling
    FlutterError.onError = (final details) {
      log(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );
      _crashlytics?.recordFlutterFatalError(details);
    };

    // Set up async error handling
    ui.PlatformDispatcher.instance.onError = (final error, final stack) {
      log('Platform Error: $error', error: error, stackTrace: stack);
      _crashlytics?.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Record non-fatal errors
  static Future<void> recordError(
    final dynamic exception,
    final StackTrace? stackTrace, {
    final String? reason,
    final bool fatal = false,
    final Map<String, dynamic>? customKeys,
  }) async {
    try {
      log(
        'Error recorded: $exception',
        error: exception,
        stackTrace: stackTrace,
      );

      if (_crashlytics != null && customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics!.setCustomKey(entry.key, entry.value as Object);
        }
      }

      await _crashlytics?.recordError(
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
    required final String userId,
    final String? role,
    final String? email,
  }) async {
    try {
      await _crashlytics?.setUserIdentifier(userId);
      if (role != null) await _crashlytics?.setCustomKey('user_role', role);
      if (email != null) await _crashlytics?.setCustomKey('user_email', email);
    } catch (e) {
      log('Failed to set user context: $e');
    }
  }

  // Log custom events
  static Future<void> logEvent(
    final String message, {
    final Map<String, dynamic>? data,
  }) async {
    try {
      log('Event: $message', error: data);
      await _crashlytics?.log(message);

      if (_crashlytics != null && data != null) {
        for (final entry in data.entries) {
          await _crashlytics!.setCustomKey(entry.key, entry.value as Object);
        }
      }
    } catch (e) {
      log('Failed to log event: $e');
    }
  }

  // Show user-friendly error messages
  static void showErrorSnackBar(
    final BuildContext context,
    final String message, {
    final Duration? duration,
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
    final BuildContext context,
    final String message, {
    final Duration? duration,
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
    final BuildContext context,
    final String message, {
    final Duration? duration,
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
  static String getNetworkErrorMessage(final dynamic error) {
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
  static String getFirebaseErrorMessage(final dynamic error) {
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
    final BuildContext context, {
    required final String title,
    required final String message,
    final String? actionText,
    final VoidCallback? onAction,
  }) async => showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final context) => AlertDialog(
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
        ),
    );

  // Show loading dialog
  static void showLoadingDialog(final BuildContext context, {final String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final context) => AlertDialog(
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
        ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(final BuildContext context) {
    Navigator.of(context).pop();
  }

  // Enhanced error handling with retry mechanism
  static Future<T?> handleWithRetry<T>(
    final Future<T> Function() operation, {
    final String? operationId,
    final int maxRetries = _maxRetries,
    final Duration retryDelay = _retryDelay,
    final bool Function(dynamic error)? shouldRetry,
  }) async {
    final id = operationId ?? DateTime.now().millisecondsSinceEpoch.toString();
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final result = await operation();
        _retryCounts.remove(id); // Reset retry count on success
        return result;
      } catch (error) {
        attempts++;
        _retryCounts[id] = attempts;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // Check if we've exceeded max retries
        if (attempts >= maxRetries) {
          await recordError(
            error,
            StackTrace.current,
            reason: 'Max retries exceeded for operation: $id',
          );
          rethrow;
        }

        // Check connectivity before retrying
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          throw Exception('No internet connection available');
        }

        // Wait before retrying
        await Future.delayed(retryDelay * attempts);
      }
    }

    return null;
  }

  // Network-aware error handling
  static Future<T?> handleNetworkOperation<T>(
    final Future<T> Function() operation, {
    final String? operationName,
    final bool showUserFeedback = true,
    final BuildContext? context,
  }) async {
    try {
      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (showUserFeedback && context != null) {
          showErrorSnackBar(
            context,
            'No internet connection. Please check your network settings.',
          );
        }
        throw Exception('No internet connection');
      }

      return await operation();
    } catch (error) {
      await recordError(
        error,
        StackTrace.current,
        reason: 'Network operation failed: ${operationName ?? 'Unknown'}',
      );

      if (showUserFeedback && context != null) {
        final message = getNetworkErrorMessage(error);
        showErrorSnackBar(context, message);
      }

      rethrow;
    }
  }

  // Add recovery action
  static void addRecoveryAction(final ErrorRecoveryAction action) {
    _recoveryActions.add(action);
  }

  // Remove recovery action
  static void removeRecoveryAction(final ErrorRecoveryAction action) {
    _recoveryActions.remove(action);
  }

  // Execute recovery actions
  static Future<void> executeRecoveryActions(final dynamic error) async {
    for (final action in _recoveryActions) {
      try {
        await action.execute(error);
      } catch (e) {
        log('Recovery action failed: $e');
      }
    }
  }

  // Check if operation should be retried
  static bool shouldRetryOperation(final dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Retry on network errors
    if (errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return true;
    }

    // Retry on server errors (5xx)
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }

    // Don't retry on client errors (4xx) except 408 (timeout)
    if (errorString.contains('400') ||
        errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('404')) {
      return false;
    }

    return false;
  }

  // Get retry count for operation
  static int getRetryCount(final String operationId) => _retryCounts[operationId] ?? 0;

  // Clear retry count for operation
  static void clearRetryCount(final String operationId) {
    _retryCounts.remove(operationId);
  }

  // Show retry dialog
  static Future<bool> showRetryDialog(
    final BuildContext context, {
    required final String message,
    final String? title,
  }) async => await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (final context) => AlertDialog(
              title: Text(title ?? 'Operation Failed'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Retry'),
                ),
              ],
            ),
        ) ??
        false;

  // Handle offline scenarios
  static Future<void> handleOfflineScenario(
    final BuildContext context, {
    required final String message,
    final VoidCallback? onRetry,
  }) async {
    showErrorDialog(
      context,
      title: 'Offline Mode',
      message: message,
      actionText: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  // Log performance issues
  static Future<void> logPerformanceIssue(
    final String operation,
    final Duration duration, {
    final Map<String, dynamic>? metadata,
  }) async {
    if (duration.inMilliseconds > 3000) {
      // Log if operation takes > 3 seconds
      await recordError(
        'Performance Issue: $operation took ${duration.inMilliseconds}ms',
        StackTrace.current,
        reason: 'Slow operation detected',
        customKeys: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          ...?metadata,
        },
      );
    }
  }
}

// Error recovery action interface
abstract class ErrorRecoveryAction {
  Future<void> execute(final dynamic error);
  String get description;
}

// Network recovery action
class NetworkRecoveryAction implements ErrorRecoveryAction {
  @override
  String get description => 'Network connectivity recovery';

  @override
  Future<void> execute(final dynamic error) async {
    // Implement network recovery logic
    // This could include reconnecting to services, clearing caches, etc.
  }
}

// Authentication recovery action
class AuthRecoveryAction implements ErrorRecoveryAction {
  @override
  String get description => 'Authentication recovery';

  @override
  Future<void> execute(final dynamic error) async {
    // Implement authentication recovery logic
    // This could include refreshing tokens, re-authenticating, etc.
  }
}
