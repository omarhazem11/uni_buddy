import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/features/analytics/domain/usecases/compute_task_analytics.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';

TaskEntity _task({
  required String id,
  bool isCompleted = false,
  DateTime? dueDate,
  TaskCategory category = TaskCategory.other,
  DateTime? createdAt,
}) {
  return TaskEntity(
    id: id,
    title: 'Task $id',
    category: category,
    dueDate: dueDate,
    isCompleted: isCompleted,
    createdAt: createdAt ?? DateTime.now(),
  );
}

void main() {
  group('computeTaskAnalytics', () {
    test('empty task list returns all-zero analytics with 8 empty weeks', () {
      final result = computeTaskAnalytics([]);
      expect(result.totalTasks, 0);
      expect(result.completedTasks, 0);
      expect(result.completionRate, 0.0);
      expect(result.weeklyCompletions.length, 8);
      expect(result.weeklyCompletions.every((w) => w.completedCount == 0), isTrue);
      expect(result.categoryBreakdown.values.every((c) => c == 0), isTrue);
    });

    test('mix of on-time, overdue-completed, and still-overdue-incomplete tasks', () {
      final now = DateTime.now();
      final tasks = [
        _task(id: 'ontime1', isCompleted: true, dueDate: now.add(const Duration(days: 3))),
        _task(id: 'ontime2', isCompleted: true),
        _task(id: 'late1', isCompleted: true, dueDate: now.subtract(const Duration(days: 2))),
        _task(id: 'overdueIncomplete1', isCompleted: false, dueDate: now.subtract(const Duration(days: 1))),
        _task(id: 'notYetDue', isCompleted: false, dueDate: now.add(const Duration(days: 5))),
      ];

      final result = computeTaskAnalytics(tasks);
      expect(result.totalTasks, 5);
      expect(result.completedTasks, 3);
      expect(result.onTimeCompletions, 2);
      expect(result.overdueCompletions, 1);
      expect(result.stillOverdueIncomplete, 1);
      expect(result.completionRate, closeTo(3 / 5, 0.0001));
    });

    test('category breakdown counts every task regardless of completion', () {
      final tasks = [
        _task(id: '1', category: TaskCategory.assignment),
        _task(id: '2', category: TaskCategory.assignment, isCompleted: true),
        _task(id: '3', category: TaskCategory.exam),
        _task(id: '4', category: TaskCategory.other),
      ];
      final result = computeTaskAnalytics(tasks);
      expect(result.categoryBreakdown[TaskCategory.assignment], 2);
      expect(result.categoryBreakdown[TaskCategory.exam], 1);
      expect(result.categoryBreakdown[TaskCategory.project], 0);
      expect(result.categoryBreakdown[TaskCategory.other], 1);
    });

    test('weekly completions bucket completed tasks by due-date week, oldest first', () {
      final now = DateTime.now();
      final tasks = [
        _task(id: 'thisWeek', isCompleted: true, dueDate: now),
        _task(id: 'oldWeek', isCompleted: true, dueDate: now.subtract(const Duration(days: 49))),
        _task(id: 'incompleteThisWeek', dueDate: now),
      ];

      final result = computeTaskAnalytics(tasks);
      expect(result.weeklyCompletions.length, 8);
      expect(result.weeklyCompletions.first.completedCount, 1);
      expect(result.weeklyCompletions.last.completedCount, 1);
      final totalBucketed = result.weeklyCompletions.fold<int>(0, (sum, w) => sum + w.completedCount);
      expect(totalBucketed, 2);
    });

    test('a completion older than the 8-week window folds into the oldest bar rather than vanishing', () {
      final now = DateTime.now();
      final tasks = [
        _task(id: 'thisWeek', isCompleted: true, dueDate: now),
        _task(id: 'ancient', isCompleted: true, dueDate: now.subtract(const Duration(days: 400))),
      ];

      final result = computeTaskAnalytics(tasks);
      final totalBucketed = result.weeklyCompletions.fold<int>(0, (sum, w) => sum + w.completedCount);
      // Every completed task must be represented on the chart — otherwise
      // "Tasks Completed" and the chart's totals silently disagree.
      expect(totalBucketed, result.completedTasks);
      expect(result.weeklyCompletions.first.completedCount, 1);
      expect(result.weeklyCompletions.last.completedCount, 1);
    });

    test('task with no due date falls back to createdAt week for bucketing', () {
      final now = DateTime.now();
      final tasks = [
        _task(id: 'noDueDate', isCompleted: true, createdAt: now),
      ];
      final result = computeTaskAnalytics(tasks);
      expect(result.weeklyCompletions.last.completedCount, 1);
    });
  });
}
