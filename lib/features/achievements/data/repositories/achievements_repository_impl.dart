import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/badge_rules.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/achievements_repository.dart';
import '../badge_catalog.dart';
import '../datasources/achievements_remote_datasource.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  final AchievementsRemoteDataSource remoteDataSource;

  AchievementsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserProgressEntity> watchProgress() => remoteDataSource.watchProgress();

  @override
  Stream<List<BadgeEntity>> watchBadges() {
    return remoteDataSource.watchProgress().map((progress) {
      return badgeCatalog.map((badge) {
        final unlockedAt = progress.badgeUnlockedAt[badge.id];
        return badge.copyWith(isUnlocked: unlockedAt != null, unlockedAt: unlockedAt);
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> recordAppOpen() => _run(remoteDataSource.recordAppOpen);

  @override
  Future<Either<Failure, void>> recordTabVisit(String tabName) {
    return _run(() => remoteDataSource.recordTabVisit(tabName));
  }

  @override
  Future<Either<Failure, void>> recordTaskCompleted({required bool wasEarly}) {
    return _run(() => remoteDataSource.recordTaskCompleted(wasEarly: wasEarly));
  }

  @override
  Future<Either<Failure, void>> recordPlannerItemAdded({required DateTime itemDate}) {
    return _run(() => remoteDataSource.recordPlannerItemAdded(itemDate: itemDate));
  }

  @override
  Future<Either<Failure, void>> recordDuplicateDayUsed() {
    return _run(remoteDataSource.recordDuplicateDayUsed);
  }

  @override
  Future<Either<Failure, List<BadgeEntity>>> recalculateBadges() async {
    try {
      final progress = await remoteDataSource.watchProgress().first;
      final now = DateTime.now();

      final newlyUnlocked = <BadgeEntity>[];
      final newUnlocks = <String, DateTime>{};
      for (final badge in badgeCatalog) {
        final alreadyUnlocked = progress.badgeUnlockedAt.containsKey(badge.id);
        if (alreadyUnlocked) continue;
        final rule = badgeRules[badge.id];
        if (rule != null && rule(progress)) {
          newUnlocks[badge.id] = now;
          newlyUnlocked.add(badge.copyWith(isUnlocked: true, unlockedAt: now));
        }
      }

      if (newUnlocks.isEmpty) return const Right([]);

      final pointsAwarded = newlyUnlocked.fold<int>(0, (sum, b) => sum + b.points);
      await remoteDataSource.unlockBadgesAndAwardPoints(newUnlocks, pointsAwarded);
      return Right(newlyUnlocked);
    } catch (e) {
      return Left(AchievementsFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } catch (e) {
      return Left(AchievementsFailure(e.toString()));
    }
  }
}
