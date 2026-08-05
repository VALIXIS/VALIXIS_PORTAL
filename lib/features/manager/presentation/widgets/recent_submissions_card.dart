import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';

class RecentSubmissionsCard extends StatelessWidget {
  const RecentSubmissionsCard({super.key, required this.submissions});

  final List<Map<String, dynamic>> submissions;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history_rounded, color: AppColors.brandCyan, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Recent PR Submissions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (submissions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No recent PR submissions',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submissions.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.border,
                height: AppSpacing.base,
              ),
              itemBuilder: (context, index) {
                final sub = submissions[index];
                final prUrl = sub['pr_url'] as String? ?? '';
                final taskId = sub['task_id'] as String? ?? 'N/A';
                final status = sub['status'] as String? ?? 'submitted';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Task #$taskId',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    prUrl,
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () {
                    final uri = Uri.tryParse(prUrl);
                    if (uri != null) launchUrl(uri);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
