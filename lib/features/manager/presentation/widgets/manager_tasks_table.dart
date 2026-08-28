import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';

/// Data table for Manager Tasks displaying task specifications, actual assigned employee, status, and interactive column sorting.
class ManagerTasksTable extends StatelessWidget {
  const ManagerTasksTable({
    super.key,
    required this.tasks,
    required this.onReassign,
    required this.onUnassign,
    required this.onDelete,
    this.sortField = 'deadline',
    this.sortAscending = true,
    this.onSort,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onReassign;
  final ValueChanged<Task> onUnassign;
  final ValueChanged<Task> onDelete;
  final String sortField;
  final bool sortAscending;
  final void Function(String field, bool ascending)? onSort;

  int? _getSortColumnIndex() {
    switch (sortField) {
      case 'title':
        return 0;
      case 'repo':
        return 1;
      case 'priority':
        return 2;
      case 'assignment':
        return 3;
      case 'deadline':
        return 4;
      case 'pr':
        return 5;
      default:
        return 4;
    }
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
          sortColumnIndex: _getSortColumnIndex(),
          sortAscending: sortAscending,
          columns: [
            DataColumn(
              label: const Text('Task Title', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              onSort: (index, asc) => onSort?.call('title', asc),
            ),
            DataColumn(
              label: const Text('Repository', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              onSort: (index, asc) => onSort?.call('repo', asc),
            ),
            DataColumn(
              label: const Text('Priority', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              onSort: (index, asc) => onSort?.call('priority', asc),
            ),
            DataColumn(
              label: const Text('Assignment', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              onSort: (index, asc) => onSort?.call('assignment', asc),
            ),
            DataColumn(
              label: const Text('Deadline', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              onSort: (index, asc) => onSort?.call('deadline', asc),
            ),
            DataColumn(
              label: const Text('PR Submitted', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              onSort: (index, asc) => onSort?.call('pr', asc),
            ),
            const DataColumn(
              label: Text('Actions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            ),
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
                        icon: const Icon(Icons.person_add_outlined, size: 18, color: AppColors.brandPurple),
                        tooltip: 'Reassign',
                        onPressed: () => onReassign(task),
                      ),
                      if (isAssigned)
                        IconButton(
                          icon: const Icon(Icons.person_remove_outlined, size: 18, color: AppColors.warning),
                          tooltip: 'Unassign',
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
