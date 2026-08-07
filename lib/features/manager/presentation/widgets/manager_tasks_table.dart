import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';

/// Data table for Manager Tasks displaying task specifications, actual assigned employee, status, and management action triggers.
class ManagerTasksTable extends StatelessWidget {
  const ManagerTasksTable({
    super.key,
    required this.tasks,
    required this.onReassign,
    required this.onUnassign,
    required this.onDelete,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onReassign;
  final ValueChanged<Task> onUnassign;
  final ValueChanged<Task> onDelete;

  Widget _buildStatusBadge(TaskStatus status) {
    final String label;
    final Color color;

    switch (status) {
      case TaskStatus.assigned:
        label = 'Assigned';
        color = AppColors.brandPurple;
        break;
      case TaskStatus.inProgress:
        label = 'In Progress';
        color = AppColors.warning;
        break;
      case TaskStatus.submitted:
        label = 'Awaiting Review';
        color = AppColors.brandCyan;
        break;
      case TaskStatus.approved:
        label = 'Completed';
        color = AppColors.success;
        break;
      case TaskStatus.rejected:
        label = 'Changes Requested';
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildEmployeeCell(String assignedTo) {
    if (assignedTo.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Unassigned',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
    }

    final initials = assignedTo.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.brandCyan.withAlpha(40),
          child: Text(
            initials.isNotEmpty ? initials : 'E',
            style: const TextStyle(color: AppColors.brandCyan, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            assignedTo,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
          dataRowMaxHeight: 64,
          columns: const [
            DataColumn(label: Text('Task Title', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Assigned Employee', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Repository', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Priority', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Deadline', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('PR Submitted', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
          ],
          rows: tasks.map((task) {
            final hasPr = task.prUrl != null && task.prUrl!.isNotEmpty;
            final isAssigned = task.assignedTo.isNotEmpty;

            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(task.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(task.branchName ?? 'main', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                DataCell(_buildEmployeeCell(task.assignedTo)),
                DataCell(Text(task.githubRepo ?? 'VALIXIS_PORTAL', style: const TextStyle(color: AppColors.brandBlue, fontSize: 12, fontWeight: FontWeight.w600))),
                DataCell(Text(task.priority.label, style: TextStyle(color: task.priority.color, fontWeight: FontWeight.w700, fontSize: 12))),
                DataCell(_buildStatusBadge(task.status)),
                DataCell(Text(DateFormatter.formatShortDate(task.deadline), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: (hasPr ? AppColors.success : AppColors.textMuted).withAlpha(20), borderRadius: BorderRadius.circular(6)),
                    child: Text(hasPr ? 'Yes' : 'No', style: TextStyle(color: hasPr ? AppColors.success : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.brandCyan),
                        tooltip: 'View Task',
                        onPressed: () => context.go('/tasks/${task.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                        tooltip: 'Edit Task',
                        onPressed: () => context.go(AppRoutes.managerCreateTask),
                      ),
                      IconButton(
                        icon: const Icon(Icons.assignment_ind_outlined, size: 18, color: AppColors.brandBlue),
                        tooltip: 'Reassign Task',
                        onPressed: () => onReassign(task),
                      ),
                      if (isAssigned)
                        IconButton(
                          icon: const Icon(Icons.person_remove_outlined, size: 18, color: AppColors.warning),
                          tooltip: 'Unassign Task',
                          onPressed: () => onUnassign(task),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        tooltip: 'Delete Task',
                        onPressed: () => onDelete(task),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
