import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge_entity.dart';

extension BadgeCategoryDisplay on BadgeCategory {
  String get label => switch (this) {
        BadgeCategory.tasks => 'Tasks',
        BadgeCategory.streaks => 'Streaks',
        BadgeCategory.planner => 'Planner',
        BadgeCategory.explorer => 'Explorer',
      };

  Color get background => switch (this) {
        BadgeCategory.tasks => AppColors.tileCoralBg,
        BadgeCategory.streaks => AppColors.tileAmberBg,
        BadgeCategory.planner => AppColors.tileVioletBg,
        BadgeCategory.explorer => AppColors.tileMintBg,
      };

  Color get iconBackground => switch (this) {
        BadgeCategory.tasks => AppColors.tileCoralIcon,
        BadgeCategory.streaks => AppColors.tileAmberIcon,
        BadgeCategory.planner => AppColors.tileVioletIcon,
        BadgeCategory.explorer => AppColors.tileMintIcon,
      };

  Color get text => switch (this) {
        BadgeCategory.tasks => AppColors.tileCoralText,
        BadgeCategory.streaks => AppColors.tileAmberText,
        BadgeCategory.planner => AppColors.tileVioletText,
        BadgeCategory.explorer => AppColors.tileMintText,
      };
}
