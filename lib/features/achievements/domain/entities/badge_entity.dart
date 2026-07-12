import 'package:equatable/equatable.dart';

enum BadgeCategory { tasks, streaks, planner, explorer }

class BadgeEntity extends Equatable {
  final String id; // e.g. 'first_steps'
  final String title;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  BadgeEntity copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return BadgeEntity(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      category: category,
      points: points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, emoji, category, points, isUnlocked, unlockedAt];
}
