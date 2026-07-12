import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge_entity.dart';
import '../providers/achievements_provider.dart';

SnackBar badgeUnlockSnackBar(BadgeEntity badge) {
  return SnackBar(
    content: Text(
      '🎉 Badge unlocked: ${badge.title}!',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    backgroundColor: AppColors.violet,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    duration: const Duration(seconds: 3),
  );
}

/// Call after any achievements record* action to check for newly unlocked
/// badges and celebrate each with a floating toast. Safe to call from any
/// widget with access to both `ref` and a (possibly since-unmounted)
/// `context` — checks `context.mounted` itself.
///
/// If a call site needs to control ordering against its own SnackBar (e.g.
/// showing a "saved!" toast first), call
/// `ref.read(achievementsActionsProvider.notifier).recalculateBadges()`
/// directly instead and queue `badgeUnlockSnackBar()` manually.
Future<void> recalculateAndCelebrate(BuildContext context, WidgetRef ref) async {
  final newlyUnlocked = await ref.read(achievementsActionsProvider.notifier).recalculateBadges();
  if (newlyUnlocked.isEmpty || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  for (final badge in newlyUnlocked) {
    messenger.showSnackBar(badgeUnlockSnackBar(badge));
  }
}
