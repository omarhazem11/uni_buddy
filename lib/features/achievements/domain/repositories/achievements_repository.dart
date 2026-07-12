import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/badge_entity.dart';
import '../entities/user_progress_entity.dart';

abstract class AchievementsRepository {
  Stream<UserProgressEntity> watchProgress();

  /// Merges the static badge catalog with unlock status from progress.
  Stream<List<BadgeEntity>> watchBadges();

  /// Call once per session start — updates streak logic.
  Future<Either<Failure, void>> recordAppOpen();

  Future<Either<Failure, void>> recordTabVisit(String tabName);

  Future<Either<Failure, void>> recordTaskCompleted({required bool wasEarly});

  // Needs the item's own date (not "today") so the "Weekly Planner" badge
  // (items across 5+ distinct days in one week) can be evaluated correctly
  // — items are frequently scheduled for days other than today.
  Future<Either<Failure, void>> recordPlannerItemAdded({required DateTime itemDate});

  Future<Either<Failure, void>> recordDuplicateDayUsed();

  /// Checks all badge conditions against current progress, unlocks any
  /// newly-earned badges, and awards their points. Returns the badges that
  /// were newly unlocked by this call (empty if none).
  Future<Either<Failure, List<BadgeEntity>>> recalculateBadges();
}
