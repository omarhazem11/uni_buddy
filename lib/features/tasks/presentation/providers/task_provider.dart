import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  // Depending on the uid (not just reading it) means switching accounts
  // disposes this provider and its cached Firestore subscription — see
  // currentUidProvider's doc comment for why that matters.
  ref.watch(currentUidProvider);
  return TaskRemoteDataSourceImpl();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  );
});

// Live task list — the dashboard and TasksPage both watch this.
final tasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

class TaskActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repository;

  TaskActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> addTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
    Duration? reminderOffset,
    DateTime? customReminderDateTime,
  }) async {
    final task = TaskEntity(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      reminderOffset: reminderOffset,
      customReminderDateTime: customReminderDateTime,
      createdAt: DateTime.now(),
    );
    final ok = await _run(() => _repository.addTask(task));
    if (ok) await NotificationService.scheduleTaskReminder(task);
    return ok;
  }

  Future<bool> updateTask(TaskEntity task) async {
    final ok = await _run(() => _repository.updateTask(task));
    if (ok) {
      await NotificationService.cancelTaskReminder(task.id);
      if (!task.isCompleted) {
        await NotificationService.scheduleTaskReminder(task);
      }
    }
    return ok;
  }

  Future<bool> toggleComplete(String taskId, bool isCompleted) async {
    final ok = await _run(() => _repository.toggleComplete(taskId, isCompleted));
    if (ok && isCompleted) {
      await NotificationService.cancelTaskReminder(taskId);
    }
    return ok;
  }

  Future<bool> deleteTask(String taskId) async {
    final ok = await _run(() => _repository.deleteTask(taskId));
    if (ok) await NotificationService.cancelTaskReminder(taskId);
    return ok;
  }

  Future<bool> _run(Future<Either<Failure, void>> Function() action) async {
    state = const AsyncValue.loading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final taskActionsProvider =
    StateNotifierProvider<TaskActionsNotifier, AsyncValue<void>>((ref) {
  return TaskActionsNotifier(ref.watch(taskRepositoryProvider));
});
