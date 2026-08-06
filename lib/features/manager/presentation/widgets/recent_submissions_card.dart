import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';

/// Card displaying recent GitHub PR submissions for manager review.
class RecentSubmissionsCard extends StatelessWidget {
  const RecentSubmissionsCard({super.key, required this.submissions});

  final List<Map<String, dynamic>> submissions;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brandCyan.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.brandCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Recent PR Submissions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (submissions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No recent PR submissions pending review',
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
                  title: Row(
                    children: [
                      Text(
                        'Task #$taskId',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.open_in_new_rounded,
                          size: 13, color: AppColors.brandCyan),
                    ],
                  ),
                  subtitle: Text(
                    prUrl,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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
                      color: AppColors.info.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.info.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
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
