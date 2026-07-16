import '../../domain/entities/schedule_item_entity.dart';
import '../providers/planner_provider.dart';

/// Extracted out of AddScheduleItemSheet purely to keep that file under
/// the 150-line limit — builds and dispatches the add/update call.
/// Accepts the notifier directly so callers can capture it before
/// Navigator.pop() — WidgetRef is invalidated after the widget disposes.
Future<bool> saveScheduleItemFromSheet({
  required PlannerActionsNotifier notifier,
  required ScheduleItemEntity? existingItem,
  required String title,
  required String? description,
  required DateTime date,
  required DateTime startTime,
  required DateTime endTime,
  required String colorHex,
  required String emoji,
}) {
  if (existingItem != null) {
    return notifier.updateItem(existingItem.copyWith(
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      colorHex: colorHex,
      emoji: emoji,
    ));
  }

  return notifier.addItem(
    title: title,
    description: description,
    date: date,
    startTime: startTime,
    endTime: endTime,
    colorHex: colorHex,
    emoji: emoji,
  );
}
