import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../data/manager_repository.dart';

/// Adaptive grid of executive metric cards with direct navigation triggers.
class ManagerMetricsGrid extends StatelessWidget {
  const ManagerMetricsGrid({super.key, required this.metrics});

  final ManagerDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final activeTasksCount = metrics.assignedCount + metrics.inProgressCount;
    final overdueCount = metrics.recentTasks
        .where((t) => t.deadline.isBefore(DateTime.now()) && !t.status.isCompleted)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 3 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _MetricCard(
              title: 'Total Tasks',
              value: metrics.totalTasks.toString(),
              icon: Icons.assignment_rounded,
              color: AppColors.brandBlue,
              onTap: () => context.go(AppRoutes.managerTasks),
            ),
            _MetricCard(
              title: 'Active Tasks',
              value: activeTasksCount.toString(),
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
              onTap: () => context.go('${AppRoutes.managerTasks}?status=active'),
            ),
            _MetricCard(
              title: 'Pending Reviews',
              value: metrics.submittedCount.toString(),
              icon: Icons.rate_review_rounded,
              color: AppColors.brandCyan,
              onTap: () => context.go(AppRoutes.managerReviews),
            ),
            _MetricCard(
              title: 'Completed Tasks',
              value: metrics.approvedCount.toString(),
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              onTap: () => context.go('${AppRoutes.managerTasks}?status=completed'),
            ),
            _MetricCard(
              title: 'Employees',
              value: metrics.totalEmployees.toString(),
              icon: Icons.people_alt_rounded,
              color: AppColors.brandPurple,
              onTap: () => context.go(AppRoutes.managerEmployees),
            ),
            _MetricCard(
              title: 'Overdue Tasks',
              value: overdueCount.toString(),
              icon: Icons.warning_amber_rounded,
              color: AppColors.error,
              onTap: () => context.go('${AppRoutes.managerTasks}?status=overdue'),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          showGlow: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
