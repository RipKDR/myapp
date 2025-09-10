import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ndis_connect/controllers/gamification_controller.dart';
import 'package:ndis_connect/services/advanced_gamification_service.dart';

import 'gamification_controller_test.mocks.dart';

@GenerateMocks([AdvancedGamificationService])
void main() {
  group('GamificationController Tests', () {
    late GamificationController gamificationController;
    late MockAdvancedGamificationService mockGamificationService;

    setUp(() {
      mockGamificationService = MockAdvancedGamificationService();
      gamificationController = GamificationController();
      // Inject mock service (would need dependency injection setup)
    });

    group('Points System', () {
      test('should initialize with zero points', () {
        expect(gamificationController.totalPoints, 0);
        expect(gamificationController.currentLevel, 1);
      });

      test('should award points for completing tasks', () async {
        // Arrange
        when(
          mockGamificationService.awardPoints(any, any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.awardPoints(100, 'task_completion');

        // Assert
        expect(gamificationController.totalPoints, 100);
        verify(
          mockGamificationService.awardPoints(100, 'task_completion'),
        ).called(1);
      });

      test('should calculate level based on points', () {
        // Test level calculation logic
        gamificationController.totalPoints = 500;
        expect(gamificationController.currentLevel, greaterThan(1));
      });

      test('should track points history', () async {
        // Arrange
        when(
          mockGamificationService.awardPoints(any, any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.awardPoints(50, 'appointment_booking');
        await gamificationController.awardPoints(75, 'budget_tracking');

        // Assert
        expect(gamificationController.pointsHistory.length, 2);
        expect(gamificationController.pointsHistory.first.amount, 50);
        expect(gamificationController.pointsHistory.last.amount, 75);
      });
    });

    group('Streaks System', () {
      test('should initialize with zero streak', () {
        expect(gamificationController.currentStreak, 0);
        expect(gamificationController.longestStreak, 0);
      });

      test('should increment streak for daily activities', () async {
        // Arrange
        when(
          mockGamificationService.updateStreak(any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.updateStreak('daily_login');

        // Assert
        expect(gamificationController.currentStreak, 1);
        verify(mockGamificationService.updateStreak('daily_login')).called(1);
      });

      test('should reset streak when activity is missed', () async {
        // Arrange
        gamificationController.currentStreak = 5;
        when(
          mockGamificationService.resetStreak(),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.resetStreak();

        // Assert
        expect(gamificationController.currentStreak, 0);
        expect(gamificationController.longestStreak, 5);
      });

      test('should track streak milestones', () async {
        // Arrange
        when(
          mockGamificationService.updateStreak(any),
        ).thenAnswer((_) async => true);

        // Act
        for (int i = 0; i < 7; i++) {
          await gamificationController.updateStreak('daily_login');
        }

        // Assert
        expect(gamificationController.currentStreak, 7);
        expect(
          gamificationController.achievements.any(
            (final a) => a.type == 'streak_7_days',
          ),
          true,
        );
      });
    });

    group('Badges and Achievements', () {
      test('should initialize with empty achievements list', () {
        expect(gamificationController.achievements, isEmpty);
      });

      test('should unlock new achievements', () async {
        // Arrange
        when(
          mockGamificationService.unlockAchievement(any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.unlockAchievement('first_appointment');

        // Assert
        expect(gamificationController.achievements.length, 1);
        expect(
          gamificationController.achievements.first.type,
          'first_appointment',
        );
        verify(
          mockGamificationService.unlockAchievement('first_appointment'),
        ).called(1);
      });

      test('should track achievement progress', () async {
        // Arrange
        when(
          mockGamificationService.updateAchievementProgress(any, any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.updateAchievementProgress(
          'appointment_master',
          3,
        );

        // Assert
        final achievement = gamificationController.achievements.firstWhere(
          (final a) => a.type == 'appointment_master',
        );
        expect(achievement.progress, 3);
      });

      test('should not duplicate achievements', () async {
        // Arrange
        when(
          mockGamificationService.unlockAchievement(any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.unlockAchievement('first_appointment');
        await gamificationController.unlockAchievement('first_appointment');

        // Assert
        expect(gamificationController.achievements.length, 1);
      });
    });

    group('Challenges', () {
      test('should initialize with empty challenges list', () {
        expect(gamificationController.activeChallenges, isEmpty);
      });

      test('should add new challenges', () async {
        // Arrange
        when(
          mockGamificationService.addChallenge(any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.addChallenge({
          'id': 'weekly_goals',
          'title': 'Complete 5 tasks this week',
          'target': 5,
          'reward': 200,
          'deadline': DateTime.now().add(const Duration(days: 7)),
        });

        // Assert
        expect(gamificationController.activeChallenges.length, 1);
        expect(
          gamificationController.activeChallenges.first.title,
          'Complete 5 tasks this week',
        );
      });

      test('should complete challenges and award rewards', () async {
        // Arrange
        when(
          mockGamificationService.completeChallenge(any),
        ).thenAnswer((_) async => true);
        when(
          mockGamificationService.awardPoints(any, any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.completeChallenge('weekly_goals');

        // Assert
        expect(gamificationController.completedChallenges.length, 1);
        verify(
          mockGamificationService.completeChallenge('weekly_goals'),
        ).called(1);
      });

      test('should remove expired challenges', () async {
        // Arrange
        when(
          mockGamificationService.removeExpiredChallenges(),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.removeExpiredChallenges();

        // Assert
        verify(mockGamificationService.removeExpiredChallenges()).called(1);
      });
    });

    group('Leaderboards', () {
      test('should initialize with empty leaderboard', () {
        expect(gamificationController.leaderboard, isEmpty);
      });

      test('should update leaderboard with user rankings', () async {
        // Arrange
        when(mockGamificationService.updateLeaderboard()).thenAnswer(
          (_) async => [
            {'userId': 'user1', 'points': 1000, 'rank': 1},
            {'userId': 'user2', 'points': 800, 'rank': 2},
          ],
        );

        // Act
        await gamificationController.updateLeaderboard();

        // Assert
        expect(gamificationController.leaderboard.length, 2);
        expect(gamificationController.leaderboard.first['rank'], 1);
      });

      test('should get user rank in leaderboard', () async {
        // Arrange
        gamificationController.leaderboard = [
          {'userId': 'user1', 'points': 1000, 'rank': 1},
          {'userId': 'current_user', 'points': 800, 'rank': 2},
          {'userId': 'user3', 'points': 600, 'rank': 3},
        ];

        // Act
        final userRank = gamificationController.getUserRank('current_user');

        // Assert
        expect(userRank, 2);
      });
    });

    group('Data Persistence', () {
      test('should save gamification data', () async {
        // Arrange
        when(mockGamificationService.saveData()).thenAnswer((_) async => true);

        // Act
        final result = await gamificationController.saveData();

        // Assert
        expect(result, true);
        verify(mockGamificationService.saveData()).called(1);
      });

      test('should load gamification data', () async {
        // Arrange
        when(mockGamificationService.loadData()).thenAnswer(
          (_) async => {
            'totalPoints': 500,
            'currentStreak': 3,
            'achievements': [],
            'challenges': [],
          },
        );

        // Act
        await gamificationController.loadData();

        // Assert
        expect(gamificationController.totalPoints, 500);
        expect(gamificationController.currentStreak, 3);
        verify(mockGamificationService.loadData()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle service errors gracefully', () async {
        // Arrange
        when(
          mockGamificationService.awardPoints(any, any),
        ).thenThrow(Exception('Service unavailable'));

        // Act
        await gamificationController.awardPoints(100, 'test');

        // Assert
        expect(gamificationController.errorMessage, isNotNull);
        expect(
          gamificationController.errorMessage,
          contains('Service unavailable'),
        );
      });

      test('should clear error messages on successful operations', () async {
        // Arrange
        gamificationController.errorMessage = 'Previous error';
        when(
          mockGamificationService.awardPoints(any, any),
        ).thenAnswer((_) async => true);

        // Act
        await gamificationController.awardPoints(100, 'test');

        // Assert
        expect(gamificationController.errorMessage, null);
      });
    });
  });
}
