import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/manager_dashboard_provider.dart';
import 'providers/review_provider.dart';
import 'widgets/feedback_dialog.dart';

/// Screen for reviewing employee Pull Request submissions.
class ReviewSubmissionsScreen extends ConsumerWidget {
  const ReviewSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(managerDashboardProvider);
    final reviewState = ref.watch(reviewNotifierProvider);
    final isLoading = reviewState.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go(AppRoutes.managerDashboard),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Review Submissions',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            metricsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Error loading submissions',
                description: err.toString(),
              ),
              data: (metrics) {
                final submissions = metrics.recentSubmissions;

                if (submissions.isEmpty) {
                  return const EmptyState(
                    icon: Icons.rate_review_rounded,
                    title: 'No Pending PR Submissions',
                    description: 'All submitted pull requests have been reviewed.',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final taskId = sub['task_id'] as String? ?? '';
                    final prUrl = sub['pr_url'] as String? ?? '';

                    return GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Task #$taskId',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  final uri = Uri.tryParse(prUrl);
                                  if (uri != null) launchUrl(uri);
                                },
                                child: Text(
                                  prUrl,
                                  style: const TextStyle(
                                    color: AppColors.brandCyan,
                                    decoration: TextDecoration.underline,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppButton(
                                label: 'Reject',
                                variant: AppButtonVariant.danger,
                                size: AppButtonSize.small,
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final feedback = await FeedbackDialog.show(
                                          context,
                                          title: 'Reject Submission',
                                          actionLabel: 'Confirm Rejection',
                                          isApprove: false,
                                        );
                                        if (feedback != null) {
                                          await ref
                                              .read(reviewNotifierProvider.notifier)
                                              .reject(taskId: taskId, feedback: feedback);
                                          ref.invalidate(managerDashboardProvider);
                                        }
                                      },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AppButton(
                                label: 'Approve',
                                size: AppButtonSize.small,
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final feedback = await FeedbackDialog.show(
                                          context,
                                          title: 'Approve Submission',
                                          actionLabel: 'Confirm Approval',
                                          isApprove: true,
                                        );
                                        if (feedback != null) {
                                          await ref
                                              .read(reviewNotifierProvider.notifier)
                                              .approve(taskId: taskId, feedback: feedback);
                                          ref.invalidate(managerDashboardProvider);
                                        }
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
