import 'package:flutter/material.dart';
import '../services/advanced_gamification_service.dart' as gamification;
import '../services/ai_personalization_service.dart' as personalization;
import '../theme/app_theme.dart';
import '../utils/haptic_utils.dart';
import '../widgets/glassmorphism_effects.dart';

/// Advanced gamification dashboard implementing 2025 engagement trends
class AdvancedGamificationDashboard extends StatefulWidget {
  const AdvancedGamificationDashboard({super.key});

  @override
  State<AdvancedGamificationDashboard> createState() =>
      _AdvancedGamificationDashboardState();
}

class _AdvancedGamificationDashboardState
    extends State<AdvancedGamificationDashboard> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _achievementController;
  late AnimationController _challengeController;

  final _gamificationService = gamification.AdvancedGamificationService();
  final _personalizationService = personalization.AIPersonalizationService();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _challengeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _initializeServices();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _achievementController.dispose();
    _challengeController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _gamificationService.initialize();
    await _personalizationService.initialize();

    _progressController.forward();
    _achievementController.forward();
    _challengeController.forward();
  }

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Progress Section
          _buildLevelProgressSection(),

          const SizedBox(height: 24),

          // Achievements Section
          _buildAchievementsSection(),

          const SizedBox(height: 24),

          // Social Challenges Section
          _buildSocialChallengesSection(),

          const SizedBox(height: 24),

          // Personalized Recommendations
          _buildPersonalizedRecommendations(),

          const SizedBox(height: 24),

          // Leaderboard Section
          _buildLeaderboardSection(),
        ],
      ),
    );

  Widget _buildLevelProgressSection() {
    final levelInfo = _gamificationService.getNextLevelInfo();
    final userProgress = _gamificationService.userProgress;

    return GlassmorphismEffects.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.trustGreen, AppTheme.calmingBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${levelInfo.currentLevel}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.trustGreen,
                          ),
                    ),
                    Text(
                      '${levelInfo.pointsToNext} points to Level ${levelInfo.nextLevel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warmAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${userProgress.totalPoints} pts',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.warmAccent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          AnimatedBuilder(
            animation: _progressController,
            builder: (final context, final child) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${levelInfo.currentPoints}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        '${levelInfo.requiredPoints}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: levelInfo.progress * _progressController.value,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.trustGreen),
                    minHeight: 8,
                  ),
                ],
              ),
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${userProgress.currentStreak} days',
                  Icons.local_fire_department,
                  AppTheme.warmAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Goals',
                  '${userProgress.completedGoals}',
                  Icons.flag,
                  AppTheme.calmingBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Achievements',
                  '${_gamificationService.unlockedAchievements.length}',
                  Icons.emoji_events,
                  AppTheme.empathyPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      final String label, final String value, final IconData icon, final Color color) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildAchievementsSection() {
    final achievements = _gamificationService.unlockedAchievements;
    final achievementProgress = _gamificationService.getAchievementProgress();

    return GlassmorphismEffects.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.empathyPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppTheme.empathyPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Unlocked Achievements
          if (achievements.isNotEmpty) ...[
            Text(
              'Unlocked (${achievements.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...achievements
                .take(3)
                .map((final achievement) =>
                    _buildAchievementCard(achievement, isUnlocked: true))
                ,
          ],

          const SizedBox(height: 16),

          // Progress Achievements
          Text(
            'In Progress',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...achievementProgress.entries
              .map((final entry) =>
                  _buildAchievementProgressCard(entry.key, entry.value))
              ,
        ],
      ),
    );
  }

  Widget _buildAchievementCard(final gamification.Achievement achievement,
      {final bool isUnlocked = false}) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? _getRarityColor(achievement.rarity).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? _getRarityColor(achievement.rarity).withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? _getRarityColor(achievement.rarity)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                ),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRarityColor(achievement.rarity).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${achievement.points}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getRarityColor(achievement.rarity),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );

  Widget _buildAchievementProgressCard(final String achievementId, final double progress) {
    // Get achievement from the service (would need to expose this method)
    // For now, create a mock achievement
    final achievement = gamification.Achievement(
      id: achievementId,
      title: 'Achievement',
      description: 'Complete this achievement',
      icon: Icons.star,
      points: 100,
      rarity: gamification.AchievementRarity.common,
      category: gamification.AchievementCategory.milestone,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  achievement.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.calmingBlue),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChallengesSection() {
    final challenges = _gamificationService.activeChallenges;

    return GlassmorphismEffects.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.calmingBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people,
                  color: AppTheme.calmingBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Community Challenges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (challenges.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No active challenges',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          else
            ...challenges
                .map(_buildChallengeCard)
                ,
        ],
      ),
    );
  }

  Widget _buildChallengeCard(final gamification.SocialChallenge challenge) {
    final userProgress =
        challenge.userProgress[_gamificationService.userProgress.userId] ?? 0;
    final progress = (userProgress / challenge.target).clamp(0.0, 1.0);
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.calmingBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.calmingBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warmAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${challenge.reward} pts',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.warmAccent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress: $userProgress/${challenge.target}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.calmingBlue),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$daysLeft days left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: daysLeft < 3 ? AppTheme.warmAccent : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${challenge.participants.length} participants',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              if (!challenge.participants
                  .contains(_gamificationService.userProgress.userId))
                ElevatedButton(
                  onPressed: () => _joinChallenge(challenge.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.calmingBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                  ),
                  child: const Text('Join'),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.trustGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Joined',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.trustGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations() {
    final recommendations =
        _personalizationService.getPersonalizedRecommendations();

    return GlassmorphismEffects.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.trustGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: AppTheme.trustGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Personalized Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendations.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppTheme.trustGreen,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re doing great!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.trustGreen,
                        ),
                  ),
                ],
              ),
            )
          else
            ...recommendations
                .take(3)
                .map(_buildRecommendationCard)
                ,
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      final personalization.PersonalizedRecommendation recommendation) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(recommendation.priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(recommendation.priority).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(recommendation.priority)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(recommendation.confidence * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getPriorityColor(recommendation.priority),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.reasoning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _handleRecommendation(recommendation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPriorityColor(recommendation.priority),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 28),
                ),
                child: const Text('Do'),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildLeaderboardSection() {
    final leaderboard = _gamificationService.leaderboard;

    return GlassmorphismEffects.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warmAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  color: AppTheme.warmAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Community Leaderboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...leaderboard
              .take(5)
              .map(_buildLeaderboardEntry)
              ,
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(final gamification.LeaderboardEntry entry) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.rank <= 3
            ? _getRankColor(entry.rank).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.rank <= 3
              ? _getRankColor(entry.rank).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: entry.rank <= 3 ? _getRankColor(entry.rank) : Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                entry.rank <= 3 ? _getRankEmoji(entry.rank) : '${entry.rank}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: entry.rank <= 3 ? 16 : 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.avatar,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Level ${entry.level} • ${entry.points} points',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  // Helper methods

  Color _getRarityColor(final gamification.AchievementRarity rarity) {
    switch (rarity) {
      case gamification.AchievementRarity.common:
        return Colors.grey;
      case gamification.AchievementRarity.uncommon:
        return AppTheme.trustGreen;
      case gamification.AchievementRarity.rare:
        return AppTheme.calmingBlue;
      case gamification.AchievementRarity.epic:
        return AppTheme.empathyPurple;
      case gamification.AchievementRarity.legendary:
        return AppTheme.warmAccent;
    }
  }

  Color _getPriorityColor(final dynamic priority) {
    // Handle both gamification and personalization priority types
    if (priority.toString().contains('low')) {
      return AppTheme.trustGreen;
    } else if (priority.toString().contains('medium')) {
      return AppTheme.warmAccent;
    } else if (priority.toString().contains('high')) {
      return AppTheme.calmingBlue;
    }
    return AppTheme.trustGreen; // Default
  }

  Color _getRankColor(final int rank) {
    switch (rank) {
      case 1:
        return AppTheme.warmAccent; // Gold
      case 2:
        return AppTheme.safetyGrey; // Silver
      case 3:
        return AppTheme.trustGreen; // Bronze
      default:
        return Colors.grey;
    }
  }

  String _getRankEmoji(final int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  Future<void> _joinChallenge(final String challengeId) async {
    try {
      await _gamificationService.joinChallenge(challengeId);
      HapticUtils.successFeedback(context);
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined challenge successfully!'),
          backgroundColor: AppTheme.trustGreen,
        ),
      );
    } catch (e) {
      HapticUtils.errorFeedback(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join challenge'),
          backgroundColor: AppTheme.safetyGrey,
        ),
      );
    }
  }

  void _handleRecommendation(
      final personalization.PersonalizedRecommendation recommendation) {
    HapticUtils.lightImpact(context);

    // Record behavior
    _personalizationService.recordBehavior(personalization.UserBehavior(
      action: 'recommendation_acted',
      timestamp: DateTime.now(),
      context: {'recommendation_id': recommendation.action},
    ));

    // Award points (using a default value since points property doesn't exist)
    _gamificationService.awardPoints('recommendation_followed',
        customPoints: 50);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great choice! +50 points'),
        backgroundColor: AppTheme.trustGreen,
      ),
    );

    setState(() {});
  }
}
