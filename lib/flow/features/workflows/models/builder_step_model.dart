import 'dart:convert';

enum StepType { trigger, aiReasoning, actionDispatcher }

class BuilderStep {
  final String id;
  final int order;
  final StepType type;
  final String title;
  final String description;
  final String actionType; // 'create_lead' | 'create_task' | 'draft_email'
  final Map<String, dynamic> config;

  const BuilderStep({
    required this.id,
    required this.order,
    required this.type,
    required this.title,
    required this.description,
    this.actionType = 'create_lead',
    required this.config,
  });

  BuilderStep copyWith({
    String? id,
    int? order,
    StepType? type,
    String? title,
    String? description,
    String? actionType,
    Map<String, dynamic>? config,
  }) {
    return BuilderStep(
      id: id ?? this.id,
      order: order ?? this.order,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      config: config ?? this.config,
    );
  }

  String get prettyConfig => const JsonEncoder.withIndent('  ').convert(config);

  static final List<BuilderStep> defaultPipeline = [
    const BuilderStep(
      id: 'step_trigger_1',
      order: 1,
      type: StepType.trigger,
      title: 'Inbound Webhook Intake',
      description: 'Ingests website contact form webhooks (< 150ms SLA).',
      config: {
        'webhook_slug': 'inbound-leads-99',
        'auth_required': true,
        'hmac_header': 'X-Valixis-Signature',
      },
    ),
    const BuilderStep(
      id: 'step_ai_2',
      order: 2,
      type: StepType.aiReasoning,
      title: 'Gemini 2.5 Flash Structured AI Reasoning',
      description: 'Extracts intent, lead score (0-100), and contact details.',
      config: {
        'model': 'gemini-2.5-flash',
        'temperature': 0.2,
        'required_entities': ['full_name', 'email', 'budget', 'urgency'],
        'prompt_instructions': 'Extract business intent and lead value from payload.',
      },
    ),
    const BuilderStep(
      id: 'step_action_3',
      order: 3,
      type: StepType.actionDispatcher,
      title: 'Business OS Lead & Task Ingestion',
      description: 'Atomically creates CRM lead & assigns sales rep.',
      actionType: 'create_lead',
      config: {
        'action_target': 'create_lead',
        'mapped_name': '{{trigger.name}}',
        'mapped_email': '{{trigger.email}}',
        'mapped_budget': '{{ai.extracted_budget}}',
        'auto_assign': 'lowest_workload_rep',
      },
    ),
  ];
}
