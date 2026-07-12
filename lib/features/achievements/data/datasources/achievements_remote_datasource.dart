import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/streak_calculator.dart';
import '../models/user_progress_model.dart';

abstract class AchievementsRemoteDataSource {
  Stream<UserProgressModel> watchProgress();
  Future<void> recordAppOpen();
  Future<void> recordTabVisit(String tabName);
  Future<void> recordTaskCompleted({required bool wasEarly});
  Future<void> recordPlannerItemAdded({required DateTime itemDate});
  Future<void> recordDuplicateDayUsed();
  Future<void> unlockBadgesAndAwardPoints(Map<String, DateTime> newUnlocks, int pointsToAdd);
}

class AchievementsRemoteDataSourceImpl implements AchievementsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AchievementsRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _doc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return _firestore.collection('users').doc(uid).collection('progress').doc('summary');
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _mondayOf(DateTime d) {
    final day = _dateOnly(d);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  @override
  Stream<UserProgressModel> watchProgress() {
    return _doc.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        final initial = UserProgressModel.initial();
        await _doc.set(initial.toFirestore());
        return initial;
      }
      return UserProgressModel.fromFirestore(snapshot);
    });
  }

  @override
  Future<void> recordAppOpen() async {
    final snapshot = await _doc.get();
    final current = UserProgressModel.fromFirestore(snapshot);
    final today = _dateOnly(DateTime.now());

    final update = computeStreakUpdate(
      lastActiveDate: current.lastActiveDate,
      currentStreak: current.currentStreak,
      longestStreak: current.longestStreak,
      today: today,
    );
    if (!update.changed) return; // already recorded today — no-op

    await _doc.set({
      'currentStreak': update.currentStreak,
      'longestStreak': update.longestStreak,
      'lastActiveDate': Timestamp.fromDate(today),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordTabVisit(String tabName) async {
    await _doc.set({
      'visitedTabs': FieldValue.arrayUnion([tabName]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordTaskCompleted({required bool wasEarly}) async {
    await _doc.set({
      'tasksCompletedCount': FieldValue.increment(1),
      if (wasEarly) 'tasksCompletedEarlyCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordPlannerItemAdded({required DateTime itemDate}) async {
    final snapshot = await _doc.get();
    final data = snapshot.data() ?? {};
    final weekKey = _mondayOf(itemDate).toIso8601String().split('T').first;
    final dateKey = _dateOnly(itemDate).toIso8601String().split('T').first;

    final weekDates = Map<String, dynamic>.from(data['scheduledWeekDates'] as Map? ?? {});
    final thisWeek = Set<String>.from(weekDates[weekKey] as List? ?? const []);
    thisWeek.add(dateKey);
    weekDates[weekKey] = thisWeek.toList();

    final currentMax = data['maxScheduledDaysInAWeek'] as int? ?? 0;
    final newMax = thisWeek.length > currentMax ? thisWeek.length : currentMax;

    await _doc.set({
      'plannerItemsCount': FieldValue.increment(1),
      'scheduledWeekDates': weekDates,
      'maxScheduledDaysInAWeek': newMax,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordDuplicateDayUsed() async {
    await _doc.set({'hasUsedDuplicateDay': true}, SetOptions(merge: true));
  }

  @override
  Future<void> unlockBadgesAndAwardPoints(Map<String, DateTime> newUnlocks, int pointsToAdd) async {
    final updates = <String, dynamic>{'totalPoints': FieldValue.increment(pointsToAdd)};
    for (final entry in newUnlocks.entries) {
      updates['badgeUnlockedAt.${entry.key}'] = Timestamp.fromDate(entry.value);
    }
    // Deliberately .update(), not .set(merge: true) — Firestore only
    // interprets dotted string keys as nested-map paths for update();
    // set(merge: true) treats "badgeUnlockedAt.first_steps" as one
    // literal field name containing a dot, so the badgeUnlockedAt map
    // itself never actually gained any entries. Safe to assume the doc
    // exists here: recalculateBadges() always reads via watchProgress()
    // first, which creates it if missing.
    await _doc.update(updates);
  }
}
