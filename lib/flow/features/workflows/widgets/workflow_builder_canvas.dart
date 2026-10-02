import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/builder_step_model.dart';
import '../providers/workflow_builder_provider.dart';
import 'step_config_dialog.dart';

class WorkflowBuilderCanvas extends ConsumerWidget {
  const WorkflowBuilderCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowBuilderProvider);
    final notifier = ref.read(workflowBuilderProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Canvas Header & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_tree, color: AppColors.electricCyan, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        state.workflowName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.workflowDescription,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final success = await notifier.saveWorkflow();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Workflow pipeline saved to Supabase successfully!'
                                    : 'Validation Error: Check workflow requirements.',
                              ),
                              backgroundColor: success ? AppColors.emeraldGreen : AppColors.coralRed,
                            ),
                          );
                        }
                      },
                icon: state.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save, size: 16),
                label: const Text('Save Workflow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldGreen,
                  foregroundColor: AppColors.obsidianDark,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Realtime Validation Errors Box
          if (state.validationErrors.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.coralRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.validationErrors.map((err) {
                  return Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.coralRed, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          err,
                          style: const TextStyle(color: AppColors.coralRed, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Visual Linear Sequential Canvas Nodes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Linear Automation Canvas',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Render Steps Sequence
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.steps.length,
                    separatorBuilder: (_, __) => _buildConnectorArrow(),
                    itemBuilder: (context, index) {
                      final step = state.steps[index];
                      return _buildStepNode(context, ref, step, index, state.steps.length);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Add Step (+) Menu Buttons
                  Row(
                    children: [
                      _buildAddStepButton(ref, StepType.aiReasoning, '+ AI Reasoning Step', AppColors.electricCyan),
                      const SizedBox(width: 12),
                      _buildAddStepButton(ref, StepType.actionDispatcher, '+ Action Dispatcher', AppColors.violetAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(
    BuildContext context,
    WidgetRef ref,
    BuilderStep step,
    int index,
    int totalSteps,
  ) {
    final notifier = ref.read(workflowBuilderProvider.notifier);

    Color borderAccent;
    IconData icon;

    switch (step.type) {
      case StepType.trigger:
        borderAccent = AppColors.emeraldGreen;
        icon = Icons.bolt;
        break;
      case StepType.aiReasoning:
        borderAccent = AppColors.electricCyan;
        icon = Icons.psychology;
        break;
      case StepType.actionDispatcher:
        borderAccent = AppColors.violetAccent;
        icon = Icons.send_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.obsidianSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderAccent.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Step Index Circle
          CircleAvatar(
            radius: 14,
            backgroundColor: borderAccent.withValues(alpha: 0.2),
            child: Text(
              '${step.order}',
              style: TextStyle(color: borderAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),

          // Icon & Titles
          Icon(icon, color: borderAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  step.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          // Actions: Reorder Up, Reorder Down, Configure, Delete
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18, color: AppColors.textSecondary),
                onPressed: index > 0 ? () => notifier.moveStep(index, index - 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18, color: AppColors.textSecondary),
                onPressed: index < totalSteps - 1 ? () => notifier.moveStep(index, index + 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 18, color: AppColors.electricCyan),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => StepConfigDialog(
                      step: step,
                      onSave: (newConfig, newActionType) {
                        notifier.updateStepConfig(step.id, newConfig, newActionType);
                      },
                    ),
                  );
                },
              ),
              if (totalSteps > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.coralRed),
                  onPressed: () => notifier.deleteStep(step.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.obsidianCard,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.electricCyan.withValues(alpha: 0.5)),
          ),
          child: const Icon(Icons.arrow_downward, color: AppColors.electricCyan, size: 16),
        ),
      ),
    );
  }

  Widget _buildAddStepButton(WidgetRef ref, StepType type, String label, Color color) {
    final notifier = ref.read(workflowBuilderProvider.notifier);
    return OutlinedButton(
      onPressed: () => notifier.addStep(type),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
