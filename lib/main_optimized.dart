import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

import 'controllers/settings_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/gamification_controller.dart';
import 'services/firebase_service.dart';
import 'services/purchase_service.dart';
import 'services/error_service.dart';
import 'services/advanced_analytics_service.dart';
import 'services/advanced_cache_service.dart';
import 'services/ai_chat_service.dart';
import 'services/performance_optimization_service.dart';
import 'services/advanced_security_service.dart';
import 'services/advanced_voice_service.dart';
import 'services/integration_service.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen immediately for better perceived performance
  runApp(const SplashScreen());

  // Initialize critical services first
  await _initializeCriticalServices();

  // Initialize advanced services in background
  unawaited(_initializeAdvancedServices());

  // Navigate to main app
  runApp(const NDISConnectApp());
}

/// Initialize only critical services that are needed for app startup
Future<void> _initializeCriticalServices() async {
  try {
    // Initialize Hive for caching (critical for app functionality)
    await Hive.initFlutter();

    // Initialize error service first (critical for error handling)
    await ErrorService.initialize();

    // Initialize Firebase (critical for app functionality)
    await FirebaseService.tryInitialize();

    // Initialize purchase service (critical for monetization)
    await PurchaseService.initialize();
  } catch (e) {
    // Log error but don't block app startup
    debugPrint('Critical service initialization failed: $e');
  }
}

/// Initialize advanced services in background (non-blocking)
Future<void> _initializeAdvancedServices() async {
  try {
    // Initialize advanced services asynchronously
    final futures = [
      AdvancedAnalyticsService().initialize(),
      AdvancedCacheService().initialize(),
      AIChatService().initialize(),
      PerformanceOptimizationService().initialize(),
      AdvancedSecurityService().initialize(),
      AdvancedVoiceService().initialize(),
      IntegrationService().initialize(),
    ];

    // Wait for all advanced services to initialize
    await Future.wait(futures);

    debugPrint('All advanced services initialized successfully');
  } catch (e) {
    // Log error but don't affect app functionality
    debugPrint('Advanced service initialization failed: $e');
  }
}

/// Splash screen shown during app initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF4F46E5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.accessible_forward,
                  size: 60,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 24),

              // App name
              const Text(
                'NDIS Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Your Accessible NDIS Companion',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
}

class NDISConnectApp extends StatelessWidget {
  const NDISConnectApp({super.key});

  @override
  Widget build(final BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()..load()),
        ChangeNotifierProvider(create: (_) => AuthController()..load()),
        ChangeNotifierProvider(create: (_) => GamificationController()..load()),
      ],
      child: const _NDISConnectAppContent(),
    );
}

class _NDISConnectAppContent extends StatelessWidget {
  const _NDISConnectAppContent();

  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NDIS Connect',
      theme: AppTheme.lightTheme(highContrast: settings.highContrast),
      darkTheme: AppTheme.darkTheme(highContrast: settings.highContrast),
      themeMode: settings.themeMode,
      builder: (final context, final child) {
        // Apply user-selected text scale and reduced motion globally.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.textScale),
            boldText: settings.highContrast,
            accessibleNavigation: settings.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: Routes.bootstrap,
      routes: Routes.routes,
    );
  }
}

/// Performance monitoring utilities
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _metrics = {};

  /// Start timing an operation
  static void startTimer(final String operation) {
    _startTimes[operation] = DateTime.now();
  }

  /// End timing an operation
  static void endTimer(final String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _metrics.putIfAbsent(operation, () => []).add(duration);
      _startTimes.remove(operation);

      // Log performance metrics
      debugPrint('Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  /// Get average time for an operation
  static Duration? getAverageTime(final String operation) {
    final times = _metrics[operation];
    if (times == null || times.isEmpty) return null;

    final total = times.fold<Duration>(
      Duration.zero,
      (final sum, final time) => sum + time,
    );

    return Duration(
      microseconds: total.inMicroseconds ~/ times.length,
    );
  }

  /// Get all performance metrics
  static Map<String, Duration> getAllMetrics() {
    final averages = <String, Duration>{};
    _metrics.forEach((final operation, final times) {
      final average = getAverageTime(operation);
      if (average != null) {
        averages[operation] = average;
      }
    });
    return averages;
  }
}

/// Optimized service base class
abstract class OptimizedService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, Future<dynamic>> _pendingOperations = {};

  /// Get cached data
  static T? getCached<T>(final String key) => _cache[key] as T?;

  /// Set cached data
  static void setCached<T>(final String key, final T data) {
    _cache[key] = data;
  }

  /// Execute operation with deduplication
  static Future<T> executeWithDeduplication<T>(
    final String key,
    final Future<T> Function() operation,
  ) async {
    // Check if operation is already pending
    if (_pendingOperations.containsKey(key)) {
      return await _pendingOperations[key] as T;
    }

    // Execute operation
    final future = operation();
    _pendingOperations[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _pendingOperations.remove(key);
    }
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
  }

  /// Clear pending operations
  static void clearPendingOperations() {
    _pendingOperations.clear();
  }
}
