import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/uni_verse_logo.dart';
import '../../../notifications/presentation/pages/notification_inbox_page.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../onboarding/presentation/pages/coming_soon_page.dart';
import '../../../settings/presentation/pages/account_settings_page.dart';

class DashboardTopNav extends ConsumerWidget {
  const DashboardTopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const UniVerseLogo(size: 32),
              const SizedBox(width: 9),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  children: const [
                    TextSpan(text: 'Uni', style: TextStyle(color: AppColors.violet)),
                    TextSpan(text: '-Verse', style: TextStyle(color: AppColors.ink)),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              _BellButton(
                hasUnread: unreadCount > 0,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationInboxPage()),
                ),
              ),
              const SizedBox(width: 12),
              const _KebabMenu(),
            ],
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _BellButton({required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.notifications_outlined, color: AppColors.violet, size: 20),
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KebabMenu extends StatelessWidget {
  const _KebabMenu();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.violet, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onSelected: (value) => _onSelected(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'explore_universities',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_rounded, size: 18, color: AppColors.coral),
                SizedBox(width: 10),
                Flexible(
                  child: Text('Explore Universities', overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_outlined, size: 18, color: AppColors.violet),
                SizedBox(width: 10),
                Text('Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSelected(BuildContext context, String value) {
    switch (value) {
      case 'explore_universities':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ComingSoonPage()));
      case 'settings':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountSettingsPage()));
    }
  }
}
