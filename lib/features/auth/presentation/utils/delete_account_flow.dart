import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/account_deletion_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/delete_account_dialog.dart';

/// Confirms, deletes the account (Firestore data + Firebase Auth user), and
/// clears local state, then pops the navigation stack back to the root so
/// AuthGate picks up the now-signed-out state and shows LoginPage on its
/// own — no explicit navigation to LoginPage needed. Call from anywhere
/// with a BuildContext + WidgetRef, e.g. the dashboard's kebab menu.
Future<void> confirmAndDeleteAccount(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDeleteAccountDialog(context);
  if (!confirmed || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeletingDialog(),
  );

  final success = await ref.read(authNotifierProvider.notifier).deleteAccount();
  if (!context.mounted) return;
  Navigator.of(context).pop(); // dismiss the loading dialog

  if (success) {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.clear();
    ref.read(accountJustDeletedProvider.notifier).state = true;
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Couldn't delete account — please try again or contact support",
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _DeletingDialog extends StatelessWidget {
  const _DeletingDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.violet),
              const SizedBox(height: 16),
              Text(
                'Deleting your account...',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
