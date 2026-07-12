import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../achievements/domain/badge_ids.dart';
import '../../../achievements/presentation/providers/achievements_provider.dart';
import '../../../achievements/presentation/utils/celebrate_badges.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../planner/presentation/providers/planner_provider.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/utils/task_stats.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_getting_started_card.dart';
import '../widgets/dashboard_hero_card.dart';
import '../widgets/dashboard_tile_grid.dart';
import '../widgets/dashboard_top_nav.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Once per dashboard mount is a reasonable proxy for "once per session
    // start" — the datasource's same-day check keeps repeat mounts a no-op
    // for streak purposes regardless.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(achievementsActionsProvider.notifier);
      await notifier.recordAppOpen();
      await notifier.recordTabVisit('home');
      if (mounted) await recalculateAndCelebrate(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final firstName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim().split(' ').first
        : 'there';

    final tasks = ref.watch(tasksStreamProvider).value ?? [];
    final dueThisWeek = tasks.dueWithin(const Duration(days: 7));
    final heroSubtitle = dueThisWeek > 0
        ? 'You have $dueThisWeek things due this week'
        : "You're all caught up! 🎉";

    final hasScheduleItems = ref.watch(hasAnyScheduleItemsProvider).value ?? false;
    // Excludes "Getting Started" — it unlocks the instant any tab is
    // visited (including the automatic 'home' visit on mount), so
    // counting it here would make step 4 trivially done from first load
    // instead of reflecting a genuine accomplishment.
    final hasBadge = ref.watch(badgesProvider).value?.any(
              (b) => b.isUnlocked && b.id != BadgeIds.gettingStarted,
            ) ??
        false;
    final stepsDone =
        1 + (tasks.isNotEmpty ? 1 : 0) + (hasScheduleItems ? 1 : 0) + (hasBadge ? 1 : 0);
    final nextStepLabel = tasks.isEmpty
        ? 'add a task next'
        : !hasScheduleItems
            ? 'plan your week next'
            : !hasBadge
                ? 'earn your first badge next'
                : "you're all set! 🎉";

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DashboardTopNav(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeroCard(
                      greeting: 'Good morning, $firstName 👋',
                      subtitle: heroSubtitle,
                      onViewTasks: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TasksPage()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Expanded(
                      child: DashboardTileGrid(),
                    ),
                    const SizedBox(height: 12),
                    DashboardGettingStartedCard(
                      stepsDone: stepsDone,
                      totalSteps: 4,
                      nextStepLabel: nextStepLabel,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: DashboardBottomNav(),
      ),
    );
  }
}
