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

  static const List<ExecutionLog> sampleLogs = [];
}
