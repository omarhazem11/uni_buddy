import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../achievements/presentation/providers/achievements_provider.dart';
import '../../../achievements/presentation/utils/celebrate_badges.dart';
import '../providers/planner_provider.dart';
import '../utils/schedule_date_format.dart';
import 'duplicate_day_confirm_button.dart';
import 'duplicate_day_grid_cell.dart';
import 'duplicate_day_month_nav.dart';
import 'month_grid.dart';
import 'schedule_sheet_header.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class DuplicateDaySheet extends ConsumerStatefulWidget {
  final DateTime sourceDate;

  const DuplicateDaySheet({super.key, required this.sourceDate});

  @override
  ConsumerState<DuplicateDaySheet> createState() => _DuplicateDaySheetState();
}

class _DuplicateDaySheetState extends ConsumerState<DuplicateDaySheet> {
  final Set<DateTime> _selected = {};
  late DateTime _visibleMonth = dateOnly(widget.sourceDate);
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final count = _selected.length;
    final today = dateOnly(DateTime.now());

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScheduleSheetHeader(title: 'Duplicate Day'),
                const SizedBox(height: 6),
                Text(
                  "Duplicate ${weekdayDateLabel(widget.sourceDate)}'s schedule to...",
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                DuplicateDayMonthNav(
                  label: '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  onPrevious: () => setState(() => _visibleMonth = _shiftMonth(-1)),
                  onNext: () => setState(() => _visibleMonth = _shiftMonth(1)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: MonthGrid(
                      visibleMonth: _visibleMonth,
                      cellBuilder: (date) => DuplicateDayGridCell(
                        day: date.day,
                        isToday: _isSameDate(date, today),
                        isSource: _isSameDate(date, widget.sourceDate),
                        isPast: date.isBefore(dateOnly(widget.sourceDate)),
                        isSelected: _selected.contains(date),
                        onTap: () => setState(() {
                          _selected.contains(date) ? _selected.remove(date) : _selected.add(date);
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DuplicateDayConfirmButton(saving: _submitted, count: count, onPressed: _confirm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _shiftMonth(int delta) => DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _confirm() {
    if (_selected.isEmpty || _submitted) return;
    _submitted = true;

    final count = _selected.length;
    final sourceDate = widget.sourceDate;
    final targetDates = _selected.toList();
    final plannerNotifier = ref.read(plannerActionsProvider.notifier);
    final achievementsNotifier = ref.read(achievementsActionsProvider.notifier);
    final messenger = ScaffoldMessenger.maybeOf(context);

    Navigator.pop(context);

    () async {
      final success = await plannerNotifier.duplicateItemsToDate(sourceDate, targetDates);
      if (!success) return;

      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Schedule copied to $count day${count == 1 ? '' : 's'}! 🎉',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      );
      await achievementsNotifier.recordDuplicateDayUsed();
      final newlyUnlocked = await achievementsNotifier.recalculateBadges();
      for (final badge in newlyUnlocked) {
        messenger?.showSnackBar(badgeUnlockSnackBar(badge));
      }
    }();
  }
}
