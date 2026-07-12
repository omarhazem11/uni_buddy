import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/level_calculator.dart';

class UserProgressModel extends UserProgressEntity {
  const UserProgressModel({
    required super.totalPoints,
    required super.level,
    required super.currentStreak,
    required super.longestStreak,
    super.lastActiveDate,
    required super.visitedTabs,
    required super.tasksCompletedCount,
    required super.tasksCompletedEarlyCount,
    required super.plannerItemsCount,
    required super.hasUsedDuplicateDay,
    required super.maxScheduledDaysInAWeek,
    required super.badgeUnlockedAt,
  });

  factory UserProgressModel.fromEntity(UserProgressEntity p) {
    return UserProgressModel(
      totalPoints: p.totalPoints,
      level: p.level,
      currentStreak: p.currentStreak,
      longestStreak: p.longestStreak,
      lastActiveDate: p.lastActiveDate,
      visitedTabs: p.visitedTabs,
      tasksCompletedCount: p.tasksCompletedCount,
      tasksCompletedEarlyCount: p.tasksCompletedEarlyCount,
      plannerItemsCount: p.plannerItemsCount,
      hasUsedDuplicateDay: p.hasUsedDuplicateDay,
      maxScheduledDaysInAWeek: p.maxScheduledDaysInAWeek,
      badgeUnlockedAt: p.badgeUnlockedAt,
    );
  }

  factory UserProgressModel.initial() {
    return const UserProgressModel(
      totalPoints: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      visitedTabs: {},
      tasksCompletedCount: 0,
      tasksCompletedEarlyCount: 0,
      plannerItemsCount: 0,
      hasUsedDuplicateDay: false,
      maxScheduledDaysInAWeek: 0,
      badgeUnlockedAt: {},
    );
  }

  factory UserProgressModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return UserProgressModel.initial();

    final points = data['totalPoints'] as int? ?? 0;
    final rawUnlocks = data['badgeUnlockedAt'] as Map<String, dynamic>? ?? {};

    return UserProgressModel(
      totalPoints: points,
      level: levelForPoints(points),
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      visitedTabs: Set<String>.from(data['visitedTabs'] as List? ?? const []),
      tasksCompletedCount: data['tasksCompletedCount'] as int? ?? 0,
      tasksCompletedEarlyCount: data['tasksCompletedEarlyCount'] as int? ?? 0,
      plannerItemsCount: data['plannerItemsCount'] as int? ?? 0,
      hasUsedDuplicateDay: data['hasUsedDuplicateDay'] as bool? ?? false,
      maxScheduledDaysInAWeek: data['maxScheduledDaysInAWeek'] as int? ?? 0,
      badgeUnlockedAt: rawUnlocks.map((id, ts) => MapEntry(id, (ts as Timestamp).toDate())),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'visitedTabs': visitedTabs.toList(),
      'tasksCompletedCount': tasksCompletedCount,
      'tasksCompletedEarlyCount': tasksCompletedEarlyCount,
      'plannerItemsCount': plannerItemsCount,
      'hasUsedDuplicateDay': hasUsedDuplicateDay,
      'maxScheduledDaysInAWeek': maxScheduledDaysInAWeek,
      'badgeUnlockedAt': badgeUnlockedAt.map((id, dt) => MapEntry(id, Timestamp.fromDate(dt))),
    };
  }
}
