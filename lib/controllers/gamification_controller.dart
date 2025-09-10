import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/analytics_service.dart';
import '../services/advanced_analytics_service.dart';

/// Advanced Gamification Controller with comprehensive engagement features,
/// social elements, and behavioral psychology integration
class GamificationController extends ChangeNotifier {
  // Core gamification metrics
  int _points = 0;
  int _streakDays = 0;
  int _totalPointsEarned = 0;
  int _level = 1;
  double _experiencePoints = 0;
  
  // Badges and achievements
  Set<String> _badges = {};
  Set<String> _achievements = {};
  String? _lastBadge;
  String? _lastAchievement;
  
  // Social features
  final List<SocialChallenge> _activeChallenges = [];
  List<LeaderboardEntry> _leaderboard = [];
  Map<String, int> _socialStats = {};
  
  // Progress tracking
  Map<String, int> _categoryPoints = {};
  Map<String, int> _weeklyGoals = {};
  Map<String, int> _monthlyGoals = {};
  final Map<String, DateTime> _lastActivity = {};
  
  // Behavioral psychology elements
  final List<Habit> _habits = [];
  final List<Milestone> _milestones = [];
  final Map<String, double> _motivationFactors = {};
  
  // Rewards and incentives
  final List<Reward> _availableRewards = [];
  final List<Reward> _earnedRewards = [];
  final List<Reward> _redeemedRewards = [];
  
  final AnalyticsService _analytics = AnalyticsService();
  final AdvancedAnalyticsService _advancedAnalytics = AdvancedAnalyticsService();

  // Getters
  int get points => _points;
  int get streakDays => _streakDays;
  int get totalPointsEarned => _totalPointsEarned;
  int get level => _level;
  double get experiencePoints => _experiencePoints;
  double get experienceToNextLevel => _calculateExperienceToNextLevel();
  
  Set<String> get badges => _badges;
  Set<String> get achievements => _achievements;
  String? get lastBadge => _lastBadge;
  String? get lastAchievement => _lastAchievement;
  
  List<SocialChallenge> get activeChallenges => List.unmodifiable(_activeChallenges);
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  Map<String, int> get socialStats => Map.unmodifiable(_socialStats);
  
  Map<String, int> get categoryPoints => Map.unmodifiable(_categoryPoints);
  Map<String, int> get weeklyGoals => Map.unmodifiable(_weeklyGoals);
  Map<String, int> get monthlyGoals => Map.unmodifiable(_monthlyGoals);
  
  List<Habit> get habits => List.unmodifiable(_habits);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  Map<String, double> get motivationFactors => Map.unmodifiable(_motivationFactors);
  
  List<Reward> get availableRewards => List.unmodifiable(_availableRewards);
  List<Reward> get earnedRewards => List.unmodifiable(_earnedRewards);
  List<Reward> get redeemedRewards => List.unmodifiable(_redeemedRewards);

  /// Initialize the gamification system
  Future<void> load() async {
    await _loadFromStorage();
    await _initializeDefaultGoals();
    await _loadSocialChallenges();
    await _updateLeaderboard();
    await _evaluateAllAchievements();
    notifyListeners();
  }

  /// Add points with category tracking and advanced analytics
  Future<void> addPoints(final int value, {final String? category, final String? action, final Map<String, dynamic>? context}) async {
    _points += value;
    _totalPointsEarned += value;
    
    // Add to category if specified
    if (category != null) {
      _categoryPoints[category] = (_categoryPoints[category] ?? 0) + value;
    }
    
    // Update experience points
    _experiencePoints += value * 0.1;
    
    // Check for level up
    final newLevel = _calculateLevel();
    if (newLevel > _level) {
      _level = newLevel;
      await _onLevelUp();
    }
    
    // Track analytics (avoid nulls; ensure Object values)
    final params = <String, Object>{
      'points': value,
      'total_points': _points,
      'level': _level,
    };
    if (category != null) params['category'] = category;
    if (action != null) params['action'] = action;
    if (context != null) params['context'] = jsonEncode(context);
    await _analytics.logEvent('points_earned', parameters: params);
    
    await _advancedAnalytics.trackUserEngagement(
      feature: 'gamification',
      action: 'points_earned',
      duration: 0,
      additionalData: {
        'points': value,
        'category': category,
        'action': action,
      },
    );
    
    await _evaluateAchievements();
    await _updateProgress();
    await _save();
    notifyListeners();
  }

  /// Bump streak with advanced streak tracking
  Future<void> bumpStreak() async {
    final today = DateTime.now();
    final lastActivity = _lastActivity['streak'] ?? DateTime(1970);
    
    // Check if this is a new day
    if (today.difference(lastActivity).inDays >= 1) {
      _streakDays += 1;
      _lastActivity['streak'] = today;
      
      // Award streak bonuses
      if (_streakDays % 7 == 0) {
        await addPoints(50, category: 'streak', action: 'weekly_streak');
      }
      if (_streakDays % 30 == 0) {
        await addPoints(200, category: 'streak', action: 'monthly_streak');
      }
      
      await _analytics.logEvent('streak_updated', parameters: {
        'streak_days': _streakDays,
        'last_activity': today.toIso8601String(),
      });
    }
    
    await _save();
    notifyListeners();
  }

  // Backward-compatible alias expected by tests
  Future<void> incrementStreak() => bumpStreak();

  /// Grant badge with advanced badge system
  Future<void> grantBadge(final String badge, {final String? category, final String? description}) async {
    if (_badges.add(badge)) {
      _lastBadge = badge;
      
      // Award bonus points for badges
      final badgePoints = _getBadgePoints(badge);
      if (badgePoints > 0) {
        await addPoints(badgePoints, category: 'badges', action: 'badge_earned');
      }
      
      final params = <String, Object>{
        'badge': badge,
        'total_badges': _badges.length,
      };
      if (category != null) params['category'] = category;
      if (description != null) params['description'] = description;
      await _analytics.logEvent('badge_earned', parameters: params);
      
      await _save();
      notifyListeners();
    }
  }

  /// Grant achievement with advanced achievement system
  Future<void> grantAchievement(final String achievement, {final String? category, final String? description, final int? points}) async {
    if (_achievements.add(achievement)) {
      _lastAchievement = achievement;
      
      // Award points for achievements
      final achievementPoints = points ?? _getAchievementPoints(achievement);
      if (achievementPoints > 0) {
        await addPoints(achievementPoints, category: 'achievements', action: 'achievement_earned');
      }
      
      final params = <String, Object>{
        'achievement': achievement,
        'points': achievementPoints,
        'total_achievements': _achievements.length,
      };
      if (category != null) params['category'] = category;
      if (description != null) params['description'] = description;
      await _analytics.logEvent('achievement_earned', parameters: params);
      
      await _save();
      notifyListeners();
    }
  }

  /// Create or join a social challenge
  Future<void> joinChallenge(final SocialChallenge challenge) async {
    if (!_activeChallenges.any((final c) => c.id == challenge.id)) {
      _activeChallenges.add(challenge);
      
      await _analytics.logEvent('challenge_joined', parameters: {
        'challenge_id': challenge.id,
        'challenge_type': challenge.type,
        'challenge_name': challenge.name,
      });
      
      await _save();
      notifyListeners();
    }
  }

  /// Complete a social challenge
  Future<void> completeChallenge(final String challengeId) async {
    final challenge = _activeChallenges.firstWhere(
      (final c) => c.id == challengeId,
      orElse: () => throw Exception('Challenge not found'),
    );
    
    _activeChallenges.remove(challenge);
    
    // Award challenge completion points
    await addPoints(challenge.rewardPoints, category: 'challenges', action: 'challenge_completed');
    
    // Update social stats
    _socialStats['challenges_completed'] = (_socialStats['challenges_completed'] ?? 0) + 1;
    
    await _analytics.logEvent('challenge_completed', parameters: {
      'challenge_id': challengeId,
      'challenge_type': challenge.type,
      'reward_points': challenge.rewardPoints,
    });
    
    await _save();
    notifyListeners();
  }

  /// Set weekly goal
  Future<void> setWeeklyGoal(final String category, final int target) async {
    _weeklyGoals[category] = target;
    
    await _analytics.logEvent('weekly_goal_set', parameters: {
      'category': category,
      'target': target,
    });
    
    await _save();
    notifyListeners();
  }

  /// Set monthly goal
  Future<void> setMonthlyGoal(final String category, final int target) async {
    _monthlyGoals[category] = target;
    
    await _analytics.logEvent('monthly_goal_set', parameters: {
      'category': category,
      'target': target,
    });
    
    await _save();
    notifyListeners();
  }

  /// Add habit for behavioral psychology
  Future<void> addHabit(final Habit habit) async {
    _habits.add(habit);
    
    await _analytics.logEvent('habit_added', parameters: {
      'habit_id': habit.id,
      'habit_name': habit.name,
      'habit_category': habit.category,
    });
    
    await _save();
    notifyListeners();
  }

  /// Complete habit
  Future<void> completeHabit(final String habitId) async {
    final habit = _habits.firstWhere(
      (final h) => h.id == habitId,
      orElse: () => throw Exception('Habit not found'),
    );
    
    habit.complete();
    
    // Award habit completion points
    await addPoints(habit.pointsPerCompletion, category: 'habits', action: 'habit_completed');
    
    await _analytics.logEvent('habit_completed', parameters: {
      'habit_id': habitId,
      'habit_name': habit.name,
      'streak': habit.currentStreak,
    });
    
    await _save();
    notifyListeners();
  }

  /// Add milestone
  Future<void> addMilestone(final Milestone milestone) async {
    _milestones.add(milestone);
    
    await _analytics.logEvent('milestone_added', parameters: {
      'milestone_id': milestone.id,
      'milestone_name': milestone.name,
      'milestone_target': milestone.target,
    });
    
    await _save();
    notifyListeners();
  }

  /// Update milestone progress
  Future<void> updateMilestoneProgress(final String milestoneId, final int progress) async {
    final milestone = _milestones.firstWhere(
      (final m) => m.id == milestoneId,
      orElse: () => throw Exception('Milestone not found'),
    );
    
    milestone.updateProgress(progress);
    
    if (milestone.isCompleted && !milestone.isAwarded) {
      milestone.award();
      await addPoints(milestone.rewardPoints, category: 'milestones', action: 'milestone_completed');
      
      await _analytics.logEvent('milestone_completed', parameters: {
        'milestone_id': milestoneId,
        'milestone_name': milestone.name,
        'reward_points': milestone.rewardPoints,
      });
    }
    
    await _save();
    notifyListeners();
  }

  /// Earn reward
  Future<void> earnReward(final Reward reward) async {
    if (!_earnedRewards.any((final r) => r.id == reward.id)) {
      _earnedRewards.add(reward);
      
      await _analytics.logEvent('reward_earned', parameters: {
        'reward_id': reward.id,
        'reward_name': reward.name,
        'reward_type': reward.type,
        'reward_value': reward.value,
      });
      
      await _save();
      notifyListeners();
    }
  }

  /// Redeem reward
  Future<void> redeemReward(final String rewardId) async {
    final reward = _earnedRewards.firstWhere(
      (final r) => r.id == rewardId,
      orElse: () => throw Exception('Reward not found'),
    );
    
    _earnedRewards.remove(reward);
    _redeemedRewards.add(reward);
    
    await _analytics.logEvent('reward_redeemed', parameters: {
      'reward_id': rewardId,
      'reward_name': reward.name,
      'reward_type': reward.type,
    });
    
    await _save();
    notifyListeners();
  }

  /// Get personalized recommendations
  Future<List<GamificationRecommendation>> getPersonalizedRecommendations() async {
    final recommendations = <GamificationRecommendation>[];
    
    // Analyze user behavior and suggest improvements
    if (_streakDays < 3) {
      recommendations.add(GamificationRecommendation(
        type: 'streak',
        title: 'Build Your Streak',
        description: 'Complete daily activities to build a streak and earn bonus points',
        action: 'Start daily habit',
        priority: 0.9,
      ));
    }
    
    if (_level < 5) {
      recommendations.add(GamificationRecommendation(
        type: 'level',
        title: 'Level Up',
        description: 'You\'re close to leveling up! Complete a few more activities',
        action: 'View activities',
        priority: 0.8,
      ));
    }
    
    // Suggest challenges based on user interests
    final topCategory = _categoryPoints.entries.isNotEmpty 
        ? _categoryPoints.entries.reduce((final a, final b) => a.value > b.value ? a : b).key
        : 'general';
    
    recommendations.add(GamificationRecommendation(
      type: 'challenge',
      title: 'New Challenge Available',
      description: 'Try a new challenge in your favorite category: $topCategory',
      action: 'View challenges',
      priority: 0.7,
    ));
    
    return recommendations;
  }

  /// Clear last badge/achievement
  void clearLastBadge() {
    _lastBadge = null;
  }

  void clearLastAchievement() {
    _lastAchievement = null;
  }

  /// Calculate level from experience points
  int _calculateLevel() => (_experiencePoints / 100).floor() + 1;

  /// Calculate experience needed for next level
  double _calculateExperienceToNextLevel() {
    final nextLevelExp = _level * 100;
    return nextLevelExp - _experiencePoints;
  }

  /// Handle level up
  Future<void> _onLevelUp() async {
    await grantAchievement('Level $_level', category: 'level', points: _level * 10);
    
    // Unlock new rewards
    await _unlockLevelRewards(_level);
    
    await _analytics.logEvent('level_up', parameters: {
      'new_level': _level,
      'experience_points': _experiencePoints,
    });
  }

  /// Unlock rewards for reaching a level
  Future<void> _unlockLevelRewards(final int level) async {
    final rewards = _getLevelRewards(level);
    for (final reward in rewards) {
      _availableRewards.add(reward);
    }
  }

  /// Get rewards for a specific level
  List<Reward> _getLevelRewards(final int level) {
    switch (level) {
      case 2:
        return [Reward(id: 'level_2_badge', name: 'Level 2 Badge', type: 'badge', value: 1)];
      case 5:
        return [Reward(id: 'level_5_theme', name: 'Level 5 Theme', type: 'theme', value: 1)];
      case 10:
        return [Reward(id: 'level_10_avatar', name: 'Level 10 Avatar', type: 'avatar', value: 1)];
      default:
        return [];
    }
  }

  /// Get badge points
  int _getBadgePoints(final String badge) {
    switch (badge) {
      case 'Smart Spender': return 25;
      case 'NDIS Champion': return 50;
      case 'Streak Master': return 100;
      case 'Goal Crusher': return 75;
      default: return 10;
    }
  }

  /// Get achievement points
  int _getAchievementPoints(final String achievement) {
    if (achievement.startsWith('Level ')) {
      final level = int.tryParse(achievement.split(' ')[1]) ?? 1;
      return level * 10;
    }
    return 25;
  }

  /// Evaluate all achievements
  Future<void> _evaluateAllAchievements() async {
    // Points-based achievements
    if (_points >= 50 && !_achievements.contains('Smart Spender')) {
      await grantAchievement('Smart Spender', category: 'points', points: 25);
    }
    if (_points >= 100 && !_achievements.contains('NDIS Champion')) {
      await grantAchievement('NDIS Champion', category: 'points', points: 50);
    }
    if (_points >= 500 && !_achievements.contains('Point Master')) {
      await grantAchievement('Point Master', category: 'points', points: 100);
    }
    
    // Streak-based achievements
    if (_streakDays >= 7 && !_achievements.contains('Week Warrior')) {
      await grantAchievement('Week Warrior', category: 'streak', points: 50);
    }
    if (_streakDays >= 30 && !_achievements.contains('Month Master')) {
      await grantAchievement('Month Master', category: 'streak', points: 200);
    }
    
    // Badge-based achievements
    if (_badges.length >= 5 && !_achievements.contains('Badge Collector')) {
      await grantAchievement('Badge Collector', category: 'badges', points: 75);
    }
    if (_badges.length >= 10 && !_achievements.contains('Badge Master')) {
      await grantAchievement('Badge Master', category: 'badges', points: 150);
    }
    
    // Level-based achievements
    if (_level >= 5 && !_achievements.contains('Rising Star')) {
      await grantAchievement('Rising Star', category: 'level', points: 100);
    }
    if (_level >= 10 && !_achievements.contains('NDIS Expert')) {
      await grantAchievement('NDIS Expert', category: 'level', points: 250);
    }
  }

  /// Evaluate achievements after points change
  Future<void> _evaluateAchievements() async {
    await _evaluateAllAchievements();
  }

  /// Update progress tracking
  Future<void> _updateProgress() async {
    // Update weekly goals progress
    for (final entry in _weeklyGoals.entries) {
      final category = entry.key;
      final target = entry.value;
      final current = _categoryPoints[category] ?? 0;
      
      if (current >= target && !_achievements.contains('Weekly Goal: $category')) {
        await grantAchievement('Weekly Goal: $category', category: 'goals', points: 50);
      }
    }
    
    // Update monthly goals progress
    for (final entry in _monthlyGoals.entries) {
      final category = entry.key;
      final target = entry.value;
      final current = _categoryPoints[category] ?? 0;
      
      if (current >= target && !_achievements.contains('Monthly Goal: $category')) {
        await grantAchievement('Monthly Goal: $category', category: 'goals', points: 100);
      }
    }
  }

  /// Initialize default goals
  Future<void> _initializeDefaultGoals() async {
    if (_weeklyGoals.isEmpty) {
      _weeklyGoals.addAll({
        'appointments': 3,
        'budget_tracking': 5,
        'provider_search': 2,
      });
    }
    
    if (_monthlyGoals.isEmpty) {
      _monthlyGoals.addAll({
        'appointments': 12,
        'budget_tracking': 20,
        'provider_search': 8,
      });
    }
  }

  /// Load social challenges
  Future<void> _loadSocialChallenges() async {
    // This would typically load from a server
    _activeChallenges.addAll([
      SocialChallenge(
        id: 'weekly_budget_tracker',
        name: 'Weekly Budget Tracker',
        description: 'Track your budget 5 times this week',
        type: 'weekly',
        target: 5,
        current: 0,
        rewardPoints: 100,
        endDate: DateTime.now().add(const Duration(days: 7)),
      ),
      SocialChallenge(
        id: 'appointment_booking',
        name: 'Appointment Booking',
        description: 'Book 3 appointments this month',
        type: 'monthly',
        target: 3,
        current: 0,
        rewardPoints: 150,
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ]);
  }

  /// Update leaderboard
  Future<void> _updateLeaderboard() async {
    // This would typically load from a server
    _leaderboard = [
      LeaderboardEntry(userId: 'user1', username: 'NDIS Champion', points: 1250, rank: 1),
      LeaderboardEntry(userId: 'user2', username: 'Budget Master', points: 1100, rank: 2),
      LeaderboardEntry(userId: 'user3', username: 'Streak King', points: 950, rank: 3),
    ];
  }

  /// Load from storage
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    _points = prefs.getInt('points') ?? 0;
    _streakDays = prefs.getInt('streakDays') ?? 0;
    _totalPointsEarned = prefs.getInt('totalPointsEarned') ?? 0;
    _level = prefs.getInt('level') ?? 1;
    _experiencePoints = prefs.getDouble('experiencePoints') ?? 0.0;
    
    _badges = (prefs.getStringList('badges') ?? []).toSet();
    _achievements = (prefs.getStringList('achievements') ?? []).toSet();
    
    // Load category points
    final categoryPointsJson = prefs.getString('categoryPoints');
    if (categoryPointsJson != null) {
      _categoryPoints = Map<String, int>.from(jsonDecode(categoryPointsJson));
    }
    
    // Load goals
    final weeklyGoalsJson = prefs.getString('weeklyGoals');
    if (weeklyGoalsJson != null) {
      _weeklyGoals = Map<String, int>.from(
        (jsonDecode(weeklyGoalsJson) as Map).map(
          (final key, final value) => MapEntry(key.toString(), value as int),
        ),
      );
    }

    final monthlyGoalsJson = prefs.getString('monthlyGoals');
    if (monthlyGoalsJson != null) {
      _monthlyGoals = Map<String, int>.from(
        (jsonDecode(monthlyGoalsJson) as Map).map(
          (final key, final value) => MapEntry(key.toString(), value as int),
        ),
      );
    }
    
    // Load social stats
    final socialStatsJson = prefs.getString('socialStats');
    if (socialStatsJson != null) {
      _socialStats = Map<String, int>.from(
        (jsonDecode(socialStatsJson) as Map).map(
          (final key, final value) => MapEntry(key.toString(), value as int),
        ),
      );
    }
    
    notifyListeners();
  }

  /// Save to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('points', _points);
    await prefs.setInt('streakDays', _streakDays);
    await prefs.setInt('totalPointsEarned', _totalPointsEarned);
    await prefs.setInt('level', _level);
    await prefs.setDouble('experiencePoints', _experiencePoints);
    
    await prefs.setStringList('badges', _badges.toList());
    await prefs.setStringList('achievements', _achievements.toList());
    
    await prefs.setString('categoryPoints', jsonEncode(_categoryPoints));
    await prefs.setString('weeklyGoals', jsonEncode(_weeklyGoals));
    await prefs.setString('monthlyGoals', jsonEncode(_monthlyGoals));
    await prefs.setString('socialStats', jsonEncode(_socialStats));
    
    notifyListeners();
  }
}

/// Social challenge model
class SocialChallenge {

  SocialChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.target,
    required this.current,
    required this.rewardPoints,
    required this.endDate,
  });
  final String id;
  final String name;
  final String description;
  final String type; // daily, weekly, monthly
  final int target;
  int current;
  final int rewardPoints;
  final DateTime endDate;

  double get progress => current / target;
  bool get isCompleted => current >= target;
  bool get isExpired => DateTime.now().isAfter(endDate);
}

/// Leaderboard entry model
class LeaderboardEntry {

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.points,
    required this.rank,
  });
  final String userId;
  final String username;
  final int points;
  final int rank;
}

/// Habit model for behavioral psychology
class Habit {

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.pointsPerCompletion,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completionDates = const [],
  });
  final String id;
  final String name;
  final String category;
  final int pointsPerCompletion;
  int currentStreak;
  int longestStreak;
  final List<DateTime> completionDates;

  void complete() {
    final today = DateTime.now();
    completionDates.add(today);
    
    // Update streak
    if (completionDates.length > 1) {
      final lastCompletion = completionDates[completionDates.length - 2];
      if (today.difference(lastCompletion).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }
    
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }
}

/// Milestone model
class Milestone {

  Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
    required this.current,
    required this.rewardPoints,
    this.isCompleted = false,
    this.isAwarded = false,
  });
  final String id;
  final String name;
  final String description;
  final int target;
  int current;
  final int rewardPoints;
  bool isCompleted;
  bool isAwarded;

  double get progress => current / target;

  void updateProgress(final int progress) {
    current = progress;
    isCompleted = current >= target;
  }

  void award() {
    isAwarded = true;
  }
}

/// Reward model
class Reward {

  Reward({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.description,
    this.imageUrl,
  });
  final String id;
  final String name;
  final String type; // badge, theme, avatar, discount, etc.
  final int value;
  final String? description;
  final String? imageUrl;
}

/// Gamification recommendation model
class GamificationRecommendation {

  GamificationRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
  });
  final String type;
  final String title;
  final String description;
  final String action;
  final double priority;
}
