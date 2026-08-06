import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../activity/presentation/widgets/activity_timeline.dart';
import '../../activity/presentation/widgets/recent_activity_feed.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/dashboard_hero_banner.dart';
import 'widgets/dashboard_metrics_grid.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_recent_tasks.dart';
import 'widgets/dashboard_shimmer.dart';

/// Dashboard screen rendering employee hero greeting, quick actions, metric cards, timeline & recent tasks.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: dashboardAsync.when(
        loading: () => const DashboardShimmer(),
        error: (err, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load Dashboard',
            description: 'Failed to retrieve your activity data. Please retry.',
            action: AppButton(
              label: 'Retry Loading',
              prefixIcon: Icons.refresh_rounded,
              onPressed: () => ref.invalidate(dashboardProvider),
            ),
          ),
        ),
        data: (data) {
          final employee = data.employee;
          final recentTasks = data.recentTasks;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DashboardHeroBanner(employee: employee),
                    const SizedBox(height: AppSpacing.xl),
                    const DashboardQuickActions(),
                    const SizedBox(height: AppSpacing.xl),
                    DashboardMetricsGrid(
                      pendingCount: data.pendingCount,
                      completedCount: data.completedCount,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    DashboardRecentTasks(tasks: recentTasks),
                    const SizedBox(height: AppSpacing.xl),
                    const ActivityTimeline(),
                    const SizedBox(height: AppSpacing.xl),
                    const RecentActivityFeed(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
