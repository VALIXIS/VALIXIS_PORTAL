import 'telemetry_event.dart';

class DashboardCachePayload {
  final List<MetricSnapshot> snapshots;
  final Map<String, dynamic> arrPrediction;
  final Map<String, dynamic> churnRadar;
  final List<AnomalyAlert> anomalies;
  final DateTime cachedAt;

  const DashboardCachePayload({
    required this.snapshots,
    required this.arrPrediction,
    required this.churnRadar,
    required this.anomalies,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
        'snapshots': snapshots.map((s) => s.toJson()).toList(),
        'arr_prediction': arrPrediction,
        'churn_radar': churnRadar,
        'anomalies': anomalies.map((a) => a.toJson()).toList(),
        'cached_at': cachedAt.toIso8601String(),
      };

  factory DashboardCachePayload.fromJson(Map<String, dynamic> json) {
    final rawSnapshots = (json['snapshots'] as List<dynamic>?) ?? [];
    final rawAnomalies = (json['anomalies'] as List<dynamic>?) ?? [];

    return DashboardCachePayload(
      snapshots: rawSnapshots
          .map((s) => MetricSnapshot.fromJson(s as Map<String, dynamic>))
          .toList(),
      arrPrediction: (json['arr_prediction'] as Map<String, dynamic>?) ?? {},
      churnRadar: (json['churn_radar'] as Map<String, dynamic>?) ?? {},
      anomalies: rawAnomalies
          .map((a) => AnomalyAlert.fromJson(a as Map<String, dynamic>))
          .toList(),
      cachedAt: json['cached_at'] != null
          ? DateTime.parse(json['cached_at'] as String)
          : DateTime.now(),
    );
  }
}
