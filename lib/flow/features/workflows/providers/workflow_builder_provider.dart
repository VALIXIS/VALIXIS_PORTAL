import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/builder_step_model.dart';

class WorkflowBuilderState {
  final String workflowId;
  final String workflowName;
  final String workflowDescription;
  final bool isActive;
  final List<BuilderStep> steps;
  final BuilderStep? editingStep;
  final List<String> validationErrors;
  final bool isSaving;

  const WorkflowBuilderState({
    required this.workflowId,
    required this.workflowName,
    required this.workflowDescription,
    required this.isActive,
    required this.steps,
    this.editingStep,
    required this.validationErrors,
    required this.isSaving,
  });

  WorkflowBuilderState copyWith({
    String? workflowId,
    String? workflowName,
    String? workflowDescription,
    bool? isActive,
    List<BuilderStep>? steps,
    BuilderStep? editingStep,
    bool clearEditingStep = false,
    List<String>? validationErrors,
    bool? isSaving,
  }) {
    return WorkflowBuilderState(
      workflowId: workflowId ?? this.workflowId,
      workflowName: workflowName ?? this.workflowName,
      workflowDescription: workflowDescription ?? this.workflowDescription,
      isActive: isActive ?? this.isActive,
      steps: steps ?? this.steps,
      editingStep: clearEditingStep ? null : (editingStep ?? this.editingStep),
      validationErrors: validationErrors ?? this.validationErrors,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class WorkflowBuilderNotifier extends StateNotifier<WorkflowBuilderState> {
  WorkflowBuilderNotifier()
      : super(
          WorkflowBuilderState(
            workflowId: 'wf_enterprise_leads_01',
            workflowName: 'Inbound Website Contact ➔ AI Lead & Task Ingestion',
            workflowDescription: 'Converts website inquiries into CRM leads & tasks via Gemini AI.',
            isActive: true,
            steps: BuilderStep.defaultPipeline,
            validationErrors: const [],
            isSaving: false,
          ),
        ) {
    validateWorkflow();
  }

  void addStep(StepType type) {
    final nextOrder = state.steps.length + 1;
    final newId = 'step_${type.name}_${DateTime.now().millisecondsSinceEpoch}';

    String title;
    String description;
    String actionType = 'create_lead';
    Map<String, dynamic> config;

    switch (type) {
      case StepType.trigger:
        title = 'Custom Webhook Trigger';
        description = 'Inbound POST trigger endpoint.';
        config = {'webhook_slug': 'custom-trigger-$nextOrder', 'auth_required': true};
        break;
      case StepType.aiReasoning:
        title = 'Gemini AI Classification Node';
        description = 'Classifies intent & extracts entities.';
        config = {'model': 'gemini-2.5-flash', 'temperature': 0.2};
        break;
      case StepType.actionDispatcher:
        title = 'Business OS Task Dispatcher';
        description = 'Creates task in Business OS.';
        actionType = 'create_task';
        config = {'action_target': 'create_task', 'mapped_title': '{{ai.summary}}'};
        break;
    }

    final newStep = BuilderStep(
      id: newId,
      order: nextOrder,
      type: type,
      title: title,
      description: description,
      actionType: actionType,
      config: config,
    );

    final updatedSteps = [...state.steps, newStep];
    state = state.copyWith(steps: _reorderSteps(updatedSteps));
    validateWorkflow();
  }

  void deleteStep(String id) {
    if (state.steps.length <= 1) return; // Must have at least 1 step
    final updatedSteps = state.steps.where((s) => s.id != id).toList();
    state = state.copyWith(steps: _reorderSteps(updatedSteps));
    validateWorkflow();
  }

  void moveStep(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.steps.length || newIndex < 0 || newIndex >= state.steps.length) {
      return;
    }
    final steps = [...state.steps];
    final step = steps.removeAt(oldIndex);
    steps.insert(newIndex, step);
    state = state.copyWith(steps: _reorderSteps(steps));
    validateWorkflow();
  }

  void startEditingStep(BuilderStep step) {
    state = state.copyWith(editingStep: step);
  }

  void closeEditingStep() {
    state = state.copyWith(clearEditingStep: true);
  }

  void updateStepConfig(String id, Map<String, dynamic> newConfig, String? newActionType) {
    final updatedSteps = state.steps.map((step) {
      if (step.id == id) {
        return step.copyWith(
          config: newConfig,
          actionType: newActionType ?? step.actionType,
        );
      }
      return step;
    }).toList();

    state = state.copyWith(steps: updatedSteps, clearEditingStep: true);
    validateWorkflow();
  }

  void validateWorkflow() {
    final errors = <String>[];

    // Ensure at least 1 trigger step exists at start
    if (state.steps.isEmpty || state.steps.first.type != StepType.trigger) {
      errors.add('Workflow pipeline must begin with an Inbound Trigger step.');
    }

    // Validate email draft actions have recipient email mapping
    for (final step in state.steps) {
      if (step.actionType == 'draft_email') {
        final emailMapping = step.config['mapped_email'] as String?;
        if (emailMapping == null || emailMapping.isEmpty) {
          errors.add('Action step "${step.title}" (draft_email) requires a mapped recipient email variable.');
        }
      }
    }

    state = state.copyWith(validationErrors: errors);
  }

  Future<bool> saveWorkflow() async {
    validateWorkflow();
    if (state.validationErrors.isNotEmpty) return false;

    state = state.copyWith(isSaving: true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = state.copyWith(isSaving: false);
    return true;
  }

  List<BuilderStep> _reorderSteps(List<BuilderStep> steps) {
    return List.generate(steps.length, (i) => steps[i].copyWith(order: i + 1));
  }
}

final workflowBuilderProvider =
    StateNotifierProvider<WorkflowBuilderNotifier, WorkflowBuilderState>((ref) {
  return WorkflowBuilderNotifier();
});
