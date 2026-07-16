import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../achievements/presentation/providers/achievements_provider.dart';
import '../../../achievements/presentation/utils/celebrate_badges.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../../../planner/presentation/pages/planner_page.dart';

class DashboardBottomNav extends ConsumerWidget {
  const DashboardBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _NavItem(icon: Icons.home_rounded, label: 'Home', active: true),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Planner',
            onTap: () => _go(context, ref, 'planner', const PlannerPage()),
          ),
          _NavItem(
            icon: Icons.description_outlined,
            label: 'Notes',
            onTap: () => _go(context, ref, 'notes', const NotesPage()),
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Analytics',
            onTap: () => _go(context, ref, 'analytics', const AnalyticsPage()),
          ),
        ],
      ),
    );
  }

  // Navigate immediately — never block on network.
  // Record the visit and check for badge unlocks in the background.
  void _go(BuildContext context, WidgetRef ref, String tabName, Widget page) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _recordVisitInBackground(ref, messenger, tabName);
  }

  Future<void> _recordVisitInBackground(
    WidgetRef ref,
    ScaffoldMessengerState? messenger,
    String tabName,
  ) async {
    await ref.read(achievementsActionsProvider.notifier).recordTabVisit(tabName);
    final newBadges = await ref.read(achievementsActionsProvider.notifier).recalculateBadges();
    for (final badge in newBadges) {
      messenger?.showSnackBar(badgeUnlockSnackBar(badge));
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({required this.icon, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.violet : AppColors.muted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.violet.withValues(alpha: 0.15),
        highlightColor: AppColors.violet.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: active
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 3)
                    : EdgeInsets.zero,
                decoration: active
                    ? BoxDecoration(
                        color: AppColors.tileVioletBg,
                        borderRadius: BorderRadius.circular(9),
                      )
                    : null,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
