import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/create_task_provider.dart';
import 'providers/manager_dashboard_provider.dart';

/// Form screen for creating new engineering tasks.
class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _promptController = TextEditingController();
  final _outputController = TextEditingController();
  final _branchController = TextEditingController();
  final _repoController = TextEditingController();

  String _priority = 'Medium';
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _objectiveController.dispose();
    _promptController.dispose();
    _outputController.dispose();
    _branchController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success =
          await ref.read(createTaskNotifierProvider.notifier).createTask(
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                objective: _objectiveController.text.trim(),
                aiPrompt: _promptController.text.trim(),
                expectedOutput: _outputController.text.trim(),
                branchName: _branchController.text.trim(),
                githubRepo: _repoController.text.trim(),
                priority: _priority,
                deadline: _deadline?.toIso8601String(),
              );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.invalidate(managerDashboardProvider);
          context.go(AppRoutes.managerDashboard);
        } else {
          final error = ref.read(createTaskNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create task: ${error ?? "Unknown error"}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTaskNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
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
                    'Create New Task',
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
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Task Title *',
                      hint: 'Implement User Auth Flow',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Task Title is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _descController,
                      label: 'Description *',
                      hint: 'Brief overview of task context',
                      maxLines: 2,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _objectiveController,
                      label: 'Objective',
                      hint: 'Primary technical goal',
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _promptController,
                      label: 'AI Prompt *',
                      hint: 'Contextual prompt for AI assistant',
                      maxLines: 3,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'AI Prompt is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _branchController,
                            label: 'Branch Name',
                            hint: 'feature/auth-screen',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            controller: _repoController,
                            label: 'GitHub Repository',
                            hint: 'https://github.com/valixis/portal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _outputController,
                      label: 'Expected Output',
                      hint: 'Functional login UI with error handling',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _priority,
                            dropdownColor: AppColors.surfaceElevated,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              filled: true,
                              fillColor: AppColors.surfaceElevated,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Low', child: Text('Low')),
                              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                              DropdownMenuItem(value: 'High', child: Text('High')),
                              DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                            ],
                            onChanged: (val) => setState(() => _priority = val ?? 'Medium'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: _deadline == null
                                ? 'Set Deadline'
                                : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                            variant: AppButtonVariant.secondary,
                            prefixIcon: Icons.calendar_month_rounded,
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => _deadline = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Create Task',
                      onPressed: isLoading ? null : _submit,
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
    );
  }
}
