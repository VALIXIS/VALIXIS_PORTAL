import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.brandCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.commit_rounded,
                      color: AppColors.brandCyan,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Pull Request Stream',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${submissions.length} DETECTED',
                style: AppTypography.telemetryHeader(
                  size: 9,
                  color: AppColors.textMuted,
                  spacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (submissions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No Pull Requests Pending Verification',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All active submissions have been reviewed or merged.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submissions.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.divider,
                height: AppSpacing.base,
              ),
              itemBuilder: (context, index) {
                final sub = submissions[index];
                final prUrl = sub['pr_url'] as String? ?? '';
                final taskId = sub['task_id'] as String? ?? 'N/A';
                final status = sub['status'] as String? ?? 'submitted';

                final statusColor = switch (status.toLowerCase()) {
                  'approved' => AppColors.success,
                  'rejected' => AppColors.error,
                  _ => AppColors.telemetryViolet,
                };

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    final uri = Uri.tryParse(prUrl);
                    if (uri != null) launchUrl(uri);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '#$taskId',
                            style: AppTypography.mono(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AppColors.brandCyan,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prUrl.isNotEmpty ? prUrl : 'No PR Link Associated',
                                style: AppTypography.mono(
                                  size: 12,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 11,
                                    color: AppColors.brandCyan,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Open GitHub PR Diff',
                                    style: AppTypography.textTheme.bodySmall?.copyWith(
                                      color: AppColors.brandCyan,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: AppTypography.telemetryHeader(
                              size: 9,
                              color: statusColor,
                              spacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

