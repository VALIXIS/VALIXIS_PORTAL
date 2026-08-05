import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/assignment_provider.dart';
import 'providers/employee_management_provider.dart';
import 'providers/manager_dashboard_provider.dart';

/// Screen for assigning tasks to employees.
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

    final success = await ref.read(assignmentNotifierProvider.notifier).assignTask(
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go(AppRoutes.managerDashboard),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Assign Task',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Employee',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEmployeeId,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(color: AppColors.textPrimary),
                    hint: const Text('Choose an employee', style: TextStyle(color: AppColors.textMuted)),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                    ),
                    items: employees
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.employee.id,
                            child: Text('${e.employee.fullName} (${e.employee.email})'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedEmployeeId = val),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Select Task',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTaskId,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(color: AppColors.textPrimary),
                    hint: const Text('Choose a task', style: TextStyle(color: AppColors.textMuted)),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                    ),
                    items: tasks
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.title),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedTaskId = val),
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
    );
  }
}
