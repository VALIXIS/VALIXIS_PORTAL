import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/empty_state.dart';
import '../../domain/models/app_notification.dart';
import '../providers/notifications_provider.dart';

/// Glassmorphism Notification Drawer overlay displaying alerts and updates.
class NotificationDrawer extends ConsumerWidget {
  const NotificationDrawer({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationDrawer(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifications = state.notifications;
    final notifier = ref.read(notificationsProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.notifications_active_rounded,
                          color: AppColors.brandCyan, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Notifications Center',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (state.unreadCount > 0)
                    TextButton(
                      onPressed: notifier.markAllAsRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: AppColors.brandCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: notifications.isEmpty
                    ? const EmptyState(
                        icon: Icons.notifications_off_rounded,
                        title: 'No Notifications',
                        description: 'You are all caught up! No recent alerts.',
                      )
                    : ListView.separated(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppColors.border, height: 16),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return _NotificationCard(
                            notification: item,
                            onTap: () => notifier.markAsRead(item.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  IconData _iconForCategory(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.taskAssigned:
        return Icons.assignment_ind_rounded;
      case NotificationCategory.prSubmitted:
        return Icons.upload_file_rounded;
      case NotificationCategory.prApproved:
        return Icons.check_circle_rounded;
      case NotificationCategory.prRejected:
        return Icons.cancel_rounded;
      case NotificationCategory.announcement:
        return Icons.campaign_rounded;
    }
  }

  Color _colorForCategory(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.taskAssigned:
        return AppColors.brandBlue;
      case NotificationCategory.prSubmitted:
        return AppColors.info;
      case NotificationCategory.prApproved:
        return AppColors.success;
      case NotificationCategory.prRejected:
        return AppColors.error;
      case NotificationCategory.announcement:
        return AppColors.brandPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _colorForCategory(notification.category);
    final relativeTime = DateFormatter.formatRelativeTime(notification.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : AppColors.surfaceElevated.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : catColor.withAlpha(60),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: catColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForCategory(notification.category),
                  color: catColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        relativeTime,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
