import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/presentation/utils/task_date_format.dart';
import '../../domain/entities/task_analytics_entity.dart';

const _chartHeight = 90.0;

class WeeklyBarChart extends StatelessWidget {
  final List<WeeklyCompletionEntity> weeks;

  const WeeklyBarChart({super.key, required this.weeks});

  @override
  Widget build(BuildContext context) {
    final maxCount = weeks.fold<int>(0, (max, w) => w.completedCount > max ? w.completedCount : max);
    if (maxCount == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Complete some tasks to see your trends! 📊',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
        ),
      );
    }

    return SizedBox(
      height: _chartHeight + 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final week in weeks)
            Expanded(
              child: _WeekBar(week: week, maxCount: maxCount),
            ),
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  final WeeklyCompletionEntity week;
  final int maxCount;

  const _WeekBar({required this.week, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final fraction = week.completedCount / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (week.completedCount > 0)
            Text(
              '${week.completedCount}',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.violet),
            ),
          const SizedBox(height: 4),
          Container(
            height: _chartHeight * fraction,
            decoration: const BoxDecoration(
              color: AppColors.violet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            shortDateLabel(week.weekStart),
            style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
