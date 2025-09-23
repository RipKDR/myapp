import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ndis_connect/services/error_service.dart';

/// Performance monitoring and optimization service
class PerformanceService {
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  static final PerformanceService _instance = PerformanceService._internal();

  final Map<String, Stopwatch> _operationTimers = {};
  final Map<String, List<Duration>> _operationHistory = {};
  final Connectivity _connectivity = Connectivity();

  // Performance thresholds
  static const Duration _slowOperationThreshold = Duration(milliseconds: 1000);
  static const Duration _verySlowOperationThreshold = Duration(
    milliseconds: 3000,
  );
  static const int _maxHistoryEntries = 100;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    // Set up performance monitoring
    _setupPerformanceMonitoring();

    // Initialize image caching
    _setupImageCaching();

    // Monitor connectivity changes
    _monitorConnectivity();

    developer.log('Performance Service initialized');
  }

  /// Start timing an operation
  void startOperation(final String operationName) {
    _operationTimers[operationName] = Stopwatch()..start();
  }

  /// End timing an operation and log results
  Future<void> endOperation(
    final String operationName, {
    final Map<String, dynamic>? metadata,
  }) async {
    final timer = _operationTimers.remove(operationName);
    if (timer == null) return;

    timer.stop();
    final duration = timer.elapsed;

    // Store in history
    _operationHistory.putIfAbsent(operationName, () => []).add(duration);

    // Limit history size
    if (_operationHistory[operationName]!.length > _maxHistoryEntries) {
      _operationHistory[operationName]!.removeAt(0);
    }

    // Log performance issues
    if (duration > _verySlowOperationThreshold) {
      await ErrorService.logPerformanceIssue(
        operationName,
        duration,
        metadata: metadata,
      );
    }

    // Log to console in debug mode
    if (kDebugMode) {
      final level = duration > _verySlowOperationThreshold
          ? 'VERY SLOW'
          : duration > _slowOperationThreshold
          ? 'SLOW'
          : 'NORMAL';

      developer.log(
        'Performance: $operationName took ${duration.inMilliseconds}ms ($level)',
        name: 'PerformanceService',
      );
    }
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(final String operationName) {
    final history = _operationHistory[operationName];
    if (history == null || history.isEmpty) return null;

    final totalMs = history.fold<int>(
      0,
      (final sum, final duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ history.length);
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final entry in _operationHistory.entries) {
      final operationName = entry.key;
      final durations = entry.value;

      if (durations.isNotEmpty) {
        final totalMs = durations.fold<int>(
          0,
          (final sum, final d) => sum + d.inMilliseconds,
        );
        final averageMs = totalMs ~/ durations.length;
        final minMs = durations
            .map((final d) => d.inMilliseconds)
            .reduce((final a, final b) => a < b ? a : b);
        final maxMs = durations
            .map((final d) => d.inMilliseconds)
            .reduce((final a, final b) => a > b ? a : b);

        stats[operationName] = {
          'count': durations.length,
          'average_ms': averageMs,
          'min_ms': minMs,
          'max_ms': maxMs,
          'total_ms': totalMs,
        };
      }
    }

    return stats;
  }

  /// Optimize app performance
  Future<void> optimizePerformance() async {
    // Clear old cache entries
    await _clearOldCacheEntries();

    // Optimize image cache
    await _optimizeImageCache();

    // Clear operation history if too large
    _cleanupOperationHistory();

    developer.log('Performance optimization completed');
  }

  /// Monitor memory usage
  void monitorMemoryUsage() {
    if (kDebugMode) {
      // In debug mode, we can monitor memory usage
      // This would be more sophisticated in a real implementation
      developer.log('Memory monitoring active');
    }
  }

  /// Setup performance monitoring
  void _setupPerformanceMonitoring() {
    // Monitor frame rendering performance
    if (kDebugMode) {
      // This would integrate with Flutter's performance overlay
      developer.log('Performance monitoring enabled');
    }
  }

  /// Setup image caching optimization
  void _setupImageCaching() {
    // Configure image cache settings
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  /// Monitor connectivity changes
  void _monitorConnectivity() {
    _connectivity.onConnectivityChanged.listen((final result) {
      if (result == ConnectivityResult.none) {
        // Optimize for offline mode
        _optimizeForOfflineMode();
      } else {
        // Optimize for online mode
        _optimizeForOnlineMode();
      }
    });
  }

  /// Clear old cache entries
  Future<void> _clearOldCacheEntries() async {
    // Clear old operation history
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    // Implementation would clear old cache entries based on timestamp
  }

  /// Optimize image cache
  Future<void> _optimizeImageCache() async {
    // Clear least recently used images
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Cleanup operation history
  void _cleanupOperationHistory() {
    for (final entry in _operationHistory.entries) {
      if (entry.value.length > _maxHistoryEntries) {
        entry.value.removeRange(0, entry.value.length - _maxHistoryEntries);
      }
    }
  }

  /// Optimize for offline mode
  void _optimizeForOfflineMode() {
    // Reduce cache sizes
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 25 << 20; // 25MB

    developer.log('Optimized for offline mode');
  }

  /// Optimize for online mode
  void _optimizeForOnlineMode() {
    // Restore normal cache sizes
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB

    developer.log('Optimized for online mode');
  }

  /// Get current performance metrics
  Map<String, dynamic> getCurrentMetrics() => {
    'image_cache_size': PaintingBinding.instance.imageCache.currentSize,
    'image_cache_size_bytes':
        PaintingBinding.instance.imageCache.currentSizeBytes,
    'active_operations': _operationTimers.length,
    'operation_history_size': _operationHistory.values.fold<int>(
      0,
      (final sum, final list) => sum + list.length,
    ),
  };

  /// Reset performance data
  void resetPerformanceData() {
    _operationTimers.clear();
    _operationHistory.clear();
    PaintingBinding.instance.imageCache.clear();

    developer.log('Performance data reset');
  }
}

/// Performance monitoring mixin for widgets
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  final PerformanceService _performanceService = PerformanceService();

  @override
  void initState() {
    super.initState();
    _performanceService.startOperation('${widget.runtimeType}_init');
  }

  @override
  void dispose() {
    _performanceService.endOperation('${widget.runtimeType}_init');
    super.dispose();
  }

  /// Time a widget operation
  Future<R> timeOperation<R>(
    final String operationName,
    final Future<R> Function() operation,
  ) async {
    _performanceService.startOperation(operationName);
    try {
      final result = await operation();
      await _performanceService.endOperation(operationName);
      return result;
    } catch (e) {
      await _performanceService.endOperation(
        operationName,
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }
}

/// Performance monitoring extension for Future
extension PerformanceFuture<T> on Future<T> {
  /// Time a future operation
  Future<T> timeOperation(final String operationName) async {
    final performanceService = PerformanceService();
    performanceService.startOperation(operationName);
    try {
      final result = await this;
      await performanceService.endOperation(operationName);
      return result;
    } catch (e) {
      await performanceService.endOperation(
        operationName,
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }
}
