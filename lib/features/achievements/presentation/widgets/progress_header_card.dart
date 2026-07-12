import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/level_calculator.dart';

class ProgressHeaderCard extends StatelessWidget {
  final UserProgressEntity progress;

  const ProgressHeaderCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final level = levelForPoints(progress.totalPoints);
    final fraction = levelProgress(progress.totalPoints);
    final toNext = pointsToNextLevel(progress.totalPoints);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.violet, borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(child: _DecorativeCircles()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Level $level',
                          style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      if (progress.currentStreak > 0) _StreakChip(days: progress.currentStreak),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.totalPoints} points',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$toNext points to level ${level + 1}',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int days;

  const _StreakChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '🔥 $days day${days == 1 ? '' : 's'} streak',
        style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

class _DecorativeCircles extends StatelessWidget {
  const _DecorativeCircles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(right: -30, top: -30, child: _circle(140)),
        Positioned(right: 20, bottom: -40, child: _circle(100)),
      ],
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
    );
  }
}
