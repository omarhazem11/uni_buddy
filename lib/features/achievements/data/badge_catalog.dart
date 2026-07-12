import '../domain/badge_ids.dart';
import '../domain/entities/badge_entity.dart';

/// Source of truth for what badges exist — hardcoded, not a model. Unlock
/// status merges in from progress at runtime (see AchievementsRepositoryImpl
/// / watchBadges). Swapping the emoji field for a custom asset path later
/// won't require touching this shape, the repository, or badge_rules.dart.
const badgeCatalog = <BadgeEntity>[
  BadgeEntity(
    id: BadgeIds.firstSteps,
    title: 'First Steps',
    description: 'Complete your first task',
    emoji: '🌱',
    category: BadgeCategory.tasks,
    points: 10,
  ),
  BadgeEntity(
    id: BadgeIds.gettingThingsDone,
    title: 'Getting Things Done',
    description: 'Complete 10 tasks',
    emoji: '✅',
    category: BadgeCategory.tasks,
    points: 25,
  ),
  BadgeEntity(
    id: BadgeIds.taskMaster,
    title: 'Task Master',
    description: 'Complete 50 tasks',
    emoji: '🏆',
    category: BadgeCategory.tasks,
    points: 100,
  ),
  BadgeEntity(
    id: BadgeIds.earlyBird,
    title: 'Early Bird',
    description: 'Complete 5 tasks before their due date',
    emoji: '🐦',
    category: BadgeCategory.tasks,
    points: 20,
  ),
  BadgeEntity(
    id: BadgeIds.threeDayStreak,
    title: '3-Day Streak',
    description: 'Open the app 3 days in a row',
    emoji: '🔥',
    category: BadgeCategory.streaks,
    points: 15,
  ),
  BadgeEntity(
    id: BadgeIds.weekWarrior,
    title: 'Week Warrior',
    description: 'Open the app 7 days in a row',
    emoji: '⚡',
    category: BadgeCategory.streaks,
    points: 40,
  ),
  BadgeEntity(
    id: BadgeIds.consistencyKing,
    title: 'Consistency King',
    description: 'Open the app 30 days in a row',
    emoji: '👑',
    category: BadgeCategory.streaks,
    points: 150,
  ),
  BadgeEntity(
    id: BadgeIds.firstSchedule,
    title: 'First Schedule',
    description: 'Add your first planner item',
    emoji: '🗓️',
    category: BadgeCategory.planner,
    points: 10,
  ),
  BadgeEntity(
    id: BadgeIds.weeklyPlanner,
    title: 'Weekly Planner',
    description: 'Schedule items across 5 days in one week',
    emoji: '📆',
    category: BadgeCategory.planner,
    points: 30,
  ),
  BadgeEntity(
    id: BadgeIds.repeatChampion,
    title: 'Repeat Champion',
    description: "Duplicate a day's schedule",
    emoji: '🔁',
    category: BadgeCategory.planner,
    points: 20,
  ),
  BadgeEntity(
    id: BadgeIds.fullTour,
    title: 'Full Tour',
    description: 'Visit all 4 tabs',
    emoji: '🧭',
    category: BadgeCategory.explorer,
    points: 25,
  ),
  BadgeEntity(
    id: BadgeIds.gettingStarted,
    title: 'Getting Started',
    description: 'Visit your first tab',
    emoji: '🚀',
    category: BadgeCategory.explorer,
    points: 5,
  ),
];
