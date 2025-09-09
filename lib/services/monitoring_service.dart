import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Monitoring Service for NDIS Connect
/// 
/// This service handles system monitoring, health checks,
/// and performance tracking for the application.
class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  Timer? _healthCheckTimer;
  Timer? _performanceTimer;
  bool _isMonitoring = false;
  DateTime? _appStartTime;
  int _sessionDuration = 0;

  /// Initialize monitoring service
  Future<void> initialize() async {
    if (_isMonitoring) return;

    _appStartTime = DateTime.now();
    _isMonitoring = true;

    // Start health checks
    _startHealthChecks();
    
    // Start performance monitoring
    _startPerformanceMonitoring();
    
    // Monitor connectivity
    _monitorConnectivity();
    
    // Set up crash reporting
    _setupCrashReporting();

    await _analytics.logEvent('monitoring_initialized');
  }

  /// Start periodic health checks
  void _startHealthChecks() {
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performHealthCheck(),
    );
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _collectPerformanceMetrics(),
    );
  }

  /// Monitor network connectivity
  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _analytics.logEvent('connectivity_changed', parameters: {
        'status': result.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Set up crash reporting
  void _setupCrashReporting() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Perform health check
  Future<void> _performHealthCheck() async {
    try {
      final healthData = <String, dynamic>{};

      // Check memory usage
      healthData['memory_usage'] = await _getMemoryUsage();
      
      // Check storage usage
      healthData['storage_usage'] = await _getStorageUsage();
      
      // Check network connectivity
      healthData['connectivity'] = await _checkConnectivity();
      
      // Check app performance
      healthData['performance'] = await _checkPerformance();

      await _analytics.logEvent('health_check', parameters: healthData.cast<String, Object>());
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'health_check',
      );
    }
  }

  /// Collect performance metrics
  Future<void> _collectPerformanceMetrics() async {
    try {
      final metrics = <String, dynamic>{};

      // App uptime
      if (_appStartTime != null) {
        _sessionDuration = DateTime.now().difference(_appStartTime!).inSeconds;
        metrics['session_duration'] = _sessionDuration;
      }

      // Memory usage
      metrics['memory_usage'] = await _getMemoryUsage();
      
      // Battery level (if available)
      metrics['battery_level'] = await _getBatteryLevel();
      
      // Network status
      metrics['network_status'] = await _getNetworkStatus();

      await _analytics.logPerformanceEvent(
        event: 'system_metrics',
        duration: _sessionDuration,
        unit: 'seconds',
        additionalParams: metrics.cast<String, Object>(),
      );
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'performance_metrics',
      );
    }
  }

  /// Get memory usage
  Future<int> _getMemoryUsage() async {
    try {
      // This is a simplified implementation
      // In a real app, you might use platform-specific APIs
      return ProcessInfo.currentRss;
    } catch (e) {
      return 0;
    }
  }

  /// Get storage usage
  Future<Map<String, dynamic>> _getStorageUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      return {
        'preferences_count': keys.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Check connectivity
  Future<String> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      return result.name;
    } catch (e) {
      return 'unknown';
    }
  }

  /// Check app performance
  Future<Map<String, dynamic>> _checkPerformance() async {
    try {
      return {
        'app_start_time': _appStartTime?.toIso8601String(),
        'session_duration': _sessionDuration,
        'is_monitoring': _isMonitoring,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get battery level
  Future<int> _getBatteryLevel() async {
    try {
      // This would require platform-specific implementation
      // For now, return a placeholder
      return 100;
    } catch (e) {
      return 0;
    }
  }

  /// Get network status
  Future<String> _getNetworkStatus() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      return result.name;
    } catch (e) {
      return 'unknown';
    }
  }

  /// Record app launch
  Future<void> recordAppLaunch() async {
    await _analytics.logAppLifecycle('app_launched');
    await _analytics.setCrashKey('app_launch_time', DateTime.now().toIso8601String());
  }

  /// Record app background
  Future<void> recordAppBackground() async {
    await _analytics.logAppLifecycle('app_backgrounded');
  }

  /// Record app foreground
  Future<void> recordAppForeground() async {
    await _analytics.logAppLifecycle('app_foregrounded');
  }

  /// Record app termination
  Future<void> recordAppTermination() async {
    await _analytics.logAppLifecycle('app_terminated');
    await _analytics.setCrashKey('session_duration', _sessionDuration.toString());
  }

  /// Record feature usage
  Future<void> recordFeatureUsage({
    required String feature,
    required String action,
    Map<String, Object>? additionalParams,
  }) async {
    await _analytics.logFeatureUsage(
      feature: feature,
      action: action,
      additionalParams: additionalParams,
    );
  }

  /// Record user interaction
  Future<void> recordUserInteraction({
    required String interaction,
    required String screen,
    Map<String, Object>? additionalParams,
  }) async {
      await _analytics.logEvent('user_interaction', parameters: {
        'interaction': interaction,
        'screen': screen,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalParams,
      });
  }

  /// Record error
  Future<void> recordError({
    required String error,
    required String context,
    StackTrace? stackTrace,
    Map<String, Object>? additionalParams,
  }) async {
    await _analytics.logError(
      error: error,
      context: context,
      additionalParams: additionalParams,
    );

    if (stackTrace != null) {
      await _analytics.recordCrash(
        error: error,
        stackTrace: stackTrace,
        context: context,
        additionalParams: additionalParams,
      );
    }
  }

  /// Record performance issue
  Future<void> recordPerformanceIssue({
    required String issue,
    required int duration,
    required String unit,
    Map<String, Object>? additionalParams,
  }) async {
    await _analytics.logPerformanceEvent(
      event: issue,
      duration: duration,
      unit: unit,
      additionalParams: additionalParams,
    );
  }

  /// Record accessibility event
  Future<void> recordAccessibilityEvent({
    required String event,
    required String feature,
    bool? enabled,
    Map<String, Object>? additionalParams,
  }) async {
    await _analytics.logAccessibilityEvent(
      event: event,
      feature: feature,
      enabled: enabled,
      additionalParams: additionalParams,
    );
  }

  /// Record user feedback
  Future<void> recordUserFeedback({
    required String feedbackType,
    required String feedback,
    int? rating,
    Map<String, Object>? additionalParams,
  }) async {
    await _analytics.logUserFeedback(
      feedbackType: feedbackType,
      feedback: feedback,
      rating: rating,
      additionalParams: additionalParams,
    );
  }

  /// Get monitoring status
  Map<String, dynamic> getMonitoringStatus() {
    return {
      'is_monitoring': _isMonitoring,
      'app_start_time': _appStartTime?.toIso8601String(),
      'session_duration': _sessionDuration,
      'health_check_active': _healthCheckTimer?.isActive ?? false,
      'performance_monitoring_active': _performanceTimer?.isActive ?? false,
    };
  }

  /// Stop monitoring
  void stopMonitoring() {
    _healthCheckTimer?.cancel();
    _performanceTimer?.cancel();
    _isMonitoring = false;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
