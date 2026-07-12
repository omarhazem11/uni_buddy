import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge_entity.dart';
import '../utils/badge_date_format.dart';
import '../utils/badge_display_helpers.dart';

class BadgeCard extends StatelessWidget {
  final BadgeEntity badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? badge.category.background : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Opacity(
                opacity: unlocked ? 1 : 0.35,
                child: Text(badge.emoji, style: const TextStyle(fontSize: 48)),
              ),
              if (!unlocked)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.lock_rounded, size: 16, color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            badge.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: unlocked ? badge.category.text : AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unlocked && badge.unlockedAt != null
                ? 'Unlocked ${shortDateLabel(badge.unlockedAt!)}'
                : badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: unlocked ? badge.category.text.withValues(alpha: 0.8) : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
