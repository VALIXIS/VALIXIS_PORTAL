import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/models/employee.dart';
import '../../../shared/models/task.dart';
import 'providers/assignment_provider.dart';
import 'providers/employee_management_provider.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/assignment_summary_card.dart';

/// Screen for assigning engineering tasks to team employees.
class AssignTaskScreen extends ConsumerStatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  ConsumerState<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends ConsumerState<AssignTaskScreen> {
  String? _selectedEmployeeId;
  String? _selectedTaskId;

  Future<void> _assign() async {
    if (_selectedEmployeeId == null || _selectedTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both an Employee and a Task'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success =
        await ref.read(assignmentNotifierProvider.notifier).assignTask(
              taskId: _selectedTaskId!,
              employeeId: _selectedEmployeeId!,
            );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task assigned successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(managerDashboardProvider);
        ref.invalidate(employeeManagementProvider);
        context.go(AppRoutes.managerDashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to assign task.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeManagementProvider);
    final metricsAsync = ref.watch(managerDashboardProvider);
    final assignmentState = ref.watch(assignmentNotifierProvider);
    final isLoading = assignmentState.isLoading;

    final employees = employeesAsync.valueOrNull ?? [];
    final tasks = metricsAsync.valueOrNull?.recentTasks ?? [];

    Employee? selectedEmployee;
    if (_selectedEmployeeId != null) {
      for (final e in employees) {
        if (e.employee.id == _selectedEmployeeId) {
          selectedEmployee = e.employee;
          break;
        }
      }
    }

    Task? selectedTask;
    if (_selectedTaskId != null) {
      for (final t in tasks) {
        if (t.id == _selectedTaskId) {
          selectedTask = t;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(AppRoutes.managerDashboard),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Task Allocation & Assignment',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Allocate task specifications to enterprise team members',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                GlassCard(
                  showGlow: true,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person_search_rounded,
                              color: AppColors.brandCyan, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            '1. Select Employee',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedEmployeeId,
                        dropdownColor: AppColors.surfaceElevated,
                        style: const TextStyle(color: AppColors.textPrimary),
                        hint: const Text('Choose an employee from team roster',
                            style: TextStyle(color: AppColors.textMuted)),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                        ),
                        items: employees
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.employee.id,
                                child: Text(
                                  '${e.employee.fullName} (${e.employee.email})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedEmployeeId = val),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: const [
                          Icon(Icons.assignment_late_rounded,
                              color: AppColors.brandBlue, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            '2. Select Task Specification',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTaskId,
                        dropdownColor: AppColors.surfaceElevated,
                        style: const TextStyle(color: AppColors.textPrimary),
                        hint: const Text('Choose an unassigned task',
                            style: TextStyle(color: AppColors.textMuted)),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.task_alt_rounded,
                              color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                        ),
                        items: tasks
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(
                                  t.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedTaskId = val),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AssignmentSummaryCard(
                        selectedEmployee: selectedEmployee,
                        selectedTask: selectedTask,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Assign Task Now',
                        prefixIcon: Icons.send_rounded,
                        onPressed: isLoading ? null : _assign,
                        isLoading: isLoading,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
