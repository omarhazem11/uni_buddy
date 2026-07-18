import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/planner_provider.dart';

const _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class DateStrip extends ConsumerWidget {
  const DateStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    final days = List.generate(7, (i) => dateOnly(selected.add(Duration(days: i - 3))));

    return SizedBox(
      height: 68,
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: GestureDetector(
                onTap: () => ref.read(selectedDateProvider.notifier).state = day,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayLetters[day.weekday - 1],
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: day == selected ? AppColors.violet : Colors.transparent,
                      ),
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: day == selected ? FontWeight.w800 : FontWeight.w600,
                          color: day == selected ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
