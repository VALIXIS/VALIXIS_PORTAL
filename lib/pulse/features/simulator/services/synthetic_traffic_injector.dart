import 'dart:math' as math;
import '../models/simulation_scenario.dart';
import '../../telemetry/models/telemetry_event.dart';

class SyntheticTrafficInjector {
  final math.Random _random = math.Random();

  /// Generates synthetic raw telemetry payloads for benchmark testing.
  List<Map<String, dynamic>> generateSyntheticEvents({
    required SimulationScenario scenario,
    required int count,
    required String organizationId,
  }) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      double metricVal;
      String eventType;

      switch (scenario.type) {
        case SimulationScenarioType.blackFridaySurge:
          eventType = 'checkout_automation_executed';
          metricVal = 150.0 + _random.nextDouble() * 500.0;
          break;
        case SimulationScenarioType.stripeOutage:
          eventType = 'webhook_payment_timeout';
          metricVal = scenario.targetLatencyMs.toDouble() + _random.nextDouble() * 100.0;
          break;
        case SimulationScenarioType.conversionCrash:
          eventType = 'cart_abandonment_recorded';
          metricVal = 1.0;
          break;
        case SimulationScenarioType.normalDay:
          eventType = 'crm_lead_activity';
          metricVal = 25.0 + _random.nextDouble() * 50.0;
          break;
      }

      return {
        'id': 'syn_evt_${now.millisecondsSinceEpoch}_$i',
        'organization_id': organizationId,
        'source_system': scenario.anomalySource ?? 'business_os',
        'event_type': eventType,
        'metric_value': metricVal,
        'payload': {
          'scenario': scenario.type.code,
          'simulated_latency_ms': scenario.targetLatencyMs,
          'batch_index': i,
        },
        'created_at': now.subtract(Duration(milliseconds: i * 20)).toIso8601String(),
      };
    });
  }

  /// Calculates next simulated live MetricSnapshot for real-time visual feedback.
  MetricSnapshot computeSimulatedSnapshot({
    required SimulationScenario scenario,
    required String organizationId,
    required int stepIndex,
  }) {
    final now = DateTime.now();
    final noise = (_random.nextDouble() - 0.5) * 0.05; // +/- 5% variance

    double arr = scenario.targetArrUsd * (1.0 + noise);
    int activeUsers = (scenario.targetActiveUsers * (1.0 + noise)).round();
    double churn = (scenario.targetChurnRisk * (1.0 + noise)).clamp(0.5, 99.0);
    int latency = (scenario.targetLatencyMs * (1.0 + noise)).round();

    return MetricSnapshot(
      id: 'snap_sim_${now.millisecondsSinceEpoch}_$stepIndex',
      organizationId: organizationId,
      timestamp: now,
      arrUsd: arr,
      activeUsers: activeUsers,
      churnRiskScore: churn,
      webhookLatencyP95: latency,
      statusHealth: scenario.statusHealth,
    );
  }
}
