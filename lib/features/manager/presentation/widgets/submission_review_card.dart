import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/glass_card.dart';

/// GitHub PR submission review card displaying PR metadata and audit actions.
class SubmissionReviewCard extends StatelessWidget {
  const SubmissionReviewCard({
    super.key,
    required this.taskId,
    required this.prUrl,
    required this.status,
    required this.isLoading,
    required this.onApprove,
    required this.onReject,
  });

  final String taskId;
  final String prUrl;
  final String status;
  final bool isLoading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  void _launchPrUrl() {
    final uri = Uri.tryParse(prUrl);
    if (uri != null) launchUrl(uri);
  }

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
                      color: AppColors.brandBlue.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.merge_type_rounded,
                      color: AppColors.brandBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Task #$taskId',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withAlpha(60)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.info,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _launchPrUrl,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 16, color: AppColors.brandCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prUrl,
                      style: const TextStyle(
                        color: AppColors.brandCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.open_in_new_rounded,
                      size: 14, color: AppColors.brandCyan),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: 'Reject',
                variant: AppButtonVariant.danger,
                size: AppButtonSize.small,
                prefixIcon: Icons.cancel_rounded,
                onPressed: isLoading ? null : onReject,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Approve Submission',
                size: AppButtonSize.small,
                prefixIcon: Icons.check_circle_rounded,
                onPressed: isLoading ? null : onApprove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
