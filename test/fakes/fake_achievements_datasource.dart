import 'dart:async';

import 'package:uni_verse/features/achievements/data/datasources/achievements_remote_datasource.dart';
import 'package:uni_verse/features/achievements/data/models/user_progress_model.dart';
import 'package:uni_verse/features/achievements/domain/streak_calculator.dart';

/// Faithful in-memory achievements datasource shared across test files —
/// the real AchievementsRepositoryImpl runs on top of this, so tests
/// exercise the actual production recalculation logic rather than a
/// hand-rolled re-implementation of it. Any widget test that pumps a page
/// touching Tasks/Planner/Dashboard needs this overridden, since those
/// features all call into achievements now.
class FakeAchievementsDataSource implements AchievementsRemoteDataSource {
  UserProgressModel progress = UserProgressModel.initial();
  final _controller = StreamController<UserProgressModel>.broadcast();

  void _emit() => _controller.add(progress);

  @override
  Stream<UserProgressModel> watchProgress() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> recordAppOpen() async {
    final today = DateTime.now();
    final update = computeStreakUpdate(
      lastActiveDate: progress.lastActiveDate,
      currentStreak: progress.currentStreak,
      longestStreak: progress.longestStreak,
      today: today,
    );
    if (!update.changed) return;
    progress = UserProgressModel.fromEntity(progress.copyWith(
      currentStreak: update.currentStreak,
      longestStreak: update.longestStreak,
      lastActiveDate: DateTime(today.year, today.month, today.day),
    ));
    _emit();
  }

  @override
  Future<void> recordTabVisit(String tabName) async {
    progress = UserProgressModel.fromEntity(
      progress.copyWith(visitedTabs: {...progress.visitedTabs, tabName}),
    );
    _emit();
  }

  @override
  Future<void> recordTaskCompleted({required bool wasEarly}) async {
    progress = UserProgressModel.fromEntity(progress.copyWith(
      tasksCompletedCount: progress.tasksCompletedCount + 1,
      tasksCompletedEarlyCount: progress.tasksCompletedEarlyCount + (wasEarly ? 1 : 0),
    ));
    _emit();
  }

  @override
  Future<void> recordPlannerItemAdded({required DateTime itemDate}) async {
    progress = UserProgressModel.fromEntity(progress.copyWith(
      plannerItemsCount: progress.plannerItemsCount + 1,
      maxScheduledDaysInAWeek: progress.maxScheduledDaysInAWeek < 1 ? 1 : progress.maxScheduledDaysInAWeek,
    ));
    _emit();
  }

  @override
  Future<void> recordDuplicateDayUsed() async {
    progress = UserProgressModel.fromEntity(progress.copyWith(hasUsedDuplicateDay: true));
    _emit();
  }

  @override
  Future<void> unlockBadgesAndAwardPoints(Map<String, DateTime> newUnlocks, int pointsToAdd) async {
    progress = UserProgressModel.fromEntity(progress.copyWith(
      totalPoints: progress.totalPoints + pointsToAdd,
      badgeUnlockedAt: {...progress.badgeUnlockedAt, ...newUnlocks},
    ));
    _emit();
  }
}
