import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
            DataColumn(label: Text('Repository', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Priority', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Assignment', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Deadline', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('PR Submitted', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
          ],
          rows: tasks.map((task) {
            final hasPr = task.prUrl != null && task.prUrl!.isNotEmpty;
            final isAssigned = task.assignedTo.isNotEmpty && task.assignedTo != 'Unassigned';

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
                DataCell(Text(task.githubRepo ?? 'VALIXIS_PORTAL', style: const TextStyle(color: AppColors.brandBlue, fontSize: 12, fontWeight: FontWeight.w600))),
                DataCell(Text(task.priority.label, style: TextStyle(color: task.priority.color, fontWeight: FontWeight.w700, fontSize: 12))),
                DataCell(
                  isAssigned
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandPurple.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.brandPurple.withAlpha(80)),
                              ),
                              child: const Text(
                                'Assigned',
                                style: TextStyle(color: AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Text(
                                task.assignedTo,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.textMuted.withAlpha(80)),
                          ),
                          child: const Text(
                            'Unassigned',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
                DataCell(Text(DateFormatter.formatShortDate(task.deadline), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                DataCell(
                  hasPr
                      ? InkWell(
                          onTap: () async {
                            final uri = Uri.parse(task.prUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.success.withAlpha(90)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.success),
                                SizedBox(width: 4),
                                Text('Yes', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.textMuted.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                          child: const Text('No', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
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
                        onPressed: () => context.go(AppRoutes.managerCreateTask, extra: task),
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
