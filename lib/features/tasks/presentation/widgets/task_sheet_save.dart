import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

/// Extracted out of AddTaskSheet purely to keep that file under the
/// 150-line limit — builds and dispatches the add/update call.
/// Accepts the notifier directly so callers can capture it before
/// Navigator.pop() — WidgetRef is invalidated after the widget disposes.
Future<bool> saveTaskFromSheet({
  required TaskActionsNotifier notifier,
  required TaskEntity? existingTask,
  required String title,
  required String? description,
  required TaskPriority priority,
  required TaskCategory category,
  required DateTime? dueDate,
  required Duration? reminderOffset,
  required DateTime? customReminderDateTime,
}) {
  if (existingTask != null) {
    return notifier.updateTask(existingTask.copyWith(
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      clearDueDate: dueDate == null,
      reminderOffset: reminderOffset,
      clearReminderOffset: reminderOffset == null,
      customReminderDateTime: customReminderDateTime,
      clearCustomReminderDateTime: customReminderDateTime == null,
    ));
  }

  return notifier.addTask(
    title: title,
    description: description,
    priority: priority,
    category: category,
    dueDate: dueDate,
    reminderOffset: reminderOffset,
    customReminderDateTime: customReminderDateTime,
  );
}
