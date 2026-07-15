import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notification.wasRead;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: unread
            ? const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.violet, width: 3)),
              )
            : null,
        padding: EdgeInsets.fromLTRB(unread ? 17 : 20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 14, top: 1),
              decoration: BoxDecoration(
                color: unread ? AppColors.violet.withValues(alpha: 0.12) : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 18,
                color: unread ? AppColors.violet : AppColors.muted,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                      color: unread ? AppColors.ink : AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(notification.scheduledFor),
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
