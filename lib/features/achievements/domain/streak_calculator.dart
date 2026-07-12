class StreakUpdate {
  final int currentStreak;
  final int longestStreak;
  final bool changed; // false when it's a same-day no-op

  const StreakUpdate({required this.currentStreak, required this.longestStreak, required this.changed});
}

/// Pure streak math, independent of Firestore/DateTime.now() so it can be
/// unit-tested directly with controlled dates rather than needing a fake
/// clock threaded through the whole datasource.
StreakUpdate computeStreakUpdate({
  required DateTime? lastActiveDate,
  required int currentStreak,
  required int longestStreak,
  required DateTime today,
}) {
  final todayOnly = DateTime(today.year, today.month, today.day);
  final lastOnly =
      lastActiveDate == null ? null : DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);

  if (lastOnly == todayOnly) {
    return StreakUpdate(currentStreak: currentStreak, longestStreak: longestStreak, changed: false);
  }

  final dayGap = lastOnly == null ? null : todayOnly.difference(lastOnly).inDays;
  final newStreak = dayGap == 1 ? currentStreak + 1 : 1;
  final newLongest = newStreak > longestStreak ? newStreak : longestStreak;
  return StreakUpdate(currentStreak: newStreak, longestStreak: newLongest, changed: true);
}
