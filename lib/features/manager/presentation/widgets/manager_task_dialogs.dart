import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/models/task.dart';
import '../../data/manager_repository.dart';

/// Modal dialogs for task reassigning, unassigning, and deleting with confirmation checks.
abstract final class ManagerTaskDialogs {
  static Future<bool?> showReassignDialog({
    required BuildContext context,
    required Task task,
    required List<Map<String, dynamic>> employees,
    required ManagerRepository managerRepo,
  }) async {
    String? selectedEmpId;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.glassBorder),
              ),
              title: Text(
                'Reassign Task "${task.title}"',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select an employee to assign this task:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: AppSpacing.md),
                  ...employees.map((emp) {
                    final empId = emp['id']?.toString() ?? emp['auth_id']?.toString() ?? '';
                    final empName = emp['name'] as String? ?? emp['full_name'] as String? ?? 'Employee';
                    final isSelected = selectedEmpId == empId;

                    return InkWell(
                      onTap: () => setDialogState(() => selectedEmpId = empId),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.brandCyan.withValues(alpha: 0.15) : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.brandCyan : AppColors.glassBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              empName,
                              style: TextStyle(
                                color: isSelected ? AppColors.brandCyan : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.brandCyan),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: selectedEmpId == null
                      ? null
                      : () {
                          Navigator.pop(context, true);
                          managerRepo.assignTask(taskId: task.id, employeeId: selectedEmpId!);
                        },
                  child: const Text('Reassign', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<bool?> showUnassignDialog({
    required BuildContext context,
    required Task task,
    required ManagerRepository managerRepo,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text('Unassign Task', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to remove assignment from "${task.title}"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unassign', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      managerRepo.unassignTask(task.id);
      return true;
    }
    return false;
  }

  static Future<bool?> showDeleteDialog({
    required BuildContext context,
    required Task task,
    required ManagerRepository managerRepo,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        title: const Text('Delete Task?', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
        content: Text('Delete "${task.title}"?\nThis action cannot be undone and will remove all related submissions and assignments.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Permanently', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      managerRepo.deleteTask(task.id);
      return true;
    }
    return false;
  }
}
