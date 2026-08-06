import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/empty_state.dart';
import 'providers/manager_dashboard_provider.dart';
import 'providers/review_provider.dart';
import 'widgets/feedback_dialog.dart';
import 'widgets/submission_review_card.dart';

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
                const SizedBox(width: AppSpacing.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'PR Submission Review Queue',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Audit submitted GitHub pull requests and record feedback',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            metricsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl4),
                  child: CircularProgressIndicator(),
                ),
              ),
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
                    description:
                        'All submitted pull requests have been audited and reviewed.',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final taskId = sub['task_id'] as String? ?? '';
                    final prUrl = sub['pr_url'] as String? ?? '';
                    final status = sub['status'] as String? ?? 'submitted';

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 80)),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 16),
                            child: child,
                          ),
                        );
                      },
                      child: SubmissionReviewCard(
                        taskId: taskId,
                        prUrl: prUrl,
                        status: status,
                        isLoading: isLoading,
                        onReject: () async {
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
                        onApprove: () async {
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
