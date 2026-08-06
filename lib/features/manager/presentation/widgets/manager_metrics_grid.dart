import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../data/manager_repository.dart';

/// Adaptive grid of executive metric cards displaying manager metrics.
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
          childAspectRatio: 1.5,
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

class _MetricCard extends StatefulWidget {
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
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        child: GlassCard(
          showGlow: _isHovered,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 16),
                  ),
                ],
              ),
              Text(
                widget.value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
