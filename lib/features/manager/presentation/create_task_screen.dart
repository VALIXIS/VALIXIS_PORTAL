import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/models/task.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
import 'providers/create_task_provider.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/create_task_form_sections.dart';

/// Form screen for creating or editing engineering tasks with glassmorphism sections.
class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key, this.taskToEdit});

  final Task? taskToEdit;

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

  bool get _isEditMode => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _objectiveController.text = t.objective ?? '';
      _promptController.text = t.aiPrompt ?? '';
      _outputController.text = t.expectedOutput ?? '';
      _branchController.text = t.branchName ?? '';
      _repoController.text = t.githubRepo ?? '';
      _priority = t.priority.label;
      _deadline = t.deadline;
    }
  }

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

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _objectiveController.clear();
    _promptController.clear();
    _outputController.clear();
    _branchController.clear();
    _repoController.clear();
    setState(() {
      _priority = 'Medium';
      _deadline = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isEditMode) {
        final success = await ref.read(createTaskNotifierProvider.notifier).updateTask(
              taskId: widget.taskToEdit!.id,
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
                content: Text('Task updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            ref.invalidate(managerDashboardProvider);
            ref.invalidate(tasksProvider);
            context.go(AppRoutes.managerTasks);
          } else {
            final error = ref.read(createTaskNotifierProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update task: ${error ?? "Unknown error"}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        final success = await ref.read(createTaskNotifierProvider.notifier).createTask(
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
            ref.invalidate(tasksProvider);
            _clearForm();
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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTaskNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.go(_isEditMode ? AppRoutes.managerTasks : AppRoutes.managerDashboard),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode ? 'Edit Task Specification' : 'Create New Task Specification',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEditMode
                                ? 'Update technical goals, AI prompts, and repository target'
                                : 'Define technical goals, AI prompts, and repository target',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BasicInfoFields(
                    titleController: _titleController,
                    descController: _descController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TechnicalSpecFields(
                    objectiveController: _objectiveController,
                    outputController: _outputController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AiGitConfigFields(
                    promptController: _promptController,
                    branchController: _branchController,
                    repoController: _repoController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PriorityScheduleFields(
                    priority: _priority,
                    deadline: _deadline,
                    onPriorityChanged: (val) => setState(() => _priority = val),
                    onPickDeadline: _pickDeadline,
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  AppButton(
                    label: _isEditMode ? 'Update Task Specification' : 'Create Task Specification',
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                    prefixIcon: _isEditMode ? Icons.save_rounded : Icons.add_task_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
