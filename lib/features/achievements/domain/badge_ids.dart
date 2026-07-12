// Shared between badge_catalog.dart (data layer, defines what each badge
// looks like) and badge_rules.dart (domain layer, defines when each badge
// unlocks) so the two never drift out of sync via typo'd string literals.
class BadgeIds {
  BadgeIds._();

  static const firstSteps = 'first_steps';
  static const gettingThingsDone = 'getting_things_done';
  static const taskMaster = 'task_master';
  static const earlyBird = 'early_bird';

  static const threeDayStreak = 'three_day_streak';
  static const weekWarrior = 'week_warrior';
  static const consistencyKing = 'consistency_king';

  static const firstSchedule = 'first_schedule';
  static const weeklyPlanner = 'weekly_planner';
  static const repeatChampion = 'repeat_champion';

  static const fullTour = 'full_tour';
  static const gettingStarted = 'getting_started';

  static const all = [
    firstSteps, gettingThingsDone, taskMaster, earlyBird,
    threeDayStreak, weekWarrior, consistencyKing,
    firstSchedule, weeklyPlanner, repeatChampion,
    fullTour, gettingStarted,
  ];
}
