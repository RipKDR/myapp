import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Advanced gamification service implementing 2025 engagement trends
class AdvancedGamificationService {
  factory AdvancedGamificationService() => _instance;
  AdvancedGamificationService._internal();
  static final AdvancedGamificationService _instance =
      AdvancedGamificationService._internal();

  // Achievement system
  final Map<String, Achievement> _achievements = {
    'first_login': Achievement(
      id: 'first_login',
      title: 'Welcome to NDIS Connect!',
      description: 'You\'ve taken the first step in your NDIS journey',
      icon: Icons.waving_hand,
      points: 50,
      rarity: AchievementRarity.common,
      category: AchievementCategory.milestone,
    ),
    'budget_master': Achievement(
      id: 'budget_master',
      title: 'Budget Master',
      description: 'Successfully managed your budget for 30 days',
      icon: Icons.account_balance_wallet,
      points: 200,
      rarity: AchievementRarity.rare,
      category: AchievementCategory.financial,
    ),
    'appointment_pro': Achievement(
      id: 'appointment_pro',
      title: 'Appointment Pro',
      description: 'Attended 10 appointments without missing any',
      icon: Icons.event_available,
      points: 150,
      rarity: AchievementRarity.rare,
      category: AchievementCategory.health,
    ),
    'streak_champion': Achievement(
      id: 'streak_champion',
      title: 'Streak Champion',
      description: 'Maintained a 7-day activity streak',
      icon: Icons.local_fire_department,
      points: 100,
      rarity: AchievementRarity.uncommon,
      category: AchievementCategory.consistency,
    ),
    'community_helper': Achievement(
      id: 'community_helper',
      title: 'Community Helper',
      description: 'Helped 5 other NDIS participants',
      icon: Icons.people,
      points: 300,
      rarity: AchievementRarity.epic,
      category: AchievementCategory.social,
    ),
    'goal_crusher': Achievement(
      id: 'goal_crusher',
      title: 'Goal Crusher',
      description: 'Completed all your monthly goals',
      icon: Icons.emoji_events,
      points: 250,
      rarity: AchievementRarity.epic,
      category: AchievementCategory.goals,
    ),
  };

  // User progress tracking
  UserProgress _userProgress = UserProgress();
  List<Achievement> _unlockedAchievements = [];
  List<SocialChallenge> _activeChallenges = [];
  List<LeaderboardEntry> _leaderboard = [];

  /// Initialize the gamification service
  Future<void> initialize() async {
    await _loadUserProgress();
    await _loadAchievements();
    await _loadChallenges();
    await _loadLeaderboard();
  }

  /// Get current user progress
  UserProgress get userProgress => _userProgress;

  /// Get unlocked achievements
  List<Achievement> get unlockedAchievements => _unlockedAchievements;

  /// Get active challenges
  List<SocialChallenge> get activeChallenges => _activeChallenges;

  /// Get leaderboard
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  /// Award points for an action
  Future<void> awardPoints(final String action, {final int? customPoints}) async {
    final points = customPoints ?? _getPointsForAction(action);
    if (points > 0) {
      _userProgress.totalPoints += points;
      _userProgress.dailyPoints += points;
      _userProgress.weeklyPoints += points;

      // Update streak
      _updateStreak();

      // Check for level up
      await _checkLevelUp();

      // Check for achievements
      await _checkAchievements(action);

      await _saveUserProgress();
    }
  }

  /// Complete a goal
  Future<void> completeGoal(final String goalId, final String goalName) async {
    _userProgress.completedGoals++;
    _userProgress.currentStreak++;

    // Award points for goal completion
    await awardPoints('goal_completed', customPoints: 100);

    // Check for goal-related achievements
    if (_userProgress.completedGoals >= 10) {
      await _unlockAchievement('goal_crusher');
    }
  }

  /// Join a social challenge
  Future<void> joinChallenge(final String challengeId) async {
    final challenge = _activeChallenges.firstWhere(
      (final c) => c.id == challengeId,
      orElse: () => throw Exception('Challenge not found'),
    );

    if (!challenge.participants.contains(_userProgress.userId)) {
      challenge.participants.add(_userProgress.userId);
      await _saveChallenges();
    }
  }

  /// Submit challenge progress
  Future<void> submitChallengeProgress(final String challengeId, final int progress) async {
    final challenge = _activeChallenges.firstWhere(
      (final c) => c.id == challengeId,
      orElse: () => throw Exception('Challenge not found'),
    );

    challenge.userProgress[_userProgress.userId] = progress;

    // Check if challenge is completed
    if (progress >= challenge.target) {
      await _completeChallenge(challengeId);
    }

    await _saveChallenges();
  }

  /// Get personalized recommendations
  List<Recommendation> getPersonalizedRecommendations() {
    final recommendations = <Recommendation>[];

    // Based on user level
    if (_userProgress.level < 5) {
      recommendations.add(Recommendation(
        title: 'Complete Your Profile',
        description: 'Add more details to unlock personalized features',
        action: 'complete_profile',
        priority: RecommendationPriority.high,
        points: 50,
      ));
    }

    // Based on activity patterns
    if (_userProgress.dailyPoints < 20) {
      recommendations.add(Recommendation(
        title: 'Daily Check-in',
        description: 'Log in daily to maintain your streak',
        action: 'daily_checkin',
        priority: RecommendationPriority.medium,
        points: 25,
      ));
    }

    // Based on achievements
    if (!_hasAchievement('budget_master')) {
      recommendations.add(Recommendation(
        title: 'Track Your Budget',
        description:
            'Monitor your NDIS spending to earn the Budget Master badge',
        action: 'track_budget',
        priority: RecommendationPriority.medium,
        points: 100,
      ));
    }

    // Based on social engagement
    if (_userProgress.socialInteractions < 5) {
      recommendations.add(Recommendation(
        title: 'Join Community Challenge',
        description: 'Connect with other NDIS participants',
        action: 'join_challenge',
        priority: RecommendationPriority.low,
        points: 75,
      ));
    }

    return recommendations;
  }

  /// Get next level requirements
  LevelInfo getNextLevelInfo() {
    final currentLevel = _userProgress.level;
    final nextLevel = currentLevel + 1;
    final requiredPoints = _getPointsForLevel(nextLevel);
    final currentPoints = _userProgress.totalPoints;
    final progress = (currentPoints / requiredPoints).clamp(0.0, 1.0);

    return LevelInfo(
      currentLevel: currentLevel,
      nextLevel: nextLevel,
      currentPoints: currentPoints,
      requiredPoints: requiredPoints,
      progress: progress,
      pointsToNext: requiredPoints - currentPoints,
    );
  }

  /// Get achievement progress
  Map<String, double> getAchievementProgress() {
    final progress = <String, double>{};

    // Budget Master progress
    final budgetDays = _userProgress.budgetTrackingDays;
    progress['budget_master'] = (budgetDays / 30).clamp(0.0, 1.0);

    // Appointment Pro progress
    final appointmentsAttended = _userProgress.appointmentsAttended;
    progress['appointment_pro'] = (appointmentsAttended / 10).clamp(0.0, 1.0);

    // Streak Champion progress
    final currentStreak = _userProgress.currentStreak;
    progress['streak_champion'] = (currentStreak / 7).clamp(0.0, 1.0);

    return progress;
  }

  // Private methods

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('user_progress');
    if (progressJson != null) {
      _userProgress = UserProgress.fromJson(
          jsonDecode(progressJson) as Map<String, dynamic>);
    } else {
      _userProgress = UserProgress();
    }
  }

  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_progress', jsonEncode(_userProgress.toJson()));
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString('unlocked_achievements');
    if (achievementsJson != null) {
      final List<dynamic> achievementsList =
          jsonDecode(achievementsJson) as List<dynamic>;
      _unlockedAchievements = achievementsList
          .map((final json) => Achievement.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson =
        jsonEncode(_unlockedAchievements.map((final a) => a.toJson()).toList());
    await prefs.setString('unlocked_achievements', achievementsJson);
  }

  Future<void> _loadChallenges() async {
    // Mock challenges for demo
    _activeChallenges = [
      SocialChallenge(
        id: 'weekly_budget',
        title: 'Weekly Budget Challenge',
        description: 'Track your budget for 7 consecutive days',
        target: 7,
        participants: [],
        userProgress: {},
        endDate: DateTime.now().add(const Duration(days: 7)),
        reward: 150,
      ),
      SocialChallenge(
        id: 'community_help',
        title: 'Community Helper',
        description: 'Help 3 other participants this month',
        target: 3,
        participants: [],
        userProgress: {},
        endDate: DateTime.now().add(const Duration(days: 30)),
        reward: 200,
      ),
    ];
  }

  Future<void> _saveChallenges() async {
    // In a real app, this would save to a backend
  }

  Future<void> _loadLeaderboard() async {
    // Mock leaderboard for demo
    _leaderboard = [
      LeaderboardEntry(
        userId: 'user1',
        username: 'Sarah M.',
        points: 2450,
        level: 8,
        avatar: '👩‍🦽',
        rank: 1,
      ),
      LeaderboardEntry(
        userId: 'user2',
        username: 'Mike T.',
        points: 2200,
        level: 7,
        avatar: '👨‍🦯',
        rank: 2,
      ),
      LeaderboardEntry(
        userId: 'user3',
        username: 'Emma L.',
        points: 1950,
        level: 6,
        avatar: '👩‍🦼',
        rank: 3,
      ),
    ];
  }

  int _getPointsForAction(final String action) {
    switch (action) {
      case 'login':
        return 10;
      case 'budget_update':
        return 25;
      case 'appointment_attended':
        return 50;
      case 'goal_completed':
        return 100;
      case 'social_interaction':
        return 30;
      default:
        return 5;
    }
  }

  int _getPointsForLevel(final int level) {
    return level * level * 100; // Exponential growth
  }

  void _updateStreak() {
    final now = DateTime.now();
    final lastActivity = _userProgress.lastActivityDate;

    if (lastActivity == null) {
      _userProgress.currentStreak = 1;
    } else {
      final daysDifference = now.difference(lastActivity).inDays;
      if (daysDifference == 1) {
        _userProgress.currentStreak++;
      } else if (daysDifference > 1) {
        _userProgress.currentStreak = 1;
      }
    }

    _userProgress.lastActivityDate = now;
  }

  Future<void> _checkLevelUp() async {
    final currentLevel = _userProgress.level;
    final requiredPoints = _getPointsForLevel(currentLevel + 1);

    if (_userProgress.totalPoints >= requiredPoints) {
      _userProgress.level++;
      // Award level up bonus
      await awardPoints('level_up', customPoints: 200);
    }
  }

  Future<void> _checkAchievements(final String action) async {
    switch (action) {
      case 'login':
        if (!_hasAchievement('first_login')) {
          await _unlockAchievement('first_login');
        }
        break;
      case 'budget_update':
        _userProgress.budgetTrackingDays++;
        if (_userProgress.budgetTrackingDays >= 30 &&
            !_hasAchievement('budget_master')) {
          await _unlockAchievement('budget_master');
        }
        break;
      case 'appointment_attended':
        _userProgress.appointmentsAttended++;
        if (_userProgress.appointmentsAttended >= 10 &&
            !_hasAchievement('appointment_pro')) {
          await _unlockAchievement('appointment_pro');
        }
        break;
    }

    // Check streak achievements
    if (_userProgress.currentStreak >= 7 &&
        !_hasAchievement('streak_champion')) {
      await _unlockAchievement('streak_champion');
    }
  }

  bool _hasAchievement(final String achievementId) => _unlockedAchievements.any((final a) => a.id == achievementId);

  Future<void> _unlockAchievement(final String achievementId) async {
    if (!_hasAchievement(achievementId)) {
      final achievement = _achievements[achievementId];
      if (achievement != null) {
        _unlockedAchievements.add(achievement);
        await awardPoints('achievement_unlocked',
            customPoints: achievement.points);
        await _saveAchievements();
      }
    }
  }

  Future<void> _completeChallenge(final String challengeId) async {
    final challenge = _activeChallenges.firstWhere((final c) => c.id == challengeId);
    await awardPoints('challenge_completed', customPoints: challenge.reward);
  }
}

// Data models

class UserProgress {

  UserProgress({
    this.userId = 'default_user',
    this.totalPoints = 0,
    this.dailyPoints = 0,
    this.weeklyPoints = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.completedGoals = 0,
    this.budgetTrackingDays = 0,
    this.appointmentsAttended = 0,
    this.socialInteractions = 0,
    this.lastActivityDate,
  });

  factory UserProgress.fromJson(final Map<String, dynamic> json) => UserProgress(
        userId: (json['userId'] as String?) ?? 'default_user',
        totalPoints: (json['totalPoints'] as int?) ?? 0,
        dailyPoints: (json['dailyPoints'] as int?) ?? 0,
        weeklyPoints: (json['weeklyPoints'] as int?) ?? 0,
        level: (json['level'] as int?) ?? 1,
        currentStreak: (json['currentStreak'] as int?) ?? 0,
        completedGoals: (json['completedGoals'] as int?) ?? 0,
        budgetTrackingDays: (json['budgetTrackingDays'] as int?) ?? 0,
        appointmentsAttended: (json['appointmentsAttended'] as int?) ?? 0,
        socialInteractions: (json['socialInteractions'] as int?) ?? 0,
        lastActivityDate: json['lastActivityDate'] != null
            ? DateTime.parse(json['lastActivityDate'] as String)
            : null,
      );
  String userId;
  int totalPoints;
  int dailyPoints;
  int weeklyPoints;
  int level;
  int currentStreak;
  int completedGoals;
  int budgetTrackingDays;
  int appointmentsAttended;
  int socialInteractions;
  DateTime? lastActivityDate;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'totalPoints': totalPoints,
        'dailyPoints': dailyPoints,
        'weeklyPoints': weeklyPoints,
        'level': level,
        'currentStreak': currentStreak,
        'completedGoals': completedGoals,
        'budgetTrackingDays': budgetTrackingDays,
        'appointmentsAttended': appointmentsAttended,
        'socialInteractions': socialInteractions,
        'lastActivityDate': lastActivityDate?.toIso8601String(),
      };
}

class Achievement {

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.rarity,
    required this.category,
  });

  factory Achievement.fromJson(final Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
        points: json['points'] as int,
        rarity: AchievementRarity.values.firstWhere(
          (final r) => r.name == json['rarity'] as String,
          orElse: () => AchievementRarity.common,
        ),
        category: AchievementCategory.values.firstWhere(
          (final c) => c.name == json['category'] as String,
          orElse: () => AchievementCategory.milestone,
        ),
      );
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;
  final AchievementRarity rarity;
  final AchievementCategory category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon.codePoint,
        'points': points,
        'rarity': rarity.name,
        'category': category.name,
      };
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

enum AchievementCategory {
  milestone,
  financial,
  health,
  consistency,
  social,
  goals,
}

class SocialChallenge {

  SocialChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.participants,
    required this.userProgress,
    required this.endDate,
    required this.reward,
  });
  final String id;
  final String title;
  final String description;
  final int target;
  final List<String> participants;
  final Map<String, int> userProgress;
  final DateTime endDate;
  final int reward;
}

class LeaderboardEntry {

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.points,
    required this.level,
    required this.avatar,
    required this.rank,
  });
  final String userId;
  final String username;
  final int points;
  final int level;
  final String avatar;
  final int rank;
}

class Recommendation {

  Recommendation({
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
    required this.points,
  });
  final String title;
  final String description;
  final String action;
  final RecommendationPriority priority;
  final int points;
}

enum RecommendationPriority {
  low,
  medium,
  high,
}

class LevelInfo {

  LevelInfo({
    required this.currentLevel,
    required this.nextLevel,
    required this.currentPoints,
    required this.requiredPoints,
    required this.progress,
    required this.pointsToNext,
  });
  final int currentLevel;
  final int nextLevel;
  final int currentPoints;
  final int requiredPoints;
  final double progress;
  final int pointsToNext;
}
