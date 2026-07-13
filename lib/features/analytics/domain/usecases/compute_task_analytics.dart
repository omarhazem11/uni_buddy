import '../../../tasks/domain/entities/task_entity.dart';
import '../entities/task_analytics_entity.dart';

const _weeksTracked = 8;

/// TaskEntity has no completedAt timestamp, so "on time" / "overdue
/// completion" can't be reconstructed exactly from history. The best
/// available proxy: a completed task counts as on-time unless its due date
/// has already passed as of now — if the due date is still in the future
/// (or there's no due date at all), it couldn't have been late. Weekly
/// buckets for the chart use the same proxy timestamp (dueDate, falling
/// back to createdAt) since no other date reflects when work was done.
TaskAnalyticsEntity computeTaskAnalytics(List<TaskEntity> tasks) {
  final now = DateTime.now();
  final totalTasks = tasks.length;
  final completedTasks = tasks.where((t) => t.isCompleted).length;

  var onTime = 0;
  var overdueCompleted = 0;
  var stillOverdueIncomplete = 0;

  for (final task in tasks) {
    if (task.isCompleted) {
      if (task.dueDate == null || !now.isAfter(task.dueDate!)) {
        onTime++;
      } else {
        overdueCompleted++;
      }
    } else if (task.dueDate != null && task.dueDate!.isBefore(now)) {
      stillOverdueIncomplete++;
    }
  }

  final categoryBreakdown = <TaskCategory, int>{for (final c in TaskCategory.values) c: 0};
  for (final task in tasks) {
    categoryBreakdown[task.category] = (categoryBreakdown[task.category] ?? 0) + 1;
  }

  return TaskAnalyticsEntity(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    onTimeCompletions: onTime,
    overdueCompletions: overdueCompleted,
    stillOverdueIncomplete: stillOverdueIncomplete,
    completionRate: totalTasks == 0 ? 0.0 : completedTasks / totalTasks,
    categoryBreakdown: categoryBreakdown,
    weeklyCompletions: _computeWeeklyCompletions(tasks, now),
  );
}

DateTime _weekStart(DateTime date) {
  final dateOnly = DateTime(date.year, date.month, date.day);
  return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
}

List<WeeklyCompletionEntity> _computeWeeklyCompletions(List<TaskEntity> tasks, DateTime now) {
  final currentWeekStart = _weekStart(now);
  final weekStarts = List.generate(
    _weeksTracked,
    (i) => currentWeekStart.subtract(Duration(days: 7 * (_weeksTracked - 1 - i))),
  );
  final oldestTrackedWeek = weekStarts.first;
  final counts = {for (final w in weekStarts) w: 0};

  for (final task in tasks) {
    if (!task.isCompleted) continue;
    final proxyDate = task.dueDate ?? task.createdAt;
    var bucket = _weekStart(proxyDate);
    // A completion whose proxy date predates the tracked window would
    // otherwise vanish from the chart while still counting toward the
    // "Tasks Completed" summary — fold it into the oldest bar instead so
    // every completed task is represented somewhere and the two numbers
    // never silently disagree.
    if (bucket.isBefore(oldestTrackedWeek)) bucket = oldestTrackedWeek;
    if (counts.containsKey(bucket)) {
      counts[bucket] = counts[bucket]! + 1;
    }
  }

  return weekStarts.map((w) => WeeklyCompletionEntity(weekStart: w, completedCount: counts[w]!)).toList();
}
