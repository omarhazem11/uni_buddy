import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:uni_verse/features/auth/domain/entities/user_entity.dart';
import 'package:uni_verse/features/auth/presentation/providers/auth_provider.dart';
import 'package:uni_verse/features/home/presentation/pages/dashboard_page.dart';
import 'package:uni_verse/features/notes/presentation/providers/note_provider.dart';
import 'package:uni_verse/features/onboarding/domain/entities/user_type.dart';
import 'package:uni_verse/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:uni_verse/features/onboarding/presentation/pages/coming_soon_page.dart';
import 'package:uni_verse/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:uni_verse/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:uni_verse/features/planner/domain/entities/planner_settings_entity.dart';
import 'package:uni_verse/features/planner/domain/entities/schedule_item_entity.dart';
import 'package:uni_verse/features/planner/domain/repositories/planner_repository.dart';
import 'package:uni_verse/features/planner/presentation/providers/planner_provider.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
import 'package:uni_verse/main.dart' as app;
import 'fakes/fake_achievements_datasource.dart';
import 'fakes/fake_note_datasource.dart';

/// In-memory stand-in for the Firestore-backed onboarding choice — no local
/// caching involved, matching production now that userType lives only in
/// Firestore.
class _FakeOnboardingRepository implements OnboardingRepository {
  UserType? userType;

  _FakeOnboardingRepository([this.userType]);

  @override
  Future<UserType?> getUserType() async => userType;

  @override
  Future<void> setUserType(UserType type) async => userType = type;
}

/// Only the methods DashboardPage's tree actually touches on render need a
/// real implementation — everything else is an unreachable write path.
class _FakePlannerRepository implements PlannerRepository {
  @override
  Stream<List<ScheduleItemEntity>> watchItemsForDate(DateTime date) => Stream.value(const []);

  @override
  Stream<List<ScheduleItemEntity>> watchItemsInRange(DateTime start, DateTime end) => Stream.value(const []);

  @override
  Stream<PlannerSettingsEntity> watchSettings() => Stream.value(const PlannerSettingsEntity());

  @override
  Future<Either<Failure, void>> addItem(ScheduleItemEntity item) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity settings) async => throw UnimplementedError();
}

Future<void> _pumpAuthGate(WidgetTester tester, {UserType? savedUserType}) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(const UserEntity(id: '1', email: 's@t.com', displayName: 'Sara')),
        ),
        onboardingRepositoryProvider.overrideWithValue(_FakeOnboardingRepository(savedUserType)),
        tasksStreamProvider.overrideWith((ref) => Stream.value(const <TaskEntity>[])),
        plannerRepositoryProvider.overrideWithValue(_FakePlannerRepository()),
        achievementsRemoteDataSourceProvider.overrideWithValue(FakeAchievementsDataSource()),
        noteRemoteDataSourceProvider.overrideWithValue(FakeNoteRemoteDataSource()),
      ],
      child: const MaterialApp(home: app.AuthGate()),
    ),
  );
  // AuthGate holds a fixed 2s splash timer before it evaluates auth/onboarding state.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a returning student user is routed straight to the dashboard, skipping onboarding',
      (tester) async {
    await _pumpAuthGate(tester, savedUserType: UserType.student);

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  testWidgets('a first-time user with no saved choice sees the onboarding question', (tester) async {
    await _pumpAuthGate(tester);

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.byType(DashboardPage), findsNothing);
  });

  testWidgets('a returning "searching" user is routed to the coming-soon page, not onboarding',
      (tester) async {
    await _pumpAuthGate(tester, savedUserType: UserType.searching);

    expect(find.byType(ComingSoonPage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  testWidgets('choosing a type on the onboarding page persists it through the repository, not a local cache',
      (tester) async {
    await _pumpAuthGate(tester);
    expect(find.byType(OnboardingPage), findsOneWidget);

    await tester.tap(find.text("I'm a student"));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
  });
}
