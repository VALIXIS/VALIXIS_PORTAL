import 'dart:convert';

class StepLogDetail {
  final int stepNumber;
  final String stepName;
  final String stepType;
  final int durationMs;
  final String status; // 'success' | 'failure'
  final Map<String, dynamic> inputPayload;
  final Map<String, dynamic> outputPayload;
  final String? errorMessage;

  const StepLogDetail({
    required this.stepNumber,
    required this.stepName,
    required this.stepType,
    required this.durationMs,
    required this.status,
    required this.inputPayload,
    required this.outputPayload,
    this.errorMessage,
  });

  String get prettyInput => const JsonEncoder.withIndent('  ').convert(inputPayload);
  String get prettyOutput => const JsonEncoder.withIndent('  ').convert(outputPayload);
}

class ExecutionLog {
  final String id;
  final String workflowId;
  final String workflowName;
  final String triggerType;
  final String status; // 'running' | 'completed' | 'failed' | 'retrying'
  final int durationMs;
  final DateTime startedAt;
  final String? errorCode;
  final List<StepLogDetail> steps;

  const ExecutionLog({
    required this.id,
    required this.workflowId,
    required this.workflowName,
    required this.triggerType,
    required this.status,
    required this.durationMs,
    required this.startedAt,
    this.errorCode,
    required this.steps,
  });

  String get shortId => id.length > 8 ? id.substring(0, 8) : id;

  static final List<ExecutionLog> sampleLogs = [
    ExecutionLog(
      id: 'exec_77a982f1b4c300e1',
      workflowId: 'wf_enterprise_lead',
      workflowName: 'Website Contact ➔ AI Lead & Task',
      triggerType: 'webhook',
      status: 'completed',
      durationMs: 340,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      steps: [
        const StepLogDetail(
          stepNumber: 1,
          stepName: 'Inbound Webhook Intake',
          stepType: 'webhook',
          durationMs: 42,
          status: 'success',
          inputPayload: {
            'event': 'contact_form_submitted',
            'name': 'Sarah Jenkins',
            'email': 'sarah.j@acmecorp.com',
            'budget': '\$50,000+',
            'token': '[REDACTED]',
          },
          outputPayload: {
            'status': 'accepted',
            'execution_id': 'exec_77a982f1b4c300e1',
            'idempotency_key': 'idemp_883a0912f',
          },
        ),
        const StepLogDetail(
          stepNumber: 2,
          stepName: 'Gemini 2.5 Flash Structured Reasoning',
          stepType: 'ai_reasoning',
          durationMs: 180,
          status: 'success',
          inputPayload: {
            'prompt': 'Classify intent and extract entities from Sarah Jenkins inquiry',
          },
          outputPayload: {
            'intent': 'enterprise_lead',
            'lead_score': 95,
            'extracted_entities': {
              'full_name': 'Sarah Jenkins',
              'company_name': 'Acme Corp',
              'email': 'sarah.j@acmecorp.com',
              'estimated_budget': 50000,
            },
            'recommended_action': 'create_lead',
          },
        ),
        const StepLogDetail(
          stepNumber: 3,
          stepName: 'Business OS Lead Dispatcher',
          stepType: 'action_dispatcher',
          durationMs: 118,
          status: 'success',
          inputPayload: {
            'action': 'create_lead',
            'lead_name': 'Sarah Jenkins',
            'organization_id': 'org_valixis_main',
          },
          outputPayload: {
            'lead_id': 'lead_acme_9921',
            'task_id': 'task_followup_882',
            'email_draft_id': 'draft_reply_331',
          },
        ),
      ],
    ),
    ExecutionLog(
      id: 'exec_8832b910c221aa94',
      workflowId: 'wf_support_ticket',
      workflowName: 'Support Ticket ➔ Task Dispatch',
      triggerType: 'webhook',
      status: 'failed',
      durationMs: 820,
      startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      errorCode: 'DATABASE_TIMEOUT: PostgreSQL RPC transaction lock timeout after 800ms.',
      steps: [
        const StepLogDetail(
          stepNumber: 1,
          stepName: 'Inbound Webhook Intake',
          stepType: 'webhook',
          durationMs: 38,
          status: 'success',
          inputPayload: {
            'event': 'ticket_created',
            'ticket_id': 'BUG-992',
            'subject': 'Webhook signature mismatch',
          },
          outputPayload: {
            'status': 'accepted',
            'execution_id': 'exec_8832b910c221aa94',
          },
        ),
        const StepLogDetail(
          stepNumber: 2,
          stepName: 'Business OS Task Dispatcher',
          stepType: 'action_dispatcher',
          durationMs: 782,
          status: 'failure',
          errorMessage: 'PostgreSQL connection timeout during create_task RPC transaction lock.',
          inputPayload: {
            'action': 'create_task',
            'ticket_id': 'BUG-992',
          },
          outputPayload: {
            'error': 'DATABASE_TIMEOUT',
          },
        ),
      ],
    ),
    ExecutionLog(
      id: 'exec_99201a44c33001e2',
      workflowId: 'wf_ecommerce_order',
      workflowName: 'E-Commerce Order ➔ Draft Kickoff Email',
      triggerType: 'webhook',
      status: 'running',
      durationMs: 110,
      startedAt: DateTime.now().subtract(const Duration(seconds: 2)),
      steps: [
        const StepLogDetail(
          stepNumber: 1,
          stepName: 'Inbound Webhook Intake',
          stepType: 'webhook',
          durationMs: 35,
          status: 'success',
          inputPayload: {
            'event': 'order_completed',
            'order_id': 'ORD-9912',
          },
          outputPayload: {
            'status': 'accepted',
          },
        ),
      ],
    ),
  ];
}
