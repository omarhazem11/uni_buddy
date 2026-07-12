import 'badge_ids.dart';
import 'entities/user_progress_entity.dart';

/// Badge id -> whether [progress] satisfies that badge's unlock condition.
/// Streak badges check longestStreak (a high-water mark) rather than
/// currentStreak, so a badge earned once stays earned even if the streak
/// later breaks.
final Map<String, bool Function(UserProgressEntity progress)> badgeRules = {
  BadgeIds.firstSteps: (p) => p.tasksCompletedCount >= 1,
  BadgeIds.gettingThingsDone: (p) => p.tasksCompletedCount >= 10,
  BadgeIds.taskMaster: (p) => p.tasksCompletedCount >= 50,
  BadgeIds.earlyBird: (p) => p.tasksCompletedEarlyCount >= 5,
  BadgeIds.threeDayStreak: (p) => p.longestStreak >= 3,
  BadgeIds.weekWarrior: (p) => p.longestStreak >= 7,
  BadgeIds.consistencyKing: (p) => p.longestStreak >= 30,
  BadgeIds.firstSchedule: (p) => p.plannerItemsCount >= 1,
  BadgeIds.weeklyPlanner: (p) => p.maxScheduledDaysInAWeek >= 5,
  BadgeIds.repeatChampion: (p) => p.hasUsedDuplicateDay,
  BadgeIds.fullTour: (p) => p.visitedTabs.length >= 4,
  BadgeIds.gettingStarted: (p) => p.visitedTabs.isNotEmpty,
};
