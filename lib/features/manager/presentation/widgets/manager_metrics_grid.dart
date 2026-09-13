import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
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
              title: 'TOTAL TASKS',
              value: metrics.totalTasks.toString(),
              subtitle: 'Fleet operations catalog',
              icon: Icons.assignment_rounded,
              color: AppColors.brandBlue,
              onTap: () => context.go(AppRoutes.managerTasks),
            ),
            _MetricCard(
              title: 'IN ACTIVE FLIGHT',
              value: activeTasksCount.toString(),
              subtitle: '${metrics.inProgressCount} in progress',
              icon: Icons.bolt_rounded,
              color: AppColors.brandCyan,
              onTap: () => context.go('${AppRoutes.managerTasks}?status=active'),
            ),
            _MetricCard(
              title: 'PENDING REVIEWS',
              value: metrics.submittedCount.toString(),
              subtitle: 'Awaiting PR verification',
              icon: Icons.rate_review_rounded,
              color: AppColors.telemetryViolet,
              onTap: () => context.go(AppRoutes.managerReviews),
            ),
            _MetricCard(
              title: 'COMPLETED',
              value: metrics.approvedCount.toString(),
              subtitle: 'Merged & verified',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              onTap: () => context.go('${AppRoutes.managerTasks}?status=completed'),
            ),
            _MetricCard(
              title: 'PERSONNEL',
              value: metrics.totalEmployees.toString(),
              subtitle: 'Active engineer nodes',
              icon: Icons.people_alt_rounded,
              color: AppColors.telemetryIndigo,
              onTap: () => context.go(AppRoutes.managerEmployees),
            ),
            _MetricCard(
              title: 'CRITICAL / OVERDUE',
              value: overdueCount.toString(),
              subtitle: overdueCount > 0 ? 'Requires attention' : 'Nominal deadline pace',
              icon: Icons.warning_amber_rounded,
              color: overdueCount > 0 ? AppColors.error : AppColors.textMuted,
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
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isInteractive: true,
      onTap: onTap,
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
                style: AppTypography.telemetryHeader(
                  size: 10,
                  color: AppColors.textMuted,
                  spacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTypography.metricValue(
                      size: 28,
                      weight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

