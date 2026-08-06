import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';

/// Stat summary section for profile displaying task metrics.
class ProfileMetricsSummary extends StatelessWidget {
  const ProfileMetricsSummary({
    super.key,
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final totalCount = pendingCount + completedCount;

    return Row(
      children: [
        Expanded(
          child: _MetricItem(
            title: 'Assigned',
            value: '$totalCount',
            icon: Icons.assignment_outlined,
            color: AppColors.brandBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricItem(
            title: 'In Progress',
            value: '$pendingCount',
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricItem(
            title: 'Completed',
            value: '$completedCount',
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
