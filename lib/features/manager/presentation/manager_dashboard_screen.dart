import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/manager_metrics_grid.dart';
import 'widgets/manager_shimmer.dart';
import 'widgets/recent_submissions_card.dart';

/// Screen displaying the Manager Dashboard overview and metrics.
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: metricsAsync.when(
        loading: () => const ManagerShimmer(),
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load manager dashboard',
            description: err.toString(),
            action: AppButton(
              label: 'Retry Loading',
              onPressed: () => ref.refresh(managerDashboardProvider),
            ),
          ),
        ),
        data: (metrics) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Manager Overview',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Real-time metrics, submissions, and team workload.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppButton(
                          label: 'Create Task',
                          prefixIcon: Icons.add_rounded,
                          onPressed: () => context.go(AppRoutes.managerCreateTask),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: 'Assign Task',
                          prefixIcon: Icons.assignment_ind_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => context.go(AppRoutes.managerAssignments),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                ManagerMetricsGrid(metrics: metrics),
                const SizedBox(height: AppSpacing.xl),
                RecentSubmissionsCard(submissions: metrics.recentSubmissions),
              ],
            ),
          );
        },
      ),
    );
  }
}
