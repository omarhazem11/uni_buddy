import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/achievements_remote_datasource.dart';
import '../../data/repositories/achievements_repository_impl.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/achievements_repository.dart';

final achievementsRemoteDataSourceProvider = Provider<AchievementsRemoteDataSource>((ref) {
  ref.watch(currentUidProvider);
  return AchievementsRemoteDataSourceImpl();
});

final achievementsRepositoryProvider = Provider<AchievementsRepository>((ref) {
  return AchievementsRepositoryImpl(
    remoteDataSource: ref.watch(achievementsRemoteDataSourceProvider),
  );
});

final userProgressProvider = StreamProvider<UserProgressEntity>((ref) {
  return ref.watch(achievementsRepositoryProvider).watchProgress();
});

final badgesProvider = StreamProvider<List<BadgeEntity>>((ref) {
  return ref.watch(achievementsRepositoryProvider).watchBadges();
});

class AchievementsActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final AchievementsRepository _repository;

  AchievementsActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> recordAppOpen() => _run(_repository.recordAppOpen);

  Future<void> recordTabVisit(String tabName) => _run(() => _repository.recordTabVisit(tabName));

  Future<void> recordTaskCompleted({required bool wasEarly}) {
    return _run(() => _repository.recordTaskCompleted(wasEarly: wasEarly));
  }

  Future<void> recordPlannerItemAdded({required DateTime itemDate}) {
    return _run(() => _repository.recordPlannerItemAdded(itemDate: itemDate));
  }

  Future<void> recordDuplicateDayUsed() => _run(_repository.recordDuplicateDayUsed);

  /// Returns the badges newly unlocked by this call (empty if none, or on
  /// failure) — the caller uses this to decide whether to celebrate.
  Future<List<BadgeEntity>> recalculateBadges() async {
    final result = await _repository.recalculateBadges();
    return result.fold((_) => const [], (badges) => badges);
  }

  Future<void> _run(Future<Either<Failure, void>> Function() action) async {
    state = const AsyncValue.loading();
    final result = await action();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

final achievementsActionsProvider =
    StateNotifierProvider<AchievementsActionsNotifier, AsyncValue<void>>((ref) {
  return AchievementsActionsNotifier(ref.watch(achievementsRepositoryProvider));
});
