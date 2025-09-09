import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics Service for NDIS Connect
///
/// This service handles all analytics tracking, crash reporting,
/// and performance monitoring for the application.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  bool _isInitialized = false;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Set up crash reporting
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Set up analytics
      await _analytics.setAnalyticsCollectionEnabled(true);

      // Set default parameters
      await _analytics.setDefaultEventParameters({
        'app_version': '1.0.0',
        'platform': defaultTargetPlatform.name,
        'accessibility_enabled': true,
      });

      _isInitialized = true;
      logEvent('analytics_initialized');
    } catch (e) {
      debugPrint('Failed to initialize analytics: $e');
    }
  }

  /// Log a custom event
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_isInitialized) return;

    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Failed to log event $name: $e');
    }
  }

  /// Log user login event
  Future<void> logLogin(String method, {String? userId}) async {
    await _analytics.logLogin(loginMethod: method);
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
  }

  /// Log user registration event
  Future<void> logSignUp(String method, {String? userId}) async {
    await _analytics.logSignUp(signUpMethod: method);
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
  }

  /// Log appointment booking event
  Future<void> logAppointmentBooked({
    required String providerId,
    required String appointmentType,
    required DateTime appointmentDate,
  }) async {
    await logEvent('appointment_booked', parameters: {
      'provider_id': providerId,
      'appointment_type': appointmentType,
      'appointment_date': appointmentDate.toIso8601String(),
    });
  }

  /// Log budget tracking event
  Future<void> logBudgetViewed({
    required String category,
    required double amount,
    required double remaining,
  }) async {
    await logEvent('budget_viewed', parameters: {
      'category': category,
      'amount': amount,
      'remaining': remaining,
      'percentage_used': ((amount - remaining) / amount * 100).round(),
    });
  }

  /// Log accessibility feature usage
  Future<void> logAccessibilityFeatureUsed({
    required String feature,
    required bool enabled,
  }) async {
    await logEvent('accessibility_feature_used', parameters: {
      'feature': feature,
      'enabled': enabled,
    });
  }

  /// Log support circle interaction
  Future<void> logSupportCircleInteraction({
    required String action,
    required String circleId,
    required int memberCount,
  }) async {
    await logEvent('support_circle_interaction', parameters: {
      'action': action,
      'circle_id': circleId,
      'member_count': memberCount,
    });
  }

  /// Log provider directory search
  Future<void> logProviderSearch({
    required String searchTerm,
    required String location,
    required int resultCount,
  }) async {
    await logEvent('provider_search', parameters: {
      'search_term': searchTerm,
      'location': location,
      'result_count': resultCount,
    });
  }

  /// Log feature usage
  Future<void> logFeatureUsage({
    required String feature,
    required String action,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'feature': feature,
      'action': action,
      ...?additionalParams,
    };
    await logEvent('feature_usage', parameters: params);
  }

  /// Log performance metrics
  Future<void> logPerformanceMetric({
    required String metric,
    required int value,
    required String unit,
  }) async {
    await logEvent('performance_metric', parameters: {
      'metric': metric,
      'value': value,
      'unit': unit,
    });
  }

  /// Log error event
  Future<void> logError({
    required String error,
    required String context,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'error': error,
      'context': context,
      ...?additionalParams,
    };
    await logEvent('error_occurred', parameters: params);
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    String? userRole,
    String? accessibilityLevel,
    String? preferredLanguage,
  }) async {
    if (!_isInitialized) return;

    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      if (userRole != null) {
        await _analytics.setUserProperty(name: 'user_role', value: userRole);
      }

      if (accessibilityLevel != null) {
        await _analytics.setUserProperty(
            name: 'accessibility_level', value: accessibilityLevel);
      }

      if (preferredLanguage != null) {
        await _analytics.setUserProperty(
            name: 'preferred_language', value: preferredLanguage);
      }
    } catch (e) {
      debugPrint('Failed to set user properties: $e');
    }
  }

  /// Record screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Record user engagement
  Future<void> logUserEngagement({
    required String engagementType,
    required int duration,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'engagement_type': engagementType,
      'duration': duration,
      ...?additionalParams,
    };
    await logEvent('user_engagement', parameters: params);
  }

  /// Record crash
  Future<void> recordCrash({
    required String error,
    required StackTrace stackTrace,
    String? context,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: context,
      );
    } catch (e) {
      debugPrint('Failed to record crash: $e');
    }
  }

  /// Set custom crash keys
  Future<void> setCrashKey(String key, String value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Failed to set crash key: $e');
    }
  }

  /// Log breadcrumb for crash context
  Future<void> logBreadcrumb(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('Failed to log breadcrumb: $e');
    }
  }

  /// Record user feedback
  Future<void> logUserFeedback({
    required String feedbackType,
    required String feedback,
    int? rating,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'feedback_type': feedbackType,
      'feedback': feedback,
      if (rating != null) 'rating': rating,
      ...?additionalParams,
    };
    await logEvent('user_feedback', parameters: params);
  }

  /// Record app lifecycle events
  Future<void> logAppLifecycle(String event) async {
    await logEvent('app_lifecycle', parameters: {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Record accessibility events
  Future<void> logAccessibilityEvent({
    required String event,
    required String feature,
    bool? enabled,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'event': event,
      'feature': feature,
      if (enabled != null) 'enabled': enabled,
      ...?additionalParams,
    };
    await logEvent('accessibility_event', parameters: params);
  }

  /// Record performance events
  Future<void> logPerformanceEvent({
    required String event,
    required int duration,
    required String unit,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'event': event,
      'duration': duration,
      'unit': unit,
      ...?additionalParams,
    };
    await logEvent('performance_event', parameters: params);
  }

  /// Get analytics instance for advanced usage
  FirebaseAnalytics get analytics => _analytics;

  /// Get crashlytics instance for advanced usage
  FirebaseCrashlytics get crashlytics => _crashlytics;
}
