import 'package:equatable/equatable.dart';
import '../../../tasks/domain/entities/task_entity.dart';

class WeeklyCompletionEntity extends Equatable {
  final DateTime weekStart;
  final int completedCount;

  const WeeklyCompletionEntity({required this.weekStart, required this.completedCount});

  @override
  List<Object?> get props => [weekStart, completedCount];
}

class TaskAnalyticsEntity extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int onTimeCompletions;
  final int overdueCompletions;
  final int stillOverdueIncomplete;
  final double completionRate;
  final Map<TaskCategory, int> categoryBreakdown;
  final List<WeeklyCompletionEntity> weeklyCompletions;

  const TaskAnalyticsEntity({
    required this.totalTasks,
    required this.completedTasks,
    required this.onTimeCompletions,
    required this.overdueCompletions,
    required this.stillOverdueIncomplete,
    required this.completionRate,
    required this.categoryBreakdown,
    required this.weeklyCompletions,
  });

  @override
  List<Object?> get props => [
        totalTasks,
        completedTasks,
        onTimeCompletions,
        overdueCompletions,
        stillOverdueIncomplete,
        completionRate,
        categoryBreakdown,
        weeklyCompletions,
      ];
}
