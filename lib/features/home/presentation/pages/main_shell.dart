import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../achievements/presentation/providers/achievements_provider.dart';
import '../../../achievements/presentation/utils/celebrate_badges.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../../../planner/presentation/pages/planner_page.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'dashboard_page.dart';

/// Top-level shell that holds all four tabs in a PageView so the user can
/// swipe between them. The bottom nav and the PageController stay in sync —
/// tapping a nav item animates to that page, swiping updates the nav.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _controller = PageController();
  int _currentIndex = 0;

  static const _pages = [
    DashboardPage(),
    PlannerPage(),
    NotesPage(),
    AnalyticsPage(),
  ];

  static const _tabNames = ['home', 'planner', 'notes', 'analytics'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    // Home (index 0) records its own visit + app-open in DashboardPage.initState.
    if (index != 0) _recordVisit(index);
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _recordVisit(int index) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final notifier = ref.read(achievementsActionsProvider.notifier);
    await notifier.recordTabVisit(_tabNames[index]);
    final newBadges = await notifier.recalculateBadges();
    for (final badge in newBadges) {
      messenger?.showSnackBar(badgeUnlockSnackBar(badge));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DashboardBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
