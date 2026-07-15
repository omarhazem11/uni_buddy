import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/domain/entities/user_type.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

/// Shows a confirm dialog, writes UserType.student to Firestore, then clears
/// the entire navigation stack so AuthGate re-routes to DashboardPage.
Future<void> confirmAndSwitchToStudent(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Switch to Student Mode?',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
      content: Text(
        "You'll see your dashboard instead of university search. You can switch back anytime.",
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.muted))),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Switch',
                style: GoogleFonts.inter(color: AppColors.violet, fontWeight: FontWeight.w600))),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await ref.read(onboardingNotifierProvider.notifier).chooseUserType(UserType.student);
  if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
}
