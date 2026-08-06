import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/auth/presentation/providers/role_provider.dart';
import '../../../../shared/components/glass_card.dart';
import '../../domain/models/announcement.dart';
import '../providers/announcements_provider.dart';
import 'create_announcement_dialog.dart';

/// Company announcements banner widget displaying enterprise notices.
class AnnouncementsBanner extends ConsumerWidget {
  const AnnouncementsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    final userRole = ref.watch(roleProvider).valueOrNull;
    final isManager = userRole?.isManager ?? false;

    if (announcements.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.campaign_rounded, color: AppColors.brandCyan, size: 22),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Company Announcements',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (isManager)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.brandCyan),
                  tooltip: 'Publish Announcement',
                  onPressed: () => CreateAnnouncementDialog.show(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final a = announcements[index];
              final priorityColor = a.priority == AnnouncementPriority.urgent
                  ? AppColors.error
                  : (a.priority == AnnouncementPriority.important
                      ? AppColors.warning
                      : AppColors.brandBlue);

              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: a.isPinned ? AppColors.brandCyan.withAlpha(80) : AppColors.glassBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (a.isPinned) ...[
                              const Icon(Icons.push_pin_rounded, color: AppColors.brandCyan, size: 14),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              a.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: priorityColor.withAlpha(60)),
                          ),
                          child: Text(
                            a.priority.label.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.content,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'By ${a.author}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                        Text(
                          DateFormatter.formatShortDate(a.createdAt),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
