import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete your account?', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      content: Text(
        'This will permanently delete your account and all your tasks, notes, planner entries, '
        'and achievements. This cannot be undone.',
        style: GoogleFonts.inter(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: AppColors.coral)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
