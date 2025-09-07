import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Advanced Analytics Service with comprehensive data visualization,
/// predictive analytics, and business intelligence capabilities
class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance =
      AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;
  final Map<String, dynamic> _userMetrics = {};
  final Map<String, dynamic> _appMetrics = {};
  final List<AnalyticsEvent> _eventBuffer = [];

  // Performance tracking
  final Map<String, DateTime> _performanceTimers = {};
  final Map<String, List<int>> _performanceMetrics = {};

  /// Initialize the advanced analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _analytics.initialize();
      await _loadUserMetrics();
      await _loadAppMetrics();
      await _initializePerformanceTracking();

      _isInitialized = true;

      await _analytics.logEvent('advanced_analytics_initialized');
    } catch (e) {
      await _analytics.logError(
        error: 'Advanced analytics initialization failed: $e',
        context: 'advanced_analytics_service',
      );
      rethrow;
    }
  }

  /// Track user engagement with detailed metrics
  Future<void> trackUserEngagement({
    required String feature,
    required String action,
    required int duration,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) await initialize();

    final params = <String, Object>{
      'feature': feature,
      'action': action,
      'duration': duration,
      'session_id': _generateSessionId(),
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
      if (additionalData != null) 'context': additionalData,
    };
    final event = AnalyticsEvent(
      name: 'user_engagement',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateUserMetrics(feature, action, duration);
  }

  /// Track feature usage with conversion funnel analysis
  Future<void> trackFeatureUsage({
    required String feature,
    required String action,
    required String stage, // discovery, engagement, conversion, retention
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) await initialize();

    final params = <String, Object>{
      'feature': feature,
      'action': action,
      'stage': stage,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
      if (context != null) 'context': context,
    };
    final event = AnalyticsEvent(
      name: 'feature_usage',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateConversionFunnel(feature, stage);
  }

  /// Track accessibility feature usage
  Future<void> trackAccessibilityUsage({
    required String feature,
    required bool enabled,
    required String userType, // participant, provider, caregiver
    Map<String, dynamic>? accessibilityNeeds,
  }) async {
    if (!_isInitialized) await initialize();

    final params = <String, Object>{
      'feature': feature,
      'enabled': enabled,
      'user_type': userType,
      if (accessibilityNeeds != null) 'accessibility_needs': accessibilityNeeds,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
    };
    final event = AnalyticsEvent(
      name: 'accessibility_usage',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateAccessibilityMetrics(feature, enabled, userType);
  }

  /// Track budget analytics and spending patterns
  Future<void> trackBudgetAnalytics({
    required String category,
    required double amount,
    required double remaining,
    required String action, // view, spend, alert, plan
    Map<String, dynamic>? budgetContext,
  }) async {
    if (!_isInitialized) await initialize();

    final percentageUsed = ((amount - remaining) / amount * 100).round();
    final isOverBudget = remaining < 0;
    final isNearLimit = percentageUsed >= 80;

    final params = <String, Object>{
      'category': category,
      'amount': amount,
      'remaining': remaining,
      'percentage_used': percentageUsed,
      'action': action,
      'is_over_budget': isOverBudget,
      'is_near_limit': isNearLimit,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
      if (budgetContext != null) 'context': budgetContext,
    };
    final event = AnalyticsEvent(
      name: 'budget_analytics',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateBudgetMetrics(category, amount, remaining, action);
  }

  /// Track appointment analytics and scheduling patterns
  Future<void> trackAppointmentAnalytics({
    required String providerId,
    required String appointmentType,
    required DateTime appointmentDate,
    required String action, // book, cancel, reschedule, complete
    Map<String, dynamic>? appointmentContext,
  }) async {
    if (!_isInitialized) await initialize();

    final daysUntilAppointment =
        appointmentDate.difference(DateTime.now()).inDays;
    final isUpcoming = daysUntilAppointment >= 0;
    final isOverdue = daysUntilAppointment < 0;

    final params = <String, Object>{
      'provider_id': providerId,
      'appointment_type': appointmentType,
      'appointment_date': appointmentDate.toIso8601String(),
      'action': action,
      'days_until_appointment': daysUntilAppointment,
      'is_upcoming': isUpcoming,
      'is_overdue': isOverdue,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
      if (appointmentContext != null) 'context': appointmentContext,
    };
    final event = AnalyticsEvent(
      name: 'appointment_analytics',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateAppointmentMetrics(providerId, appointmentType, action);
  }

  /// Track provider directory usage and search patterns
  Future<void> trackProviderAnalytics({
    required String searchTerm,
    required String location,
    required int resultCount,
    required String action, // search, view, contact, book
    Map<String, dynamic>? searchFilters,
  }) async {
    if (!_isInitialized) await initialize();

    final params = <String, Object>{
      'search_term': searchTerm,
      'location': location,
      'result_count': resultCount,
      'action': action,
      if (searchFilters != null) 'search_filters': searchFilters,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
    };
    final event = AnalyticsEvent(
      name: 'provider_analytics',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateProviderMetrics(searchTerm, location, resultCount, action);
  }

  /// Track support circle interactions and collaboration metrics
  Future<void> trackSupportCircleAnalytics({
    required String circleId,
    required String action,
    required int memberCount,
    required String userRole,
    Map<String, dynamic>? collaborationData,
  }) async {
    if (!_isInitialized) await initialize();

    final params = <String, Object>{
      'circle_id': circleId,
      'action': action,
      'member_count': memberCount,
      'user_role': userRole,
      if (collaborationData != null) 'collaboration_data': collaborationData,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
    };
    final event = AnalyticsEvent(
      name: 'support_circle_analytics',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
    await _updateSupportCircleMetrics(circleId, action, memberCount);
  }

  /// Start performance timing for a specific operation
  void startPerformanceTimer(String operation) {
    _performanceTimers[operation] = DateTime.now();
  }

  /// End performance timing and record metrics
  Future<void> endPerformanceTimer(String operation) async {
    if (!_isInitialized) await initialize();

    final startTime = _performanceTimers[operation];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    // Record performance metric
    await _recordPerformanceMetric(operation, duration);

    // Update performance tracking
    _performanceMetrics.putIfAbsent(operation, () => []).add(duration);

    // Clean up timer
    _performanceTimers.remove(operation);

    // Log if performance is poor
    if (duration > 1000) {
      // More than 1 second
      await _analytics.logError(
        error: 'Performance issue: $operation took ${duration}ms',
        context: 'performance_tracking',
      );
    }
  }

  /// Record performance metric
  Future<void> _recordPerformanceMetric(String operation, int duration) async {
    final params = <String, Object>{
      'operation': operation,
      'duration': duration,
      'platform': defaultTargetPlatform.name,
      if (_auth.currentUser?.uid != null) 'user_id': _auth.currentUser!.uid,
    };
    final event = AnalyticsEvent(
      name: 'performance_metric',
      timestamp: DateTime.now(),
      parameters: params,
    );

    await _recordEvent(event);
  }

  /// Get comprehensive user analytics dashboard data
  Future<AnalyticsDashboard> getUserAnalyticsDashboard() async {
    if (!_isInitialized) await initialize();

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Gather data from multiple sources
    final userMetrics = await _getUserMetrics(userId);
    final budgetAnalytics = await _getBudgetAnalytics(userId);
    final appointmentAnalytics = await _getAppointmentAnalytics(userId);
    final providerAnalytics = await _getProviderAnalytics(userId);
    final supportCircleAnalytics = await _getSupportCircleAnalytics(userId);
    final performanceMetrics = await _getPerformanceMetrics();

    return AnalyticsDashboard(
      userMetrics: userMetrics,
      budgetAnalytics: budgetAnalytics,
      appointmentAnalytics: appointmentAnalytics,
      providerAnalytics: providerAnalytics,
      supportCircleAnalytics: supportCircleAnalytics,
      performanceMetrics: performanceMetrics,
      generatedAt: DateTime.now(),
    );
  }

  /// Get predictive analytics for budget forecasting
  Future<BudgetForecast> getBudgetForecast() async {
    if (!_isInitialized) await initialize();

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Get historical spending data
    final spendingHistory = await _getSpendingHistory(userId);

    // Calculate spending trends
    final trends = _calculateSpendingTrends(spendingHistory);

    // Predict future spending
    final forecast = _predictFutureSpending(trends);

    // Generate recommendations
    final recommendations =
        _generateBudgetRecommendationsFromForecast(forecast);

    return BudgetForecast(
      currentSpending: trends.currentSpending,
      projectedSpending: forecast.projectedSpending,
      budgetExhaustionDate: forecast.budgetExhaustionDate,
      recommendations: recommendations,
      confidence: forecast.confidence,
      generatedAt: DateTime.now(),
    );
  }

  /// Get user behavior insights
  Future<UserBehaviorInsights> getUserBehaviorInsights() async {
    if (!_isInitialized) await initialize();

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Analyze user patterns
    final usagePatterns = await _analyzeUsagePatterns(userId);
    final engagementMetrics = await _analyzeEngagementMetrics(userId);
    final accessibilityUsage = await _analyzeAccessibilityUsage(userId);
    final featureAdoption = await _analyzeFeatureAdoption(userId);

    return UserBehaviorInsights(
      usagePatterns: usagePatterns,
      engagementMetrics: engagementMetrics,
      accessibilityUsage: accessibilityUsage,
      featureAdoption: featureAdoption,
      generatedAt: DateTime.now(),
    );
  }

  /// Generate personalized recommendations
  Future<List<PersonalizedRecommendation>>
      getPersonalizedRecommendations() async {
    if (!_isInitialized) await initialize();

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final recommendations = <PersonalizedRecommendation>[];

    // Budget recommendations
    final budgetRecommendations =
        await _generateBudgetRecommendationsForUser(userId);
    recommendations.addAll(budgetRecommendations);

    // Service recommendations
    final serviceRecommendations =
        await _generateServiceRecommendations(userId);
    recommendations.addAll(serviceRecommendations);

    // Feature recommendations
    final featureRecommendations =
        await _generateFeatureRecommendations(userId);
    recommendations.addAll(featureRecommendations);

    // Accessibility recommendations
    final accessibilityRecommendations =
        await _generateAccessibilityRecommendations(userId);
    recommendations.addAll(accessibilityRecommendations);

    return recommendations;
  }

  /// Record analytics event
  Future<void> _recordEvent(AnalyticsEvent event) async {
    // Add to buffer
    _eventBuffer.add(event);

    // Send to Firebase Analytics
    await _analytics.logEvent(event.name, parameters: event.parameters);

    // Store in Firestore for advanced analytics
    try {
      await _firestore.collection('analytics_events').add(event.toJson());
    } catch (e) {
      debugPrint('Failed to store analytics event: $e');
    }

    // Process buffer if it gets too large
    if (_eventBuffer.length > 100) {
      await _processEventBuffer();
    }
  }

  /// Process event buffer for batch operations
  Future<void> _processEventBuffer() async {
    if (_eventBuffer.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final event in _eventBuffer) {
        final docRef = _firestore.collection('analytics_events').doc();
        batch.set(docRef, event.toJson());
      }

      await batch.commit();
      _eventBuffer.clear();
    } catch (e) {
      debugPrint('Failed to process event buffer: $e');
    }
  }

  /// Update user metrics
  Future<void> _updateUserMetrics(
      String feature, String action, int duration) async {
    final key = '${feature}_$action';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;
    _userMetrics['${key}_total_duration'] =
        (_userMetrics['${key}_total_duration'] ?? 0) + duration;

    await _saveUserMetrics();
  }

  /// Update conversion funnel metrics
  Future<void> _updateConversionFunnel(String feature, String stage) async {
    final key = 'funnel_${feature}_$stage';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;

    await _saveUserMetrics();
  }

  /// Update accessibility metrics
  Future<void> _updateAccessibilityMetrics(
      String feature, bool enabled, String userType) async {
    final key =
        'accessibility_${feature}_${userType}_${enabled ? 'enabled' : 'disabled'}';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;

    await _saveUserMetrics();
  }

  /// Update budget metrics
  Future<void> _updateBudgetMetrics(
      String category, double amount, double remaining, String action) async {
    final key = 'budget_${category}_$action';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;
    _userMetrics['${key}_amount'] =
        (_userMetrics['${key}_amount'] ?? 0.0) + amount;

    await _saveUserMetrics();
  }

  /// Update appointment metrics
  Future<void> _updateAppointmentMetrics(
      String providerId, String appointmentType, String action) async {
    final key = 'appointment_${appointmentType}_$action';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;

    await _saveUserMetrics();
  }

  /// Update provider metrics
  Future<void> _updateProviderMetrics(String searchTerm, String location,
      int resultCount, String action) async {
    final key = 'provider_$action';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;
    _userMetrics['${key}_result_count'] =
        (_userMetrics['${key}_result_count'] ?? 0) + resultCount;

    await _saveUserMetrics();
  }

  /// Update support circle metrics
  Future<void> _updateSupportCircleMetrics(
      String circleId, String action, int memberCount) async {
    final key = 'support_circle_$action';
    _userMetrics[key] = (_userMetrics[key] ?? 0) + 1;
    _userMetrics['${key}_member_count'] =
        (_userMetrics['${key}_member_count'] ?? 0) + memberCount;

    await _saveUserMetrics();
  }

  /// Load user metrics from storage
  Future<void> _loadUserMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString('user_metrics');
    if (metricsJson != null) {
      _userMetrics.addAll(Map<String, dynamic>.from(jsonDecode(metricsJson)));
    }
  }

  /// Save user metrics to storage
  Future<void> _saveUserMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_metrics', jsonEncode(_userMetrics));
  }

  /// Load app metrics from storage
  Future<void> _loadAppMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString('app_metrics');
    if (metricsJson != null) {
      _appMetrics.addAll(Map<String, dynamic>.from(jsonDecode(metricsJson)));
    }
  }

  /// Initialize performance tracking
  Future<void> _initializePerformanceTracking() async {
    // Set up performance monitoring for key operations
    startPerformanceTimer('app_startup');
  }

  /// Generate session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'session_${timestamp}_$random';
  }

  /// Get user metrics from Firestore
  Future<Map<String, dynamic>> _getUserMetrics(String userId) async {
    // Implementation would query Firestore for user-specific metrics
    return _userMetrics;
  }

  /// Get budget analytics from Firestore
  Future<BudgetAnalytics> _getBudgetAnalytics(String userId) async {
    // Implementation would query Firestore for budget analytics
    return BudgetAnalytics(
      totalSpent: 0.0,
      totalRemaining: 0.0,
      categoryBreakdown: {},
      spendingTrends: [],
      alerts: [],
    );
  }

  /// Get appointment analytics from Firestore
  Future<AppointmentAnalytics> _getAppointmentAnalytics(String userId) async {
    // Implementation would query Firestore for appointment analytics
    return AppointmentAnalytics(
      totalAppointments: 0,
      upcomingAppointments: 0,
      completedAppointments: 0,
      cancelledAppointments: 0,
      averageBookingTime: 0,
      providerBreakdown: {},
    );
  }

  /// Get provider analytics from Firestore
  Future<ProviderAnalytics> _getProviderAnalytics(String userId) async {
    // Implementation would query Firestore for provider analytics
    return ProviderAnalytics(
      totalSearches: 0,
      averageResults: 0,
      topSearchTerms: [],
      locationBreakdown: {},
      serviceTypeBreakdown: {},
    );
  }

  /// Get support circle analytics from Firestore
  Future<SupportCircleAnalytics> _getSupportCircleAnalytics(
      String userId) async {
    // Implementation would query Firestore for support circle analytics
    return SupportCircleAnalytics(
      totalCircles: 0,
      activeMembers: 0,
      collaborationEvents: 0,
      averageResponseTime: 0,
      memberBreakdown: {},
    );
  }

  /// Get performance metrics
  Future<PerformanceMetrics> _getPerformanceMetrics() async {
    final metrics = <String, double>{};

    for (final entry in _performanceMetrics.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        metrics[entry.key] =
            durations.reduce((a, b) => a + b) / durations.length;
      }
    }

    return PerformanceMetrics(
      averageResponseTimes: metrics,
      slowestOperations: _getSlowestOperations(),
      performanceTrends: _getPerformanceTrends(),
    );
  }

  /// Get spending history for forecasting
  Future<List<SpendingRecord>> _getSpendingHistory(String userId) async {
    // Implementation would query Firestore for spending history
    return [];
  }

  /// Calculate spending trends
  SpendingTrends _calculateSpendingTrends(List<SpendingRecord> history) {
    // Implementation would calculate spending trends from history
    return SpendingTrends(
      currentSpending: 0.0,
      monthlyAverage: 0.0,
      trendDirection: 'stable',
      volatility: 0.0,
    );
  }

  /// Predict future spending
  SpendingForecast _predictFutureSpending(SpendingTrends trends) {
    // Implementation would use ML algorithms to predict future spending
    return SpendingForecast(
      projectedSpending: 0.0,
      budgetExhaustionDate: DateTime.now().add(const Duration(days: 30)),
      confidence: 0.8,
    );
  }

  /// Generate budget recommendations
  List<PersonalizedRecommendation> _generateBudgetRecommendationsFromForecast(
      SpendingForecast forecast) {
    // Implementation would generate personalized budget recommendations
    return [];
  }

  /// Analyze usage patterns
  Future<UsagePatterns> _analyzeUsagePatterns(String userId) async {
    // Implementation would analyze user usage patterns
    return UsagePatterns(
      peakUsageHours: [],
      mostUsedFeatures: [],
      sessionDuration: 0,
      frequency: 0,
    );
  }

  /// Analyze engagement metrics
  Future<EngagementMetrics> _analyzeEngagementMetrics(String userId) async {
    // Implementation would analyze user engagement metrics
    return EngagementMetrics(
      dailyActiveMinutes: 0,
      weeklyRetention: 0.0,
      featureAdoptionRate: 0.0,
      userSatisfactionScore: 0.0,
    );
  }

  /// Analyze accessibility usage
  Future<AccessibilityUsage> _analyzeAccessibilityUsage(String userId) async {
    // Implementation would analyze accessibility feature usage
    return AccessibilityUsage(
      enabledFeatures: [],
      usageFrequency: {},
      effectiveness: 0.0,
      recommendations: [],
    );
  }

  /// Analyze feature adoption
  Future<FeatureAdoption> _analyzeFeatureAdoption(String userId) async {
    // Implementation would analyze feature adoption patterns
    return FeatureAdoption(
      adoptedFeatures: [],
      pendingFeatures: [],
      adoptionRate: 0.0,
      timeToAdoption: {},
    );
  }

  /// Generate budget recommendations for user
  Future<List<PersonalizedRecommendation>>
      _generateBudgetRecommendationsForUser(String userId) async {
    // Implementation would generate budget-specific recommendations
    return [];
  }

  /// Generate service recommendations for user
  Future<List<PersonalizedRecommendation>> _generateServiceRecommendations(
      String userId) async {
    // Implementation would generate service recommendations
    return [];
  }

  /// Generate feature recommendations for user
  Future<List<PersonalizedRecommendation>> _generateFeatureRecommendations(
      String userId) async {
    // Implementation would generate feature recommendations
    return [];
  }

  /// Generate accessibility recommendations for user
  Future<List<PersonalizedRecommendation>>
      _generateAccessibilityRecommendations(String userId) async {
    // Implementation would generate accessibility recommendations
    return [];
  }

  /// Get slowest operations
  List<String> _getSlowestOperations() {
    final sortedMetrics = _performanceMetrics.entries.toList()
      ..sort((a, b) => b.value
          .reduce((x, y) => x + y)
          .compareTo(a.value.reduce((x, y) => x + y)));

    return sortedMetrics.take(5).map((e) => e.key).toList();
  }

  /// Get performance trends
  Map<String, List<double>> _getPerformanceTrends() {
    // Implementation would calculate performance trends over time
    return {};
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  Map<String, dynamic> get userMetrics => Map.unmodifiable(_userMetrics);
  Map<String, dynamic> get appMetrics => Map.unmodifiable(_appMetrics);
}

/// Analytics event model
class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, Object> parameters;

  AnalyticsEvent({
    required this.name,
    required this.timestamp,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        'parameters': parameters,
      };
}

/// Analytics dashboard model
class AnalyticsDashboard {
  final Map<String, dynamic> userMetrics;
  final BudgetAnalytics budgetAnalytics;
  final AppointmentAnalytics appointmentAnalytics;
  final ProviderAnalytics providerAnalytics;
  final SupportCircleAnalytics supportCircleAnalytics;
  final PerformanceMetrics performanceMetrics;
  final DateTime generatedAt;

  AnalyticsDashboard({
    required this.userMetrics,
    required this.budgetAnalytics,
    required this.appointmentAnalytics,
    required this.providerAnalytics,
    required this.supportCircleAnalytics,
    required this.performanceMetrics,
    required this.generatedAt,
  });
}

/// Budget analytics model
class BudgetAnalytics {
  final double totalSpent;
  final double totalRemaining;
  final Map<String, double> categoryBreakdown;
  final List<SpendingTrend> spendingTrends;
  final List<BudgetAlert> alerts;

  BudgetAnalytics({
    required this.totalSpent,
    required this.totalRemaining,
    required this.categoryBreakdown,
    required this.spendingTrends,
    required this.alerts,
  });
}

/// Appointment analytics model
class AppointmentAnalytics {
  final int totalAppointments;
  final int upcomingAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int averageBookingTime;
  final Map<String, int> providerBreakdown;

  AppointmentAnalytics({
    required this.totalAppointments,
    required this.upcomingAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.averageBookingTime,
    required this.providerBreakdown,
  });
}

/// Provider analytics model
class ProviderAnalytics {
  final int totalSearches;
  final int averageResults;
  final List<String> topSearchTerms;
  final Map<String, int> locationBreakdown;
  final Map<String, int> serviceTypeBreakdown;

  ProviderAnalytics({
    required this.totalSearches,
    required this.averageResults,
    required this.topSearchTerms,
    required this.locationBreakdown,
    required this.serviceTypeBreakdown,
  });
}

/// Support circle analytics model
class SupportCircleAnalytics {
  final int totalCircles;
  final int activeMembers;
  final int collaborationEvents;
  final int averageResponseTime;
  final Map<String, int> memberBreakdown;

  SupportCircleAnalytics({
    required this.totalCircles,
    required this.activeMembers,
    required this.collaborationEvents,
    required this.averageResponseTime,
    required this.memberBreakdown,
  });
}

/// Performance metrics model
class PerformanceMetrics {
  final Map<String, double> averageResponseTimes;
  final List<String> slowestOperations;
  final Map<String, List<double>> performanceTrends;

  PerformanceMetrics({
    required this.averageResponseTimes,
    required this.slowestOperations,
    required this.performanceTrends,
  });
}

/// Budget forecast model
class BudgetForecast {
  final double currentSpending;
  final double projectedSpending;
  final DateTime budgetExhaustionDate;
  final List<PersonalizedRecommendation> recommendations;
  final double confidence;
  final DateTime generatedAt;

  BudgetForecast({
    required this.currentSpending,
    required this.projectedSpending,
    required this.budgetExhaustionDate,
    required this.recommendations,
    required this.confidence,
    required this.generatedAt,
  });
}

/// User behavior insights model
class UserBehaviorInsights {
  final UsagePatterns usagePatterns;
  final EngagementMetrics engagementMetrics;
  final AccessibilityUsage accessibilityUsage;
  final FeatureAdoption featureAdoption;
  final DateTime generatedAt;

  UserBehaviorInsights({
    required this.usagePatterns,
    required this.engagementMetrics,
    required this.accessibilityUsage,
    required this.featureAdoption,
    required this.generatedAt,
  });
}

/// Personalized recommendation model
class PersonalizedRecommendation {
  final String type;
  final String title;
  final String description;
  final String action;
  final double priority;
  final Map<String, dynamic> metadata;

  PersonalizedRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
    this.metadata = const {},
  });
}

/// Supporting models
class SpendingRecord {
  final DateTime date;
  final double amount;
  final String category;
  final String description;
  SpendingRecord({
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
  });
}

class SpendingTrends {
  final double currentSpending;
  final double monthlyAverage;
  final String trendDirection;
  final double volatility;
  SpendingTrends({
    required this.currentSpending,
    required this.monthlyAverage,
    required this.trendDirection,
    required this.volatility,
  });
}

class SpendingForecast {
  final double projectedSpending;
  final DateTime budgetExhaustionDate;
  final double confidence;
  SpendingForecast({
    required this.projectedSpending,
    required this.budgetExhaustionDate,
    required this.confidence,
  });
}

class SpendingTrend {
  final DateTime date;
  final double amount;
  final String category;
  SpendingTrend({
    required this.date,
    required this.amount,
    required this.category,
  });
}

class BudgetAlert {
  final String type;
  final String message;
  final DateTime timestamp;
  final double threshold;
  BudgetAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.threshold,
  });
}

class UsagePatterns {
  final List<int> peakUsageHours;
  final List<String> mostUsedFeatures;
  final int sessionDuration;
  final int frequency;
  UsagePatterns({
    required this.peakUsageHours,
    required this.mostUsedFeatures,
    required this.sessionDuration,
    required this.frequency,
  });
}

class EngagementMetrics {
  final int dailyActiveMinutes;
  final double weeklyRetention;
  final double featureAdoptionRate;
  final double userSatisfactionScore;
  EngagementMetrics({
    required this.dailyActiveMinutes,
    required this.weeklyRetention,
    required this.featureAdoptionRate,
    required this.userSatisfactionScore,
  });
}

class AccessibilityUsage {
  final List<String> enabledFeatures;
  final Map<String, int> usageFrequency;
  final double effectiveness;
  final List<String> recommendations;
  AccessibilityUsage({
    required this.enabledFeatures,
    required this.usageFrequency,
    required this.effectiveness,
    required this.recommendations,
  });
}

class FeatureAdoption {
  final List<String> adoptedFeatures;
  final List<String> pendingFeatures;
  final double adoptionRate;
  final Map<String, int> timeToAdoption;
  FeatureAdoption({
    required this.adoptedFeatures,
    required this.pendingFeatures,
    required this.adoptionRate,
    required this.timeToAdoption,
  });
}
