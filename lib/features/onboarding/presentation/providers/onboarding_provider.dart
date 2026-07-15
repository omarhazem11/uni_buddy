import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/onboarding_remote_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/repositories/onboarding_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final onboardingRemoteDataSourceProvider = Provider<OnboardingRemoteDataSource>((ref) {
  // Depending on the uid (not just reading it) means switching accounts —
  // or signing out, or deleting the account — disposes this provider and
  // everything downstream of it, instead of leaving a stale onboarding
  // choice cached from whoever was signed in before. There's nothing to
  // manually "clear" on sign-out for the same reason: there's no local
  // cache left to go stale, this always reads straight from Firestore.
  ref.watch(currentUidProvider);
  return OnboardingRemoteDataSourceImpl();
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(
    remoteDataSource: ref.watch(onboardingRemoteDataSourceProvider),
  );
});

// User's saved onboarding choice — null means the question hasn't been
// asked yet for this account. Re-fetched fresh from Firestore whenever the
// signed-in uid changes (see onboardingRemoteDataSourceProvider), so a
// returning user with a saved choice skips straight to the dashboard while
// a different user signing in on the same device correctly sees onboarding.
final userTypeProvider = FutureProvider<UserType?>((ref) async {
  return ref.watch(onboardingRepositoryProvider).getUserType();
});

class OnboardingNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> chooseUserType(UserType type) async {
    state = const AsyncValue.loading();
    final repository = _ref.read(onboardingRepositoryProvider);
    await repository.setUserType(type);
    _ref.invalidate(userTypeProvider);
    state = const AsyncValue.data(null);
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<void>>((ref) {
  return OnboardingNotifier(ref);
});
