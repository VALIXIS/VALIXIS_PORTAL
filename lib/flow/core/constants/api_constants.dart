/// API Endpoints and SLA Latency Targets for VALIXIS Flow
class ApiConstants {
  ApiConstants._();

  static const String apiVersion = 'v1';
  static const String webhookBaseEndpoint = '/api/v1/flow/webhook';
  static const String aiNodeEndpoint = '/functions/v1/ai-decision-node';
  static const String actionDispatcherEndpoint = '/functions/v1/action-dispatcher';

  /// SLA Performance Target Thresholds
  static const int maxIngestionSlaMs = 150;
  static const int maxAiReasoningTargetMs = 2500;
  static const int maxPayloadSizeBytes = 1048576; // 1 MB
  static const int idempotencyTtlHours = 24;
}
