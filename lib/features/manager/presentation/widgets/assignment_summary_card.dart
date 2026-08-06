import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/employee.dart';
import '../../../../shared/models/task.dart';

/// Preview summary card showing selected employee and target task specs.
class AssignmentSummaryCard extends StatelessWidget {
  const AssignmentSummaryCard({
    super.key,
    required this.selectedEmployee,
    required this.selectedTask,
  });

  final Employee? selectedEmployee;
  final Task? selectedTask;

  @override
  Widget build(BuildContext context) {
    if (selectedEmployee == null && selectedTask == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_turned_in_rounded,
                  color: AppColors.brandCyan, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Assignment Preview',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (selectedEmployee != null) ...[
            _SummaryRow(
              icon: Icons.person_outline_rounded,
              label: 'Employee:',
              value: '${selectedEmployee!.fullName} (${selectedEmployee!.email})',
              color: AppColors.brandBlue,
            ),
            const SizedBox(height: 6),
          ],
          if (selectedTask != null) ...[
            _SummaryRow(
              icon: Icons.task_alt_rounded,
              label: 'Target Task:',
              value: selectedTask!.title,
              color: AppColors.brandPurple,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
