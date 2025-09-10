import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Advanced Multi-layer Caching Service with intelligent prefetching,
/// offline-first architecture, and performance optimization
class AdvancedCacheService {
  factory AdvancedCacheService() => _instance;
  AdvancedCacheService._internal();
  static final AdvancedCacheService _instance =
      AdvancedCacheService._internal();

  final AnalyticsService _analytics = AnalyticsService();

  // Cache layers
  late Box<dynamic> _memoryCache;
  late Box<dynamic> _diskCache;
  late Box<dynamic> _metadataCache;

  // Cache configuration
  static const int _maxMemoryItems = 100;
  static const int _maxDiskItems = 1000;
  static const Duration _defaultTTL = Duration(hours: 24);

  // Performance tracking
  final Map<String, CacheMetrics> _cacheMetrics = {};
  final Map<String, DateTime> _lastAccess = {};

  bool _isInitialized = false;
  bool _isOnline = true;

  /// Initialize the advanced cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive for disk caching
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);

      // Open cache boxes
      _memoryCache = await Hive.openBox('memory_cache');
      _diskCache = await Hive.openBox('disk_cache');
      _metadataCache = await Hive.openBox('metadata_cache');

      // Initialize connectivity monitoring
      await _initializeConnectivityMonitoring();

      // Load cache metrics
      await _loadCacheMetrics();

      // Start background cleanup
      _startBackgroundCleanup();

      _isInitialized = true;

      await _analytics.logEvent('advanced_cache_initialized', parameters: {
        'memory_items': _memoryCache.length,
        'disk_items': _diskCache.length,
        'metadata_items': _metadataCache.length,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Advanced cache initialization failed: $e',
        context: 'advanced_cache_service',
      );
      rethrow;
    }
  }

  /// Get data with multi-layer cache lookup and intelligent prefetching
  Future<T?> get<T>(final String key, {final T Function()? fetcher, final Duration? ttl}) async {
    if (!_isInitialized) await initialize();

    final startTime = DateTime.now();

    try {
      // L1: Memory cache lookup
      final memoryResult = await _getFromMemoryCache<T>(key);
      if (memoryResult != null) {
        await _updateCacheMetrics(
            key, 'memory_hit', DateTime.now().difference(startTime));
        return memoryResult;
      }

      // L2: Disk cache lookup
      final diskResult = await _getFromDiskCache<T>(key);
      if (diskResult != null) {
        // Promote to memory cache
        await _setMemoryCache(key, diskResult, ttl ?? _defaultTTL);
        await _updateCacheMetrics(
            key, 'disk_hit', DateTime.now().difference(startTime));
        return diskResult;
      }

      // L3: Network fetch (if fetcher provided and online)
      if (fetcher != null && _isOnline) {
        final networkResult = await _fetchFromNetwork<T>(key, fetcher, ttl);
        if (networkResult != null) {
          await _updateCacheMetrics(
              key, 'network_hit', DateTime.now().difference(startTime));
          return networkResult;
        }
      }

      // Cache miss
      await _updateCacheMetrics(
          key, 'cache_miss', DateTime.now().difference(startTime));
      return null;
    } catch (e) {
      await _analytics.logError(
        error: 'Cache get failed for key $key: $e',
        context: 'advanced_cache_service',
      );
      return null;
    }
  }

  /// Set data in cache with intelligent layer selection
  Future<void> set<T>(final String key, final T value,
      {final Duration? ttl, final CachePriority priority = CachePriority.normal}) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheTTL = ttl ?? _defaultTTL;
      final expiryTime = DateTime.now().add(cacheTTL);

      // Create cache entry
      final cacheEntry = CacheEntry<T>(
        value: value,
        expiryTime: expiryTime,
        priority: priority,
        createdAt: DateTime.now(),
      );

      // Store in appropriate cache layers based on priority
      switch (priority) {
        case CachePriority.high:
          await _setMemoryCache(key, cacheEntry, cacheTTL);
          await _setDiskCache(key, cacheEntry, cacheTTL);
          break;
        case CachePriority.normal:
          await _setDiskCache(key, cacheEntry, cacheTTL);
          break;
        case CachePriority.low:
          await _setDiskCache(key, cacheEntry, cacheTTL);
          break;
      }

      // Update metadata
      await _updateMetadata(key, cacheEntry);

      await _analytics.logEvent('cache_set', parameters: {
        'key': key,
        'priority': priority.name,
        'ttl': cacheTTL.inSeconds,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Cache set failed for key $key: $e',
        context: 'advanced_cache_service',
      );
    }
  }

  /// Prefetch data based on usage patterns and predictions
  Future<void> prefetch<T>(final String key, final Future<T> Function() fetcher,
      {final Duration? ttl}) async {
    if (!_isInitialized) await initialize();

    try {
      // Check if already cached
      final existing = await get<T>(key);
      if (existing != null) return;

      // Fetch and cache
      final data = await fetcher();
      await set(key, data, ttl: ttl);

      await _analytics.logEvent('cache_prefetch', parameters: {
        'key': key,
        'success': true,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Cache prefetch failed for key $key: $e',
        context: 'advanced_cache_service',
      );
    }
  }

  /// Intelligent batch prefetching based on user patterns
  Future<void> intelligentPrefetch<T>(
      final List<String> keys, final Future<Map<String, T>> Function() batchFetcher) async {
    if (!_isInitialized) await initialize();

    try {
      // Filter out already cached keys
      final uncachedKeys = <String>[];
      for (final key in keys) {
        final cached = await get<T>(key);
        if (cached == null) {
          uncachedKeys.add(key);
        }
      }

      if (uncachedKeys.isEmpty) return;

      // Batch fetch uncached data
      final batchData = await batchFetcher();

      // Cache all fetched data
      for (final entry in batchData.entries) {
        if (uncachedKeys.contains(entry.key)) {
          await set(entry.key, entry.value);
        }
      }

      await _analytics.logEvent('intelligent_prefetch', parameters: {
        'total_keys': keys.length,
        'uncached_keys': uncachedKeys.length,
        'fetched_keys': batchData.length,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Intelligent prefetch failed: $e',
        context: 'advanced_cache_service',
      );
    }
  }

  /// Remove data from cache
  Future<void> remove(final String key) async {
    if (!_isInitialized) await initialize();

    try {
      await _memoryCache.delete(key);
      await _diskCache.delete(key);
      await _metadataCache.delete(key);

      await _analytics.logEvent('cache_remove', parameters: {
        'key': key,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Cache remove failed for key $key: $e',
        context: 'advanced_cache_service',
      );
    }
  }

  /// Clear all cache data
  Future<void> clear() async {
    if (!_isInitialized) await initialize();

    try {
      await _memoryCache.clear();
      await _diskCache.clear();
      await _metadataCache.clear();

      _cacheMetrics.clear();
      _lastAccess.clear();

      await _analytics.logEvent('cache_clear', parameters: {
        'cleared_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Cache clear failed: $e',
        context: 'advanced_cache_service',
      );
    }
  }

  /// Get cache statistics and performance metrics
  Future<CacheStatistics> getStatistics() async {
    if (!_isInitialized) await initialize();

    final memoryItems = _memoryCache.length;
    final diskItems = _diskCache.length;
    final metadataItems = _metadataCache.length;

    // Calculate hit rates
    final totalHits =
        _cacheMetrics.values.fold<int>(0, (final sum, final metrics) => sum + metrics.hits);
    final totalMisses = _cacheMetrics.values
        .fold<int>(0, (final sum, final metrics) => sum + metrics.misses);
    final totalRequests = totalHits + totalMisses;

    final hitRate = totalRequests > 0 ? (totalHits / totalRequests) * 100 : 0.0;

    // Calculate average response times
    final totalResponseTime = _cacheMetrics.values.fold<Duration>(
      Duration.zero,
      (final sum, final metrics) => sum + metrics.totalResponseTime,
    );
    final averageResponseTime = totalRequests > 0
        ? Duration(
            microseconds: totalResponseTime.inMicroseconds ~/ totalRequests)
        : Duration.zero;

    return CacheStatistics(
      memoryItems: memoryItems,
      diskItems: diskItems,
      metadataItems: metadataItems,
      totalItems: memoryItems + diskItems,
      hitRate: hitRate,
      averageResponseTime: averageResponseTime,
      totalRequests: totalRequests,
      cacheMetrics: Map.unmodifiable(_cacheMetrics),
    );
  }

  /// Get data from memory cache
  Future<T?> _getFromMemoryCache<T>(final String key) async {
    try {
      final entry = _memoryCache.get(key);
      if (entry == null) return null;

      // Handle different entry types safely
      Map<String, dynamic> entryMap;
      if (entry is Map<String, dynamic>) {
        entryMap = entry;
      } else if (entry is Map) {
        entryMap = Map<String, dynamic>.from(entry);
      } else {
        // Invalid entry type, remove it
        await _memoryCache.delete(key);
        return null;
      }

      final cacheEntry = CacheEntry<T>.fromJson(entryMap);

      // Check expiry
      if (DateTime.now().isAfter(cacheEntry.expiryTime)) {
        await _memoryCache.delete(key);
        return null;
      }

      // Update access count and last access time
      cacheEntry.accessCount++;
      _lastAccess[key] = DateTime.now();
      await _memoryCache.put(key, cacheEntry.toJson());

      return cacheEntry.value;
    } catch (e) {
      debugPrint('Memory cache get error: $e');
      // Remove corrupted entry
      try {
        await _memoryCache.delete(key);
      } catch (_) {
        // Ignore delete errors
      }
      return null;
    }
  }

  /// Get data from disk cache
  Future<T?> _getFromDiskCache<T>(final String key) async {
    try {
      final entry = _diskCache.get(key);
      if (entry == null) return null;

      // Handle different entry types safely
      Map<String, dynamic> entryMap;
      if (entry is Map<String, dynamic>) {
        entryMap = entry;
      } else if (entry is Map) {
        entryMap = Map<String, dynamic>.from(entry);
      } else {
        // Invalid entry type, remove it
        await _diskCache.delete(key);
        return null;
      }

      final cacheEntry = CacheEntry<T>.fromJson(entryMap);

      // Check expiry
      if (DateTime.now().isAfter(cacheEntry.expiryTime)) {
        await _diskCache.delete(key);
        return null;
      }

      // Update access count and last access time
      cacheEntry.accessCount++;
      _lastAccess[key] = DateTime.now();
      await _diskCache.put(key, cacheEntry.toJson());

      return cacheEntry.value;
    } catch (e) {
      debugPrint('Disk cache get error: $e');
      // Remove corrupted entry
      try {
        await _diskCache.delete(key);
      } catch (_) {
        // Ignore delete errors
      }
      return null;
    }
  }

  /// Fetch data from network
  Future<T?> _fetchFromNetwork<T>(
      final String key, final T Function() fetcher, final Duration? ttl) async {
    try {
      final data = fetcher();
      if (data != null) {
        await set(key, data, ttl: ttl);
      }
      return data;
    } catch (e) {
      debugPrint('Network fetch error: $e');
      return null;
    }
  }

  /// Set data in memory cache
  Future<void> _setMemoryCache<T>(final String key, final T value, final Duration ttl) async {
    try {
      final expiryTime = DateTime.now().add(ttl);
      final cacheEntry = CacheEntry<T>(
        value: value,
        expiryTime: expiryTime,
        priority: CachePriority.high,
        createdAt: DateTime.now(),
      );

      await _memoryCache.put(key, cacheEntry.toJson());

      // Enforce memory cache size limit
      if (_memoryCache.length > _maxMemoryItems) {
        await _evictLeastRecentlyUsed();
      }
    } catch (e) {
      debugPrint('Memory cache set error: $e');
    }
  }

  /// Set data in disk cache
  Future<void> _setDiskCache<T>(final String key, final T value, final Duration ttl) async {
    try {
      final expiryTime = DateTime.now().add(ttl);
      final cacheEntry = CacheEntry<T>(
        value: value,
        expiryTime: expiryTime,
        priority: CachePriority.normal,
        createdAt: DateTime.now(),
      );

      await _diskCache.put(key, cacheEntry.toJson());

      // Enforce disk cache size limit
      if (_diskCache.length > _maxDiskItems) {
        await _evictLeastRecentlyUsed();
      }
    } catch (e) {
      debugPrint('Disk cache set error: $e');
    }
  }

  /// Update cache metadata
  Future<void> _updateMetadata<T>(final String key, final CacheEntry<T> entry) async {
    try {
      final metadata = CacheMetadata(
        key: key,
        priority: entry.priority,
        createdAt: entry.createdAt,
        lastAccessed: DateTime.now(),
        accessCount: entry.accessCount,
        size: _estimateSize(entry.value),
      );

      await _metadataCache.put(key, metadata.toJson());
    } catch (e) {
      debugPrint('Metadata update error: $e');
    }
  }

  /// Evict least recently used items
  Future<void> _evictLeastRecentlyUsed() async {
    try {
      // Sort by last access time
      final sortedKeys = _lastAccess.entries.toList()
        ..sort((final a, final b) => a.value.compareTo(b.value));

      // Remove oldest 10% of items
      final itemsToRemove = (sortedKeys.length * 0.1).ceil();
      for (int i = 0; i < itemsToRemove && i < sortedKeys.length; i++) {
        final key = sortedKeys[i].key;
        await _memoryCache.delete(key);
        await _diskCache.delete(key);
        await _metadataCache.delete(key);
        _lastAccess.remove(key);
      }
    } catch (e) {
      debugPrint('LRU eviction error: $e');
    }
  }

  /// Update cache metrics
  Future<void> _updateCacheMetrics(
      final String key, final String hitType, final Duration responseTime) async {
    final metrics = _cacheMetrics.putIfAbsent(key, CacheMetrics.new);

    switch (hitType) {
      case 'memory_hit':
        metrics.memoryHits++;
        break;
      case 'disk_hit':
        metrics.diskHits++;
        break;
      case 'network_hit':
        metrics.networkHits++;
        break;
      case 'cache_miss':
        metrics.misses++;
        break;
    }

    metrics.totalResponseTime += responseTime;
    _lastAccess[key] = DateTime.now();
  }

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivityMonitoring() async {
    final connectivity = Connectivity();

    connectivity.onConnectivityChanged
        .listen((final results) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      _isOnline = result != ConnectivityResult.none;

      _analytics.logEvent('connectivity_changed', parameters: {
        'is_online': _isOnline,
        'connection_type': result.name,
      });
    });

    // Get initial connectivity state
    final initialResults = await connectivity.checkConnectivity();
    final initialResult = initialResults.isNotEmpty
        ? initialResults.first
        : ConnectivityResult.none;
    _isOnline = initialResult != ConnectivityResult.none;
  }

  /// Load cache metrics from storage
  Future<void> _loadCacheMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getString('cache_metrics');
      if (metricsJson != null) {
        final metricsMap = jsonDecode(metricsJson) as Map<String, dynamic>;
        for (final entry in metricsMap.entries) {
          _cacheMetrics[entry.key] =
              CacheMetrics.fromJson(entry.value as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Load cache metrics error: $e');
    }
  }

  /// Save cache metrics to storage
  Future<void> _saveCacheMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsMap = <String, dynamic>{};
      for (final entry in _cacheMetrics.entries) {
        metricsMap[entry.key] = entry.value.toJson();
      }
      await prefs.setString('cache_metrics', jsonEncode(metricsMap));
    } catch (e) {
      debugPrint('Save cache metrics error: $e');
    }
  }

  /// Start background cleanup process
  void _startBackgroundCleanup() {
    // Run cleanup every hour
    Future.delayed(const Duration(hours: 1), () {
      _performBackgroundCleanup();
      _startBackgroundCleanup(); // Schedule next cleanup
    });
  }

  /// Perform background cleanup
  Future<void> _performBackgroundCleanup() async {
    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];

      // Clean up expired memory cache entries
      for (final key in _memoryCache.keys) {
        final entry = _memoryCache.get(key);
        if (entry != null) {
          final cacheEntry =
              CacheEntry<String>.fromJson(entry as Map<String, dynamic>);
          if (now.isAfter(cacheEntry.expiryTime)) {
            keysToRemove.add(key as String);
          }
        }
      }

      // Clean up expired disk cache entries
      for (final key in _diskCache.keys) {
        final entry = _diskCache.get(key);
        if (entry != null) {
          final cacheEntry =
              CacheEntry<String>.fromJson(entry as Map<String, dynamic>);
          if (now.isAfter(cacheEntry.expiryTime)) {
            keysToRemove.add(key as String);
          }
        }
      }

      // Remove expired entries
      for (final key in keysToRemove) {
        await _memoryCache.delete(key);
        await _diskCache.delete(key);
        await _metadataCache.delete(key);
        _lastAccess.remove(key);
      }

      // Save updated metrics
      await _saveCacheMetrics();

      if (keysToRemove.isNotEmpty) {
        await _analytics.logEvent('cache_cleanup', parameters: {
          'expired_items': keysToRemove.length,
          'memory_items': _memoryCache.length,
          'disk_items': _diskCache.length,
        });
      }
    } catch (e) {
      await _analytics.logError(
        error: 'Background cleanup failed: $e',
        context: 'advanced_cache_service',
      );
    }
  }

  /// Estimate size of cached value
  int _estimateSize<T>(final T value) {
    try {
      if (value is String) {
        return value.length * 2; // UTF-16 encoding
      } else if (value is Map || value is List) {
        return jsonEncode(value).length * 2;
      } else {
        return 100; // Default estimate
      }
    } catch (e) {
      return 100; // Default estimate
    }
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isOnline => _isOnline;
  int get memoryCacheSize => _memoryCache.length;
  int get diskCacheSize => _diskCache.length;
}

/// Cache entry model
class CacheEntry<T> {

  CacheEntry({
    required this.value,
    required this.expiryTime,
    required this.priority,
    required this.createdAt,
    this.accessCount = 0,
  });

  factory CacheEntry.fromJson(final Map<String, dynamic> json) {
    try {
      return CacheEntry<T>(
        value: json['value'] as T,
        expiryTime: DateTime.parse(json['expiryTime'] as String),
        priority: CachePriority.values.firstWhere(
          (final p) => p.name == json['priority'],
          orElse: () => CachePriority.normal,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        accessCount: (json['accessCount'] as int?) ?? 0,
      );
    } catch (e) {
      throw ArgumentError('Invalid cache entry data: $e');
    }
  }
  final T value;
  final DateTime expiryTime;
  final CachePriority priority;
  final DateTime createdAt;
  int accessCount;

  Map<String, dynamic> toJson() => {
        'value': value,
        'expiryTime': expiryTime.toIso8601String(),
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'accessCount': accessCount,
      };
}

/// Cache metadata model
class CacheMetadata {

  CacheMetadata({
    required this.key,
    required this.priority,
    required this.createdAt,
    required this.lastAccessed,
    required this.accessCount,
    required this.size,
  });

  factory CacheMetadata.fromJson(final Map<String, dynamic> json) {
    try {
      return CacheMetadata(
        key: json['key'] as String,
        priority: CachePriority.values.firstWhere(
          (final p) => p.name == json['priority'],
          orElse: () => CachePriority.normal,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastAccessed: DateTime.parse(json['lastAccessed'] as String),
        accessCount: json['accessCount'] as int,
        size: json['size'] as int,
      );
    } catch (e) {
      throw ArgumentError('Invalid cache metadata: $e');
    }
  }
  final String key;
  final CachePriority priority;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final int accessCount;
  final int size;

  Map<String, dynamic> toJson() => {
        'key': key,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'lastAccessed': lastAccessed.toIso8601String(),
        'accessCount': accessCount,
        'size': size,
      };
}

/// Cache metrics model
class CacheMetrics {

  CacheMetrics();

  factory CacheMetrics.fromJson(final Map<String, dynamic> json) {
    try {
      final metrics = CacheMetrics();
      metrics.memoryHits = (json['memoryHits'] as int?) ?? 0;
      metrics.diskHits = (json['diskHits'] as int?) ?? 0;
      metrics.networkHits = (json['networkHits'] as int?) ?? 0;
      metrics.misses = (json['misses'] as int?) ?? 0;
      metrics.totalResponseTime =
          Duration(microseconds: (json['totalResponseTime'] as int?) ?? 0);
      return metrics;
    } catch (e) {
      throw ArgumentError('Invalid cache metrics data: $e');
    }
  }
  int memoryHits = 0;
  int diskHits = 0;
  int networkHits = 0;
  int misses = 0;
  Duration totalResponseTime = Duration.zero;

  int get hits => memoryHits + diskHits + networkHits;
  int get totalRequests => hits + misses;
  double get hitRate => totalRequests > 0 ? (hits / totalRequests) * 100 : 0.0;
  Duration get averageResponseTime => totalRequests > 0
      ? Duration(
          microseconds: totalResponseTime.inMicroseconds ~/ totalRequests)
      : Duration.zero;

  Map<String, dynamic> toJson() => {
        'memoryHits': memoryHits,
        'diskHits': diskHits,
        'networkHits': networkHits,
        'misses': misses,
        'totalResponseTime': totalResponseTime.inMicroseconds,
      };
}

/// Cache statistics model
class CacheStatistics {

  CacheStatistics({
    required this.memoryItems,
    required this.diskItems,
    required this.metadataItems,
    required this.totalItems,
    required this.hitRate,
    required this.averageResponseTime,
    required this.totalRequests,
    required this.cacheMetrics,
  });
  final int memoryItems;
  final int diskItems;
  final int metadataItems;
  final int totalItems;
  final double hitRate;
  final Duration averageResponseTime;
  final int totalRequests;
  final Map<String, CacheMetrics> cacheMetrics;
}

/// Cache priority enum
enum CachePriority {
  low,
  normal,
  high,
}
