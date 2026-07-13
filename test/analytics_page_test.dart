import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/features/analytics/presentation/pages/analytics_page.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';

Future<void> _pumpAnalytics(WidgetTester tester, List<TaskEntity> tasks) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [tasksStreamProvider.overrideWith((ref) => Stream.value(tasks))],
      child: const MaterialApp(home: AnalyticsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state shows friendly copy instead of bare zeros', (tester) async {
    await _pumpAnalytics(tester, []);

    expect(find.text('Get started! 🌱'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.textContaining('great job'), findsOneWidget);
    expect(find.textContaining('Complete some tasks to see your trends'), findsOneWidget);
    expect(find.textContaining('Add tasks to see your breakdown'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('populated tasks compute completion rate and on-time count', (tester) async {
    final now = DateTime.now();
    final tasks = [
      TaskEntity(
        id: '1',
        title: 'Finish essay',
        category: TaskCategory.assignment,
        isCompleted: true,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now,
      ),
      TaskEntity(
        id: '2',
        title: 'Study for exam',
        category: TaskCategory.exam,
        createdAt: now,
      ),
    ];
    await _pumpAnalytics(tester, tasks);

    expect(find.text('50%'), findsOneWidget);
    expect(find.textContaining('On Time (1)'), findsOneWidget);
    expect(find.text('Get started! 🌱'), findsNothing);

    // Assignment/Exam have tasks (1 each); Project/Other don't — those
    // untouched categories must not render a bare "0".
    expect(find.text('0'), findsNothing);
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('shows a back button when pushed on top of another page', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tasksStreamProvider.overrideWith((ref) => Stream.value(const <TaskEntity>[]))],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                  ),
                  child: const Text('Open Analytics'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Analytics'));
    await tester.pumpAndSettle();

    expect(find.byType(AnalyticsPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsPage), findsNothing);
  });
}
