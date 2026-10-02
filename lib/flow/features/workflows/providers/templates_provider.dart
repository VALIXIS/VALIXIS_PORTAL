import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flagship_template_model.dart';

class TemplatesState {
  final List<FlagshipTemplate> templates;
  final String? provisioningSlug;
  final String? lastProvisionedWorkflowId;

  const TemplatesState({
    required this.templates,
    this.provisioningSlug,
    this.lastProvisionedWorkflowId,
  });

  TemplatesState copyWith({
    List<FlagshipTemplate>? templates,
    String? provisioningSlug,
    String? lastProvisionedWorkflowId,
    bool clearProvisioning = false,
  }) {
    return TemplatesState(
      templates: templates ?? this.templates,
      provisioningSlug: clearProvisioning ? null : (provisioningSlug ?? this.provisioningSlug),
      lastProvisionedWorkflowId: lastProvisionedWorkflowId ?? this.lastProvisionedWorkflowId,
    );
  }
}

class TemplatesNotifier extends StateNotifier<TemplatesState> {
  TemplatesNotifier()
      : super(
          const TemplatesState(
            templates: FlagshipTemplate.catalog,
          ),
        );

  Future<bool> provisionTemplate(String slug) async {
    state = state.copyWith(provisioningSlug: slug);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newWfId = 'wf_prov_${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(
      clearProvisioning: true,
      lastProvisionedWorkflowId: newWfId,
    );
    return true;
  }
}

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, TemplatesState>((ref) {
  return TemplatesNotifier();
});
