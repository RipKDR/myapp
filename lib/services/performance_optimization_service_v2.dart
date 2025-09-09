import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';

/// Advanced Performance Optimization Service
/// Provides comprehensive performance monitoring, optimization, and management
class PerformanceOptimizationServiceV2 {
  static final PerformanceOptimizationServiceV2 _instance =
      PerformanceOptimizationServiceV2._internal();
  factory PerformanceOptimizationServiceV2() => _instance;
  PerformanceOptimizationServiceV2._internal();

  // Performance metrics
  final Map<String, List<Duration>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};
  final Map<String, DateTime> _startTimes = {};
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Configuration
  static const Duration _defaultCacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 100;
  static const int _maxOperationHistory = 1000;

  // Connectivity
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  final StreamController<ConnectivityResult> _connectivityController =
      StreamController<ConnectivityResult>.broadcast();

  // Background processing
  bool _backgroundProcessingEnabled = false;
  Timer? _cleanupTimer;
  Timer? _metricsTimer;

  /// Initialize the performance optimization service
  Future<void> initialize() async {
    try {
      // Initialize connectivity monitoring
      await _initializeConnectivity();

      // Initialize background processing
      await _initializeBackgroundProcessing();

      // Start cleanup timer
      _startCleanupTimer();

      // Start metrics collection
      _startMetricsCollection();

      developer
          .log('Performance Optimization Service initialized successfully');
    } catch (e) {
      developer
          .log('Failed to initialize Performance Optimization Service: $e');
      rethrow;
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivity() async {
    try {
      // Get initial connectivity status
      final connectivity = Connectivity();
      final initialResults = await connectivity.checkConnectivity();
      _connectivityStatus = initialResults.isNotEmpty
          ? initialResults.first
          : ConnectivityResult.none;

      // Listen for connectivity changes
      connectivity.onConnectivityChanged
          .listen((List<ConnectivityResult> results) {
        final newStatus =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        if (newStatus != _connectivityStatus) {
          _connectivityStatus = newStatus;
          _connectivityController.add(newStatus);
          _onConnectivityChanged(newStatus);
        }
      });
    } catch (e) {
      developer.log('Failed to initialize connectivity monitoring: $e');
      // Set default status on error
      _connectivityStatus = ConnectivityResult.none;
    }
  }

  /// Initialize background processing
  Future<void> _initializeBackgroundProcessing() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Register background tasks
      await _registerBackgroundTasks();

      _backgroundProcessingEnabled = true;
    } catch (e) {
      developer.log('Failed to initialize background processing: $e');
    }
  }

  /// Register background tasks
  Future<void> _registerBackgroundTasks() async {
    // Cache cleanup task
    await Workmanager().registerPeriodicTask(
      'cache_cleanup',
      'cacheCleanup',
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType:
            null, // Network type detection not required for this operation
        requiresBatteryNotLow: false,
      ),
    );

    // Performance metrics collection
    await Workmanager().registerPeriodicTask(
      'metrics_collection',
      'metricsCollection',
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupExpiredCache();
      _cleanupOldMetrics();
    });
  }

  /// Start metrics collection
  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _collectSystemMetrics();
    });
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult status) {
    switch (status) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        _onConnectionRestored();
        break;
      case ConnectivityResult.none:
        _onConnectionLost();
        break;
      default:
        break;
    }
  }

  /// Handle connection restored
  void _onConnectionRestored() {
    developer.log('Connection restored - enabling network operations');
    // Resume network operations, sync cached data, etc.
  }

  /// Handle connection lost
  void _onConnectionLost() {
    developer.log('Connection lost - switching to offline mode');
    // Switch to offline mode, use cached data, etc.
  }

  /// Start timing an operation
  void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  /// End timing an operation
  void endTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _recordOperationTime(operation, duration);
      _startTimes.remove(operation);
    }
  }

  /// Record operation time
  void _recordOperationTime(String operation, Duration duration) {
    _operationTimes.putIfAbsent(operation, () => []).add(duration);
    _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;

    // Limit history size
    if (_operationTimes[operation]!.length > _maxOperationHistory) {
      _operationTimes[operation]!.removeAt(0);
    }
  }

  /// Get average time for an operation
  Duration? getAverageTime(String operation) {
    final times = _operationTimes[operation];
    if (times == null || times.isEmpty) return null;

    final total = times.fold<Duration>(
      Duration.zero,
      (sum, time) => sum + time,
    );

    return Duration(
      microseconds: total.inMicroseconds ~/ times.length,
    );
  }

  /// Get operation statistics
  Map<String, dynamic> getOperationStats(String operation) {
    final times = _operationTimes[operation] ?? [];
    final count = _operationCounts[operation] ?? 0;

    if (times.isEmpty) {
      return {
        'operation': operation,
        'count': count,
        'averageTime': null,
        'minTime': null,
        'maxTime': null,
        'totalTime': Duration.zero,
      };
    }

    final total = times.fold<Duration>(
      Duration.zero,
      (sum, time) => sum + time,
    );

    final min = times.reduce((a, b) => a < b ? a : b);
    final max = times.reduce((a, b) => a > b ? a : b);
    final average = Duration(
      microseconds: total.inMicroseconds ~/ times.length,
    );

    return {
      'operation': operation,
      'count': count,
      'averageTime': average,
      'minTime': min,
      'maxTime': max,
      'totalTime': total,
    };
  }

  /// Get all performance metrics
  Map<String, dynamic> getAllMetrics() {
    final operationStats = <String, Map<String, dynamic>>{};
    for (var operation in _operationTimes.keys) {
      operationStats[operation] = getOperationStats(operation);
    }

    return {
      'operations': operationStats,
      'cacheSize': _cache.length,
      'connectivityStatus': _connectivityStatus.toString(),
      'backgroundProcessingEnabled': _backgroundProcessingEnabled,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Cache data with expiration
  void cacheData<T>(String key, T data, {Duration? expiry}) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();

    // Limit cache size
    if (_cache.length > _maxCacheSize) {
      _evictOldestCacheEntry();
    }
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    if (!_cache.containsKey(key)) return null;

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    final expiry = _defaultCacheExpiry;
    if (DateTime.now().difference(timestamp) > expiry) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Clear cache for specific pattern
  void clearCachePattern(String pattern) {
    final keysToRemove =
        _cache.keys.where((key) => key.contains(pattern)).toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Cleanup expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _defaultCacheExpiry) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Cleanup old metrics
  void _cleanupOldMetrics() {
    _operationTimes.forEach((operation, times) {
      // Keep only recent times (this is a simplified approach)
      if (times.length > _maxOperationHistory) {
        _operationTimes[operation] =
            times.skip(times.length - _maxOperationHistory).toList();
      }
    });
  }

  /// Evict oldest cache entry
  void _evictOldestCacheEntry() {
    if (_cacheTimestamps.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    _cacheTimestamps.forEach((key, time) {
      if (oldestTime == null || time.isBefore(oldestTime!)) {
        oldestTime = time;
        oldestKey = key;
      }
    });

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  /// Collect system metrics
  void _collectSystemMetrics() {
    // This would collect system-level metrics like memory usage, CPU usage, etc.
    // For now, we'll just log the current metrics
    if (kDebugMode) {
      developer.log('Performance metrics: ${getAllMetrics()}');
    }
  }

  /// Get connectivity status
  ConnectivityResult get connectivityStatus => _connectivityStatus;

  /// Get connectivity stream
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  /// Check if connected to internet
  bool get isConnected => _connectivityStatus != ConnectivityResult.none;

  /// Check if connected to WiFi
  bool get isConnectedToWifi => _connectivityStatus == ConnectivityResult.wifi;

  /// Check if connected to mobile data
  bool get isConnectedToMobile =>
      _connectivityStatus == ConnectivityResult.mobile;

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _metricsTimer?.cancel();
    _connectivityController.close();
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'cacheCleanup':
        await _performCacheCleanup();
        break;
      case 'metricsCollection':
        await _collectPerformanceMetrics();
        break;
      default:
        break;
    }
    return Future.value(true);
  });
}

/// Perform cache cleanup in background
Future<void> _performCacheCleanup() async {
  // Implement cache cleanup logic
  developer.log('Performing background cache cleanup');
}

/// Collect performance metrics in background
Future<void> _collectPerformanceMetrics() async {
  // Implement metrics collection logic
  developer.log('Collecting performance metrics in background');
}

/// Performance monitoring mixin for easy integration
mixin PerformanceMonitoring {
  PerformanceOptimizationServiceV2 get _performanceService =>
      PerformanceOptimizationServiceV2();

  /// Monitor operation performance
  Future<T> monitorOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    _performanceService.startTimer(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      _performanceService.endTimer(operationName);
    }
  }

  /// Monitor synchronous operation performance
  T monitorSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    _performanceService.startTimer(operationName);
    try {
      final result = operation();
      return result;
    } finally {
      _performanceService.endTimer(operationName);
    }
  }

  /// Cache data with performance monitoring
  void cacheWithMonitoring<T>(String key, T data, {Duration? expiry}) {
    _performanceService.cacheData(key, data, expiry: expiry);
  }

  /// Get cached data with performance monitoring
  T? getCachedWithMonitoring<T>(String key) {
    return _performanceService.getCachedData<T>(key);
  }
}
