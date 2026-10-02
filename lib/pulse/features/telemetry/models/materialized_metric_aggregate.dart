/// Model representing an aggregated metric snapshot from Materialized Views (Hourly/Daily)
class MaterializedMetricAggregate {
  final String orgId;
  final String metricName;
  final DateTime bucket;
  final int totalCount;
  final double avgValue;
  final double minValue;
  final double maxValue;
  final double p50Value;
  final double p95Value;
  final double p99Value;

  MaterializedMetricAggregate({
    required this.orgId,
    required this.metricName,
    required this.bucket,
    required this.totalCount,
    required this.avgValue,
    required this.minValue,
    required this.maxValue,
    required this.p50Value,
    required this.p95Value,
    required this.p99Value,
  });

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'metric_name': metricName,
      'bucket': bucket.toIso8601String(),
      'total_count': totalCount,
      'avg_value': avgValue,
      'min_value': minValue,
      'max_value': maxValue,
      'p50_value': p50Value,
      'p95_value': p95Value,
      'p99_value': p99Value,
    };
  }

  factory MaterializedMetricAggregate.fromJson(Map<String, dynamic> json) {
    return MaterializedMetricAggregate(
      orgId: json['org_id'] as String? ?? 'org_valixis_01',
      metricName: json['metric_name'] as String? ?? 'telemetry_metric',
      bucket: json['bucket'] != null ? DateTime.parse(json['bucket'] as String) : DateTime.now(),
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      avgValue: (json['avg_value'] as num?)?.toDouble() ?? 0.0,
      minValue: (json['min_value'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['max_value'] as num?)?.toDouble() ?? 0.0,
      p50Value: (json['p50_value'] as num?)?.toDouble() ?? 0.0,
      p95Value: (json['p95_value'] as num?)?.toDouble() ?? 0.0,
      p99Value: (json['p99_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
