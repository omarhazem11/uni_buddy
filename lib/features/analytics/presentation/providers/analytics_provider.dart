import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/entities/task_analytics_entity.dart';
import '../../domain/usecases/compute_task_analytics.dart';

final taskAnalyticsProvider = Provider<TaskAnalyticsEntity>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final tasks = tasksAsync.value ?? [];
  return computeTaskAnalytics(tasks);
});
