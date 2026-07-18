import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/planner_provider.dart';
import '../utils/timeline_math.dart';
import 'day_timeline_empty_state.dart';
import 'schedule_item_block.dart';
import 'task_timeline_block.dart';
import 'timeline_hour_markers.dart';

class DayTimelineView extends ConsumerWidget {
  final DateTime date;

  const DayTimelineView({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(dayItemsProvider(date));
    final settingsAsync = ref.watch(plannerSettingsProvider);
    // Reuses the same tasksStreamProvider the Tasks feature and dashboard
    // watch — Riverpod caches the underlying Firestore stream, so this
    // doesn't open a second listener.
    final tasksAsync = ref.watch(tasksStreamProvider);

    if (!itemsAsync.hasValue || !settingsAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final items = itemsAsync.value!;
    final settings = settingsAsync.value!;
    final normalized = dateOnly(date);
    final tasksToday = (tasksAsync.value ?? [])
        .where((t) => t.dueDate != null && dateOnly(t.dueDate!) == normalized)
        .toList();

    if (items.isEmpty && tasksToday.isEmpty) return const DayTimelineEmptyState();

    final start = settings.dayStartMinutes;
    final end = settings.dayEndMinutes;

    return LayoutBuilder(
      builder: (context, constraints) {
        const contentLeft = timelineLabelWidth + 8.0;
        final contentWidth = constraints.maxWidth - contentLeft;

        // Compute side-by-side columns for overlapping schedule items.
        final scheduleLayouts = computeBlockLayouts(
          items: [
            for (final item in items)
              (id: item.id, start: item.startTime, end: item.endTime),
          ],
          contentLeft: contentLeft,
          contentWidth: contentWidth,
        );

        // Tasks are point-in-time; treat as 30-minute blocks for collision.
        final taskLayouts = computeBlockLayouts(
          items: [
            for (final task in tasksToday)
              (
                id: task.id,
                start: task.dueDate!,
                end: task.dueDate!.add(const Duration(minutes: 30)),
              ),
          ],
          contentLeft: contentLeft,
          contentWidth: contentWidth,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: totalTimelineHeight(start, end),
            child: Stack(
              children: [
                TimelineHourMarkers(dayStartMinutes: start, dayEndMinutes: end),
                for (final item in items)
                  Positioned(
                    top: timelineTop(item.startTime, start),
                    left: scheduleLayouts[item.id]!.left,
                    right: scheduleLayouts[item.id]!.right,
                    height: timelineHeight(item.startTime, item.endTime),
                    child: ScheduleItemBlock(item: item),
                  ),
                for (final task in tasksToday)
                  Positioned(
                    top: timelineTop(task.dueDate!, start),
                    left: taskLayouts[task.id]!.left,
                    right: taskLayouts[task.id]!.right,
                    height: taskBlockHeight,
                    child: TaskTimelineBlock(task: task),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
