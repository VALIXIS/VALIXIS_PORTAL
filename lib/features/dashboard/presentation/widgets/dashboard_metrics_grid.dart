import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';

/// Grid of metric cards summarizing active task counts, completion rates, and gamified sprint progress bar.
class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({
    super.key,
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final total = pendingCount + completedCount;
    final progress = total > 0 ? (completedCount / total) : 0.0;
    final percentage = (progress * 100).round();

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 700;

    return Column(
      children: [
        Flex(
          direction: isCompact ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: isCompact ? 0 : 1,
              child: _StatCard(
                title: 'Pending Tasks',
                value: pendingCount.toString(),
                badgeText: 'Action Needed',
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: isCompact ? 0 : AppSpacing.md,
              height: isCompact ? AppSpacing.md : 0,
            ),
            Expanded(
              flex: isCompact ? 0 : 1,
              child: _StatCard(
                title: 'Completed Tasks',
                value: completedCount.toString(),
                badgeText: 'Verified & Merged',
                icon: Icons.task_alt_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          showGlow: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.workspace_premium_rounded, color: AppColors.brandCyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Weekly Sprint Progress',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.brandCyan.withAlpha(60)),
                    ),
                    child: Text(
                      '$percentage% Sprint Velocity',
                      style: const TextStyle(
                        color: AppColors.brandCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage == 100 ? AppColors.success : AppColors.brandCyan,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount of $total assigned tasks completed',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  Text(
                    percentage == 100 ? '🎉 Sprint Goal Achieved!' : '${100 - percentage}% remaining',
                    style: TextStyle(
                      color: percentage == 100 ? AppColors.success : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String badgeText;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
