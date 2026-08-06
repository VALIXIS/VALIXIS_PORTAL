import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
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
      body: metricsAsync.when(
        loading: () => const ManagerShimmer(),
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load Manager Dashboard',
            description: err.toString(),
            action: AppButton(
              label: 'Retry Loading',
              prefixIcon: Icons.refresh_rounded,
              onPressed: () => ref.refresh(managerDashboardProvider),
            ),
          ),
        ),
        data: (metrics) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ManagerHeroHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  const ManagerQuickActions(),
                  const SizedBox(height: AppSpacing.xl),
                  ManagerMetricsGrid(metrics: metrics),
                  const SizedBox(height: AppSpacing.xl),
                  RecentSubmissionsCard(
                    submissions: metrics.recentSubmissions,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
