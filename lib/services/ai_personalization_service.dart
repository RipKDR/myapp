import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

/// AI-powered personalization service implementing 2025 adaptive UI trends
class AIPersonalizationService {
  factory AIPersonalizationService() => _instance;
  AIPersonalizationService._internal();
  static final AIPersonalizationService _instance =
      AIPersonalizationService._internal();

  UserProfile _userProfile = UserProfile();
  List<UserBehavior> _behaviorHistory = [];
  List<PersonalizationRule> _activeRules = [];
  Map<String, dynamic> _adaptiveSettings = {};

  /// Initialize the personalization service
  Future<void> initialize() async {
    await _loadUserProfile();
    await _loadBehaviorHistory();
    await _generatePersonalizationRules();
    await _loadAdaptiveSettings();
  }

  /// Get current user profile
  UserProfile get userProfile => _userProfile;

  /// Get adaptive settings
  Map<String, dynamic> get adaptiveSettings => _adaptiveSettings;

  /// Record user behavior
  Future<void> recordBehavior(final UserBehavior behavior) async {
    _behaviorHistory.add(behavior);

    // Keep only last 100 behaviors for performance
    if (_behaviorHistory.length > 100) {
      _behaviorHistory = _behaviorHistory.skip(100).toList();
    }

    await _saveBehaviorHistory();
    await _updatePersonalizationRules();
  }

  /// Get personalized dashboard layout
  DashboardLayout getPersonalizedDashboardLayout() {
    final preferences = _analyzeUserPreferences();

    return DashboardLayout(
      primaryWidgets: _getPrimaryWidgets(preferences),
      secondaryWidgets: _getSecondaryWidgets(preferences),
      layoutStyle: _getOptimalLayoutStyle(preferences),
      colorScheme: _getPersonalizedColorScheme(preferences),
      typography: _getPersonalizedTypography(preferences),
    );
  }

  /// Get personalized recommendations
  List<PersonalizedRecommendation> getPersonalizedRecommendations() {
    final recommendations = <PersonalizedRecommendation>[];
    final preferences = _analyzeUserPreferences();

    // Time-based recommendations
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      recommendations.add(PersonalizedRecommendation(
        title: 'Good Morning!',
        description: 'Start your day by checking your appointments',
        action: 'view_calendar',
        priority: RecommendationPriority.high,
        confidence: 0.9,
        reasoning: 'Based on your morning routine patterns',
      ));
    } else if (hour >= 18 && hour < 22) {
      recommendations.add(PersonalizedRecommendation(
        title: 'Evening Budget Check',
        description: 'Review today\'s spending and plan for tomorrow',
        action: 'view_budget',
        priority: RecommendationPriority.medium,
        confidence: 0.8,
        reasoning: 'Based on your evening activity patterns',
      ));
    }

    // Usage pattern recommendations
    if (preferences.frequentlyUsedFeatures.contains('budget')) {
      if (!preferences.recentlyUsedFeatures.contains('budget')) {
        recommendations.add(PersonalizedRecommendation(
          title: 'Budget Update Reminder',
          description: 'You haven\'t updated your budget in a while',
          action: 'update_budget',
          priority: RecommendationPriority.medium,
          confidence: 0.7,
          reasoning: 'Based on your budget tracking frequency',
        ));
      }
    }

    // Goal-based recommendations
    if (preferences.currentGoals.isNotEmpty) {
      final primaryGoal = preferences.currentGoals.first;
      recommendations.add(PersonalizedRecommendation(
        title: 'Progress on ${primaryGoal.name}',
        description:
            'You\'re ${(primaryGoal.progress * 100).toInt()}% complete',
        action: 'view_goal_progress',
        priority: RecommendationPriority.high,
        confidence: 0.95,
        reasoning: 'Based on your active goals',
      ));
    }

    // Accessibility recommendations
    if (preferences.accessibilityNeeds.isNotEmpty) {
      if (preferences.accessibilityNeeds.contains('high_contrast') &&
          !(_adaptiveSettings['high_contrast_enabled'] as bool? ?? false)) {
        recommendations.add(PersonalizedRecommendation(
          title: 'Accessibility Enhancement',
          description: 'Enable high contrast mode for better visibility',
          action: 'enable_high_contrast',
          priority: RecommendationPriority.high,
          confidence: 0.9,
          reasoning: 'Based on your accessibility preferences',
        ));
      }
    }

    return recommendations;
  }

  /// Get adaptive interface settings
  AdaptiveInterfaceSettings getAdaptiveInterfaceSettings() {
    final preferences = _analyzeUserPreferences();

    return AdaptiveInterfaceSettings(
      textSize: _calculateOptimalTextSize(preferences),
      buttonSize: _calculateOptimalButtonSize(preferences),
      spacing: _calculateOptimalSpacing(preferences),
      animationSpeed: _calculateOptimalAnimationSpeed(preferences),
      colorContrast: _calculateOptimalColorContrast(preferences),
      layoutDensity: _calculateOptimalLayoutDensity(preferences),
    );
  }

  /// Get personalized content
  PersonalizedContent getPersonalizedContent(final String contentType) {
    final preferences = _analyzeUserPreferences();

    switch (contentType) {
      case 'welcome_message':
        return _getPersonalizedWelcomeMessage(preferences);
      case 'tips':
        return _getPersonalizedTips(preferences);
      case 'notifications':
        return _getPersonalizedNotifications(preferences);
      default:
        return PersonalizedContent(
          title: 'Default Content',
          content: 'This is default content',
          style: ContentStyle.neutral,
        );
    }
  }

  /// Update user preferences based on behavior
  Future<void> updatePreferencesFromBehavior() async {
    final preferences = _analyzeUserPreferences();

    // Update user profile based on behavior patterns
    _userProfile.preferredFeatures = preferences.frequentlyUsedFeatures;
    _userProfile.accessibilityNeeds = preferences.accessibilityNeeds;
    _userProfile.usagePatterns = preferences.usagePatterns;

    await _saveUserProfile();
  }

  // Private methods

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _userProfile =
          UserProfile.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
    } else {
      _userProfile = UserProfile();
    }
  }

  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_userProfile.toJson()));
  }

  Future<void> _loadBehaviorHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('behavior_history');
    if (historyJson != null) {
      final List<dynamic> historyList =
          jsonDecode(historyJson) as List<dynamic>;
      _behaviorHistory = historyList
          .map((final json) => UserBehavior.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveBehaviorHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        jsonEncode(_behaviorHistory.map((final b) => b.toJson()).toList());
    await prefs.setString('behavior_history', historyJson);
  }

  Future<void> _loadAdaptiveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('adaptive_settings');
    if (settingsJson != null) {
      _adaptiveSettings = jsonDecode(settingsJson) as Map<String, dynamic>;
    } else {
      _adaptiveSettings = {};
    }
  }

  Future<void> _saveAdaptiveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adaptive_settings', jsonEncode(_adaptiveSettings));
  }

  Future<void> _generatePersonalizationRules() async {
    _activeRules = [
      PersonalizationRule(
        id: 'frequent_budget_user',
        condition: (final preferences) =>
            preferences.frequentlyUsedFeatures.contains('budget'),
        action: (final settings) => settings['budget_priority'] = 'high',
        confidence: 0.8,
      ),
      PersonalizationRule(
        id: 'morning_user',
        condition: (final preferences) => preferences.peakUsageHours.contains(8),
        action: (final settings) => settings['morning_optimization'] = true,
        confidence: 0.7,
      ),
      PersonalizationRule(
        id: 'accessibility_needs',
        condition: (final preferences) => preferences.accessibilityNeeds.isNotEmpty,
        action: (final settings) => settings['accessibility_enhanced'] = true,
        confidence: 0.9,
      ),
    ];
  }

  Future<void> _updatePersonalizationRules() async {
    final preferences = _analyzeUserPreferences();

    for (final rule in _activeRules) {
      if (rule.condition(preferences)) {
        rule.action(_adaptiveSettings);
      }
    }

    await _saveAdaptiveSettings();
  }

  UserPreferences _analyzeUserPreferences() {
    final now = DateTime.now();
    final recentBehaviors = _behaviorHistory
        .where(
          (final b) => now.difference(b.timestamp).inDays <= 30,
        )
        .toList();

    // Analyze feature usage
    final featureUsage = <String, int>{};
    for (final behavior in recentBehaviors) {
      if (behavior.action.startsWith('navigate_')) {
        final feature = behavior.action.replaceFirst('navigate_', '');
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }
    }

    final frequentlyUsedFeatures = featureUsage.entries
        .where((final e) => e.value >= 5)
        .map((final e) => e.key)
        .toList();

    // Analyze usage patterns
    final usageHours = recentBehaviors.map((final b) => b.timestamp.hour).toList();

    final peakUsageHours = <int>{};
    for (int hour = 0; hour < 24; hour++) {
      final count = usageHours.where((final h) => h == hour).length;
      if (count >= usageHours.length * 0.1) {
        // 10% threshold
        peakUsageHours.add(hour);
      }
    }

    // Analyze accessibility needs
    final accessibilityNeeds = <String>[];
    if (_userProfile.textSizePreference > 1.2) {
      accessibilityNeeds.add('large_text');
    }
    if (_userProfile.highContrastPreference) {
      accessibilityNeeds.add('high_contrast');
    }
    if (_userProfile.reduceMotionPreference) {
      accessibilityNeeds.add('reduce_motion');
    }

    return UserPreferences(
      frequentlyUsedFeatures: frequentlyUsedFeatures,
      recentlyUsedFeatures:
          recentBehaviors.take(10).map((final b) => b.action).toList(),
      peakUsageHours: peakUsageHours.toList(),
      accessibilityNeeds: accessibilityNeeds,
      usagePatterns: _analyzeUsagePatterns(recentBehaviors),
      currentGoals: _userProfile.currentGoals,
    );
  }

  List<UsagePattern> _analyzeUsagePatterns(final List<UserBehavior> behaviors) {
    final patterns = <UsagePattern>[];

    // Daily usage pattern
    final dailyUsage = <int, int>{};
    for (final behavior in behaviors) {
      final hour = behavior.timestamp.hour;
      dailyUsage[hour] = (dailyUsage[hour] ?? 0) + 1;
    }

    if (dailyUsage.isNotEmpty) {
      patterns.add(UsagePattern(
        type: 'daily_usage',
        data: dailyUsage,
        confidence: 0.8,
      ));
    }

    // Weekly usage pattern
    final weeklyUsage = <int, int>{};
    for (final behavior in behaviors) {
      final weekday = behavior.timestamp.weekday;
      weeklyUsage[weekday] = (weeklyUsage[weekday] ?? 0) + 1;
    }

    if (weeklyUsage.isNotEmpty) {
      patterns.add(UsagePattern(
        type: 'weekly_usage',
        data: weeklyUsage,
        confidence: 0.7,
      ));
    }

    return patterns;
  }

  List<String> _getPrimaryWidgets(final UserPreferences preferences) {
    final widgets = <String>[];

    // Add most frequently used features
    for (final feature in preferences.frequentlyUsedFeatures.take(3)) {
      widgets.add(feature);
    }

    // Add default widgets if not enough frequent features
    if (widgets.length < 3) {
      final defaultWidgets = ['dashboard', 'calendar', 'budget'];
      for (final widget in defaultWidgets) {
        if (!widgets.contains(widget)) {
          widgets.add(widget);
        }
        if (widgets.length >= 3) break;
      }
    }

    return widgets;
  }

  List<String> _getSecondaryWidgets(final UserPreferences preferences) {
    final widgets = <String>[];

    // Add less frequently used features
    for (final feature in preferences.frequentlyUsedFeatures.skip(3)) {
      widgets.add(feature);
    }

    // Add remaining default widgets
    final defaultWidgets = ['chat', 'settings', 'privacy'];
    for (final widget in defaultWidgets) {
      if (!widgets.contains(widget) &&
          !preferences.frequentlyUsedFeatures.contains(widget)) {
        widgets.add(widget);
      }
    }

    return widgets;
  }

  LayoutStyle _getOptimalLayoutStyle(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('large_text')) {
      return LayoutStyle.spacious;
    } else if (preferences.frequentlyUsedFeatures.length > 5) {
      return LayoutStyle.compact;
    } else {
      return LayoutStyle.balanced;
    }
  }

  ColorScheme _getPersonalizedColorScheme(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('high_contrast')) {
      return ColorScheme.highContrast;
    } else if (preferences.peakUsageHours.contains(18) ||
        preferences.peakUsageHours.contains(19)) {
      return ColorScheme.dark;
    } else {
      return ColorScheme.light;
    }
  }

  Typography _getPersonalizedTypography(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('large_text')) {
      return Typography.large;
    } else if (preferences.accessibilityNeeds.contains('dyslexia_friendly')) {
      return Typography.dyslexiaFriendly;
    } else {
      return Typography.standard;
    }
  }

  double _calculateOptimalTextSize(final UserPreferences preferences) {
    double baseSize = 1;

    if (preferences.accessibilityNeeds.contains('large_text')) {
      baseSize = 1.3;
    } else if (_userProfile.textSizePreference > 1.0) {
      baseSize = _userProfile.textSizePreference;
    }

    return baseSize.clamp(0.8, 2.0);
  }

  double _calculateOptimalButtonSize(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('large_text')) {
      return 1.2;
    } else if (preferences.accessibilityNeeds.contains('motor_difficulties')) {
      return 1.3;
    } else {
      return 1;
    }
  }

  double _calculateOptimalSpacing(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('large_text')) {
      return 1.2;
    } else if (_userProfile.layoutDensityPreference == 'spacious') {
      return 1.3;
    } else if (_userProfile.layoutDensityPreference == 'compact') {
      return 0.8;
    } else {
      return 1;
    }
  }

  double _calculateOptimalAnimationSpeed(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('reduce_motion')) {
      return 0; // No animations
    } else if (preferences.accessibilityNeeds.contains('slow_animations')) {
      return 0.5;
    } else {
      return 1;
    }
  }

  double _calculateOptimalColorContrast(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('high_contrast')) {
      return 1.5;
    } else if (preferences.accessibilityNeeds.contains('color_blindness')) {
      return 1.2;
    } else {
      return 1;
    }
  }

  String _calculateOptimalLayoutDensity(final UserPreferences preferences) {
    if (preferences.accessibilityNeeds.contains('large_text')) {
      return 'spacious';
    } else if (preferences.frequentlyUsedFeatures.length > 6) {
      return 'compact';
    } else {
      return 'balanced';
    }
  }

  PersonalizedContent _getPersonalizedWelcomeMessage(
      final UserPreferences preferences) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    String message;
    if (preferences.frequentlyUsedFeatures.contains('budget')) {
      message = 'Ready to manage your NDIS budget today?';
    } else if (preferences.frequentlyUsedFeatures.contains('calendar')) {
      message = 'Don\'t forget to check your upcoming appointments';
    } else {
      message = 'Welcome back to your NDIS journey';
    }

    return PersonalizedContent(
      title: '$greeting!',
      content: message,
      style: ContentStyle.positive,
    );
  }

  PersonalizedContent _getPersonalizedTips(final UserPreferences preferences) {
    final tips = <String>[];

    if (preferences.frequentlyUsedFeatures.contains('budget')) {
      tips.add('💡 Tip: Track your spending weekly to stay on budget');
    }

    if (preferences.frequentlyUsedFeatures.contains('calendar')) {
      tips.add('📅 Tip: Set appointment reminders 24 hours in advance');
    }

    if (preferences.accessibilityNeeds.contains('high_contrast')) {
      tips.add('♿ Tip: High contrast mode is enabled for better visibility');
    }

    final tip = tips.isNotEmpty
        ? tips[math.Random().nextInt(tips.length)]
        : '💡 Tip: Use voice commands for hands-free navigation';

    return PersonalizedContent(
      title: 'Daily Tip',
      content: tip,
      style: ContentStyle.informative,
    );
  }

  PersonalizedContent _getPersonalizedNotifications(
      final UserPreferences preferences) {
    final notifications = <String>[];

    if (preferences.frequentlyUsedFeatures.contains('budget')) {
      notifications.add('Your budget is 80% utilized this month');
    }

    if (preferences.frequentlyUsedFeatures.contains('calendar')) {
      notifications.add('You have an appointment tomorrow at 2 PM');
    }

    final notification = notifications.isNotEmpty
        ? notifications[math.Random().nextInt(notifications.length)]
        : 'You have 3 new messages in your NDIS chat';

    return PersonalizedContent(
      title: 'Notification',
      content: notification,
      style: ContentStyle.neutral,
    );
  }
}

// Data models

class UserProfile {

  UserProfile({
    this.userId = 'default_user',
    this.preferredFeatures = const [],
    this.accessibilityNeeds = const [],
    this.usagePatterns = const [],
    this.currentGoals = const [],
    this.textSizePreference = 1.0,
    this.highContrastPreference = false,
    this.reduceMotionPreference = false,
    this.layoutDensityPreference = 'balanced',
  });

  factory UserProfile.fromJson(final Map<String, dynamic> json) => UserProfile(
        userId: (json['userId'] as String?) ?? 'default_user',
        preferredFeatures: List<String>.from(
            (json['preferredFeatures'] as List<dynamic>?) ?? []),
        accessibilityNeeds: List<String>.from(
            (json['accessibilityNeeds'] as List<dynamic>?) ?? []),
        usagePatterns: (json['usagePatterns'] as List<dynamic>?)
                ?.map((final p) => UsagePattern.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        currentGoals: (json['currentGoals'] as List<dynamic>?)
                ?.map((final g) => UserGoal.fromJson(g as Map<String, dynamic>))
                .toList() ??
            [],
        textSizePreference: (json['textSizePreference'] as double?) ?? 1.0,
        highContrastPreference:
            (json['highContrastPreference'] as bool?) ?? false,
        reduceMotionPreference:
            (json['reduceMotionPreference'] as bool?) ?? false,
        layoutDensityPreference:
            (json['layoutDensityPreference'] as String?) ?? 'balanced',
      );
  String userId;
  List<String> preferredFeatures;
  List<String> accessibilityNeeds;
  List<UsagePattern> usagePatterns;
  List<UserGoal> currentGoals;
  double textSizePreference;
  bool highContrastPreference;
  bool reduceMotionPreference;
  String layoutDensityPreference;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'preferredFeatures': preferredFeatures,
        'accessibilityNeeds': accessibilityNeeds,
        'usagePatterns': usagePatterns.map((final p) => p.toJson()).toList(),
        'currentGoals': currentGoals.map((final g) => g.toJson()).toList(),
        'textSizePreference': textSizePreference,
        'highContrastPreference': highContrastPreference,
        'reduceMotionPreference': reduceMotionPreference,
        'layoutDensityPreference': layoutDensityPreference,
      };
}

class UserBehavior {

  UserBehavior({
    required this.action,
    required this.timestamp,
    this.context = const {},
  });

  factory UserBehavior.fromJson(final Map<String, dynamic> json) => UserBehavior(
        action: json['action'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        context: Map<String, dynamic>.from(
            (json['context'] as Map<dynamic, dynamic>?) ?? {}),
      );
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  Map<String, dynamic> toJson() => {
        'action': action,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };
}

class UserPreferences {

  UserPreferences({
    required this.frequentlyUsedFeatures,
    required this.recentlyUsedFeatures,
    required this.peakUsageHours,
    required this.accessibilityNeeds,
    required this.usagePatterns,
    required this.currentGoals,
  });
  final List<String> frequentlyUsedFeatures;
  final List<String> recentlyUsedFeatures;
  final List<int> peakUsageHours;
  final List<String> accessibilityNeeds;
  final List<UsagePattern> usagePatterns;
  final List<UserGoal> currentGoals;
}

class UsagePattern {

  UsagePattern({
    required this.type,
    required this.data,
    required this.confidence,
  });

  factory UsagePattern.fromJson(final Map<String, dynamic> json) => UsagePattern(
        type: json['type'] as String,
        data: Map<int, int>.from(json['data'] as Map<dynamic, dynamic>),
        confidence: json['confidence'] as double,
      );
  final String type;
  final Map<int, int> data;
  final double confidence;

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'confidence': confidence,
      };
}

class UserGoal {

  UserGoal({
    required this.id,
    required this.name,
    required this.progress,
    required this.targetDate,
  });

  factory UserGoal.fromJson(final Map<String, dynamic> json) => UserGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        progress: json['progress'] as double,
        targetDate: DateTime.parse(json['targetDate'] as String),
      );
  final String id;
  final String name;
  final double progress;
  final DateTime targetDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'progress': progress,
        'targetDate': targetDate.toIso8601String(),
      };
}

class PersonalizationRule {

  PersonalizationRule({
    required this.id,
    required this.condition,
    required this.action,
    required this.confidence,
  });
  final String id;
  final bool Function(UserPreferences) condition;
  final void Function(Map<String, dynamic>) action;
  final double confidence;
}

class DashboardLayout {

  DashboardLayout({
    required this.primaryWidgets,
    required this.secondaryWidgets,
    required this.layoutStyle,
    required this.colorScheme,
    required this.typography,
  });
  final List<String> primaryWidgets;
  final List<String> secondaryWidgets;
  final LayoutStyle layoutStyle;
  final ColorScheme colorScheme;
  final Typography typography;
}

class AdaptiveInterfaceSettings {

  AdaptiveInterfaceSettings({
    required this.textSize,
    required this.buttonSize,
    required this.spacing,
    required this.animationSpeed,
    required this.colorContrast,
    required this.layoutDensity,
  });
  final double textSize;
  final double buttonSize;
  final double spacing;
  final double animationSpeed;
  final double colorContrast;
  final String layoutDensity;
}

class PersonalizedRecommendation {

  PersonalizedRecommendation({
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
    required this.confidence,
    required this.reasoning,
  });
  final String title;
  final String description;
  final String action;
  final RecommendationPriority priority;
  final double confidence;
  final String reasoning;
}

class PersonalizedContent {

  PersonalizedContent({
    required this.title,
    required this.content,
    required this.style,
  });
  final String title;
  final String content;
  final ContentStyle style;
}

enum LayoutStyle { compact, balanced, spacious }

enum ColorScheme { light, dark, highContrast }

enum Typography { standard, large, dyslexiaFriendly }

enum RecommendationPriority { low, medium, high }

enum ContentStyle { positive, neutral, informative, warning }
