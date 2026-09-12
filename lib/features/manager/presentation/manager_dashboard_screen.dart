import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/realtime_sync_service.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/manager_hero_header.dart';
import 'widgets/manager_metrics_grid.dart';
import 'widgets/manager_quick_actions.dart';
import 'widgets/manager_shimmer.dart';
import 'widgets/recent_submissions_card.dart';

/// Executive Manager Dashboard rendering real-time metrics, quick actions, and PR submissions.
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.brandCyan,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          ref.read(realtimeSyncProvider.notifier).forceRefresh();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: metricsAsync.when(
          loading: () => const ManagerShimmer(),
          error: (err, _) => Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Unable to Load Manager Dashboard',
                description: err.toString(),
                action: AppButton(
                  label: 'Retry Connection',
                  prefixIcon: Icons.refresh_rounded,
                  onPressed: () {
                    ref.read(realtimeSyncProvider.notifier).forceRefresh();
                  },
                ),
              ),
            ),
          ),
          data: (metrics) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ManagerHeroHeader(),
                  const SizedBox(height: AppSpacing.base),
                  const ManagerQuickActions(),
                  const SizedBox(height: AppSpacing.base),
                  ManagerMetricsGrid(metrics: metrics),
                  const SizedBox(height: AppSpacing.base),
                  RecentSubmissionsCard(
                    submissions: metrics.recentSubmissions,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
