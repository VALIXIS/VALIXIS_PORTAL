import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../data/manager_repository.dart';

class ManagerMetricsGrid extends StatelessWidget {
  const ManagerMetricsGrid({super.key, required this.metrics});

  final ManagerDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
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
              title: 'Total Employees',
              value: metrics.totalEmployees.toString(),
              icon: Icons.people_alt_rounded,
              color: AppColors.brandCyan,
            ),
            _MetricCard(
              title: 'Total Tasks',
              value: metrics.totalTasks.toString(),
              icon: Icons.assignment_rounded,
              color: AppColors.brandBlue,
            ),
            _MetricCard(
              title: 'Assigned',
              value: metrics.assignedCount.toString(),
              icon: Icons.push_pin_rounded,
              color: AppColors.brandPurple,
            ),
            _MetricCard(
              title: 'In Progress',
              value: metrics.inProgressCount.toString(),
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
            ),
            _MetricCard(
              title: 'Submitted',
              value: metrics.submittedCount.toString(),
              icon: Icons.upload_file_rounded,
              color: AppColors.info,
            ),
            _MetricCard(
              title: 'Approved',
              value: metrics.approvedCount.toString(),
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            _MetricCard(
              title: 'Rejected',
              value: metrics.rejectedCount.toString(),
              icon: Icons.cancel_rounded,
              color: AppColors.error,
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
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.base),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
