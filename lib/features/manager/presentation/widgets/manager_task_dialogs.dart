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
  static Future<bool?> showEditTaskDialog({
    required BuildContext context,
    required Task task,
    required ManagerRepository managerRepo,
  }) async {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? '');
    final objController = TextEditingController(text: task.objective ?? '');
    final promptController = TextEditingController(text: task.aiPrompt ?? '');
    final repoController = TextEditingController(text: task.githubRepo ?? 'VALIXIS_PORTAL');
    final branchController = TextEditingController(text: task.branchName ?? 'main');
    final outputController = TextEditingController(text: task.expectedOutput ?? '');
    TaskPriority selectedPriority = task.priority;
    DateTime selectedDeadline = task.deadline;
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

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
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppColors.brandCyan, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Edit Task #${task.id}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 580,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title
                        const Text('Task Title *', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: titleController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. Implement Real-time WebSocket Sync',
                            filled: true,
                            fillColor: AppColors.surfaceCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Priority and Deadline Row
                        Row(
                          children: [
                            // Priority
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Priority', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<TaskPriority>(
                                        value: selectedPriority,
                                        isExpanded: true,
                                        dropdownColor: AppColors.surfaceElevated,
                                        items: TaskPriority.values.map((p) {
                                          return DropdownMenuItem(
                                            value: p,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(p.label, style: TextStyle(color: p.color, fontSize: 13, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (p) {
                                          if (p != null) {
                                            setDialogState(() => selectedPriority = p);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Deadline
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deadline', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDeadline,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2035),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: AppColors.brandCyan,
                                                onPrimary: Colors.black,
                                                surface: AppColors.surfaceElevated,
                                                onSurface: AppColors.textPrimary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setDialogState(() => selectedDeadline = picked);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceCard,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.glassBorder),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${selectedDeadline.year}-${selectedDeadline.month.toString().padLeft(2, '0')}-${selectedDeadline.day.toString().padLeft(2, '0')}',
                                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.brandCyan),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Repository & Branch
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('GitHub Repository', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: repoController,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'VALIXIS_PORTAL',
                                      filled: true,
                                      fillColor: AppColors.surfaceCard,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Branch Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: branchController,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'feat/branch-name',
                                      filled: true,
                                      fillColor: AppColors.surfaceCard,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Description
                        const Text('Description', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: descController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Detailed task scope and requirements...',
                            filled: true,
                            fillColor: AppColors.surfaceCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Engineering Objective
                        const Text('Engineering Objective', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: objController,
                          maxLines: 2,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Architectural goal or deliverable...',
                            filled: true,
                            fillColor: AppColors.surfaceCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // AI Prompt Specification
                        const Text('AI Prompt Specification', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: promptController,
                          maxLines: 2,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: 'Prompt instructions for automated code assistance...',
                            filled: true,
                            fillColor: AppColors.surfaceCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setDialogState(() => isSubmitting = true);
                            try {
                              await managerRepo.updateTask(
                                taskId: task.id,
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                objective: objController.text.trim(),
                                aiPrompt: promptController.text.trim(),
                                githubRepo: repoController.text.trim(),
                                branchName: branchController.text.trim(),
                                expectedOutput: outputController.text.trim(),
                                priority: selectedPriority.value,
                                deadline: selectedDeadline.toUtc().toIso8601String(),
                              );
                              if (context.mounted) {
                                Navigator.pop(context, true);
                              }
                            } catch (e) {
                              setDialogState(() => isSubmitting = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update task: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
