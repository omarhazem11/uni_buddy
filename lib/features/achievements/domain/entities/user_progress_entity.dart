import 'package:equatable/equatable.dart';

class UserProgressEntity extends Equatable {
  final int totalPoints;
  final int level; // computed from totalPoints
  final int currentStreak; // consecutive days app opened
  final int longestStreak;
  final DateTime? lastActiveDate;
  final Set<String> visitedTabs; // 'home','planner','notes','analytics'
  final int tasksCompletedCount;
  final int tasksCompletedEarlyCount;
  final int plannerItemsCount;
  final bool hasUsedDuplicateDay;
  final int maxScheduledDaysInAWeek;
  // Badge id -> unlock timestamp. The keys double as the unlocked-badge
  // set, so watchBadges() merges this straight onto the static catalog
  // without needing a separate "unlocked ids" collection.
  final Map<String, DateTime> badgeUnlockedAt;

  const UserProgressEntity({
    this.totalPoints = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.visitedTabs = const {},
    this.tasksCompletedCount = 0,
    this.tasksCompletedEarlyCount = 0,
    this.plannerItemsCount = 0,
    this.hasUsedDuplicateDay = false,
    this.maxScheduledDaysInAWeek = 0,
    this.badgeUnlockedAt = const {},
  });

  UserProgressEntity copyWith({
    int? totalPoints,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    Set<String>? visitedTabs,
    int? tasksCompletedCount,
    int? tasksCompletedEarlyCount,
    int? plannerItemsCount,
    bool? hasUsedDuplicateDay,
    int? maxScheduledDaysInAWeek,
    Map<String, DateTime>? badgeUnlockedAt,
  }) {
    return UserProgressEntity(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      visitedTabs: visitedTabs ?? this.visitedTabs,
      tasksCompletedCount: tasksCompletedCount ?? this.tasksCompletedCount,
      tasksCompletedEarlyCount: tasksCompletedEarlyCount ?? this.tasksCompletedEarlyCount,
      plannerItemsCount: plannerItemsCount ?? this.plannerItemsCount,
      hasUsedDuplicateDay: hasUsedDuplicateDay ?? this.hasUsedDuplicateDay,
      maxScheduledDaysInAWeek: maxScheduledDaysInAWeek ?? this.maxScheduledDaysInAWeek,
      badgeUnlockedAt: badgeUnlockedAt ?? this.badgeUnlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        totalPoints,
        level,
        currentStreak,
        longestStreak,
        lastActiveDate,
        visitedTabs,
        tasksCompletedCount,
        tasksCompletedEarlyCount,
        plannerItemsCount,
        hasUsedDuplicateDay,
        maxScheduledDaysInAWeek,
        badgeUnlockedAt,
      ];
}
