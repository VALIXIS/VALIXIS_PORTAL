class TelemetryEvent {
  final String id;
  final String organizationId;
  final String sourceSystem; // 'business_os', 'flow', 'pulse'
  final String eventType;
  final Map<String, dynamic> payload;
  final int ingestionLatencyMs;
  final DateTime createdAt;

  TelemetryEvent({
    required this.id,
    required this.organizationId,
    required this.sourceSystem,
    required this.eventType,
    required this.payload,
    this.ingestionLatencyMs = 15,
    required this.createdAt,
  });

  factory TelemetryEvent.fromJson(Map<String, dynamic> json) {
    return TelemetryEvent(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      sourceSystem: json['source_system'] ?? 'pulse',
      eventType: json['event_type'] ?? '',
      payload: json['payload'] is Map<String, dynamic> ? json['payload'] : {},
      ingestionLatencyMs: json['ingestion_latency_ms'] ?? 15,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'source_system': sourceSystem,
      'event_type': eventType,
      'payload': payload,
      'ingestion_latency_ms': ingestionLatencyMs,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MetricSnapshot {
  final String id;
  final String organizationId;
  final DateTime timestamp;
  final double arrUsd;
  final int activeUsers;
  final double churnRiskScore;
  final int webhookLatencyP95;
  final String statusHealth; // 'optimal', 'growth', 'critical'

  MetricSnapshot({
    required this.id,
    required this.organizationId,
    required this.timestamp,
    required this.arrUsd,
    required this.activeUsers,
    required this.churnRiskScore,
    required this.webhookLatencyP95,
    required this.statusHealth,
  });

  factory MetricSnapshot.fromJson(Map<String, dynamic> json) {
    return MetricSnapshot(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      arrUsd: (json['arr_usd'] as num?)?.toDouble() ?? 0.0,
      activeUsers: json['active_users'] ?? 0,
      churnRiskScore: (json['churn_risk_score'] as num?)?.toDouble() ?? 0.0,
      webhookLatencyP95: json['webhook_latency_p95'] ?? 25,
      statusHealth: json['status_health'] ?? 'optimal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'timestamp': timestamp.toIso8601String(),
      'arr_usd': arrUsd,
      'active_users': activeUsers,
      'churn_risk_score': churnRiskScore,
      'webhook_latency_p95': webhookLatencyP95,
      'status_health': statusHealth,
    };
  }
}

class AnomalyAlert {
  final String id;
  final String organizationId;
  final String title;
  final String severity; // 'critical', 'warning', 'info'
  final String source;
  final String metric;
  final double currentValue;
  final double thresholdValue;
  final String status; // 'active', 'resolved', 'self_healing_dispatched'
  final DateTime createdAt;

  AnomalyAlert({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.severity,
    required this.source,
    required this.metric,
    required this.currentValue,
    required this.thresholdValue,
    required this.status,
    required this.createdAt,
  });

  factory AnomalyAlert.fromJson(Map<String, dynamic> json) {
    return AnomalyAlert(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      title: json['title'] ?? '',
      severity: json['severity'] ?? 'info',
      source: json['source'] ?? '',
      metric: json['metric'] ?? '',
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      thresholdValue: (json['threshold_value'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'severity': severity,
      'source': source,
      'metric': metric,
      'current_value': currentValue,
      'threshold_value': thresholdValue,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
