import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/glass_card.dart';

/// Reusable section wrapper for form grouping with icon and title.
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

/// Basic information fields (Title, Description).
class BasicInfoFields extends StatelessWidget {
  const BasicInfoFields({
    super.key,
    required this.titleController,
    required this.descController,
  });

  final TextEditingController titleController;
  final TextEditingController descController;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Basic Information',
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.brandCyan,
      children: [
        AppTextField(
          controller: titleController,
          label: 'Task Title *',
          hint: 'e.g. Implement User Auth Flow',
          prefixIcon: Icons.title_rounded,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Task Title is required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: descController,
          label: 'Description',
          hint: 'Brief overview of context and requirements (Optional)',
          prefixIcon: Icons.description_rounded,
          maxLines: 2,
        ),
      ],
    );
  }
}

/// Technical specification fields (Objective, Expected Output).
class TechnicalSpecFields extends StatelessWidget {
  const TechnicalSpecFields({
    super.key,
    required this.objectiveController,
    required this.outputController,
  });

  final TextEditingController objectiveController;
  final TextEditingController outputController;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Technical Specification',
      icon: Icons.alt_route_rounded,
      iconColor: AppColors.brandBlue,
      children: [
        AppTextField(
          controller: objectiveController,
          label: 'Technical Objective',
          hint: 'Primary architectural or functional objective',
          prefixIcon: Icons.flag_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: outputController,
          label: 'Expected Output',
          hint: 'Functional UI deliverables or test coverage criteria',
          prefixIcon: Icons.verified_outlined,
        ),
      ],
    );
  }
}

/// AI Prompt and Git configuration fields.
class AiGitConfigFields extends StatelessWidget {
  const AiGitConfigFields({
    super.key,
    required this.promptController,
    required this.branchController,
    required this.repoController,
  });

  final TextEditingController promptController;
  final TextEditingController branchController;
  final TextEditingController repoController;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'AI & Git Configuration',
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.brandPurple,
      children: [
        AppTextField(
          controller: promptController,
          label: 'AI Prompt Specification *',
          hint: 'Contextual prompt instructions for AI code generation',
          prefixIcon: Icons.terminal_rounded,
          maxLines: 3,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'AI Prompt is required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: branchController,
                label: 'Git Branch Name',
                hint: 'feature/auth-flow',
                prefixIcon: Icons.account_tree_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: repoController,
                label: 'GitHub Repository',
                hint: 'e.g. VALIXIS/AI_PDF',
                prefixIcon: Icons.code_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Priority dropdown and deadline picker section.
class PriorityScheduleFields extends StatelessWidget {
  const PriorityScheduleFields({
    super.key,
    required this.priority,
    required this.deadline,
    required this.onPriorityChanged,
    required this.onPickDeadline,
  });

  final String priority;
  final DateTime? deadline;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onPickDeadline;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Priority & Schedule',
      icon: Icons.tune_rounded,
      iconColor: AppColors.warning,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: priority,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Priority Level',
                  prefixIcon: Icon(Icons.low_priority_rounded,
                      color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                ),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                ],
                onChanged: (val) {
                  if (val != null) onPriorityChanged(val);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: deadline == null
                    ? 'Set Deadline'
                    : 'Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                variant: AppButtonVariant.secondary,
                prefixIcon: Icons.calendar_month_rounded,
                onPressed: onPickDeadline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
