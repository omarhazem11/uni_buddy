import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/utils/task_display_helpers.dart';

Color _colorFor(TaskCategory category) => switch (category) {
      TaskCategory.assignment => AppColors.violet,
      TaskCategory.exam => AppColors.coral,
      TaskCategory.project => AppColors.mint,
      TaskCategory.other => AppColors.amber,
    };

class CategoryBreakdownCard extends StatelessWidget {
  final Map<TaskCategory, int> breakdown;
  final int totalTasks;

  const CategoryBreakdownCard({super.key, required this.breakdown, required this.totalTasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By Category',
            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 14),
          if (totalTasks == 0)
            Text(
              'Add tasks to see your breakdown 📝',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            )
          else
            for (final category in TaskCategory.values) ...[
              _CategoryRow(category: category, count: breakdown[category] ?? 0, total: totalTasks),
              if (category != TaskCategory.values.last) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final TaskCategory category;
  final int count;
  final int total;

  const _CategoryRow({required this.category, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    final color = _colorFor(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${category.emoji} ${category.label}',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const Spacer(),
            Text(
              count == 0 ? '—' : '$count',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: count == 0 ? AppColors.muted : AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 8,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.progressTrack, borderRadius: BorderRadius.circular(100)),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
