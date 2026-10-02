class DailyVolumeItem {
  final String date;
  final int count;
  final int successCount;

  const DailyVolumeItem({
    required this.date,
    required this.count,
    required this.successCount,
  });

  factory DailyVolumeItem.fromJson(Map<String, dynamic> json) {
    return DailyVolumeItem(
      date: json['date'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      successCount: (json['success_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class FlowAnalytics {
  final int totalRuns;
  final int successfulRuns;
  final int failedRuns;
  final double successRatePercent;
  final double avgOverallLatencyMs;
  final double avgWebhookLatencyMs;
  final double avgAiLatencyMs;
  final double avgActionLatencyMs;
  final List<DailyVolumeItem> dailyVolume;

  const FlowAnalytics({
    required this.totalRuns,
    required this.successfulRuns,
    required this.failedRuns,
    required this.successRatePercent,
    required this.avgOverallLatencyMs,
    required this.avgWebhookLatencyMs,
    required this.avgAiLatencyMs,
    required this.avgActionLatencyMs,
    required this.dailyVolume,
  });

  factory FlowAnalytics.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['daily_volume'] as List<dynamic>?)
            ?.map((e) => DailyVolumeItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return FlowAnalytics(
      totalRuns: (json['total_runs'] as num?)?.toInt() ?? 0,
      successfulRuns: (json['successful_runs'] as num?)?.toInt() ?? 0,
      failedRuns: (json['failed_runs'] as num?)?.toInt() ?? 0,
      successRatePercent: (json['success_rate_percent'] as num?)?.toDouble() ?? 100.0,
      avgOverallLatencyMs: (json['avg_overall_latency_ms'] as num?)?.toDouble() ?? 0.0,
      avgWebhookLatencyMs: (json['avg_webhook_latency_ms'] as num?)?.toDouble() ?? 0.0,
      avgAiLatencyMs: (json['avg_ai_latency_ms'] as num?)?.toDouble() ?? 0.0,
      avgActionLatencyMs: (json['avg_action_latency_ms'] as num?)?.toDouble() ?? 0.0,
      dailyVolume: dailyList,
    );
  }

    static FlowAnalytics empty() {
    return const FlowAnalytics(
      totalRuns: 0,
      successfulRuns: 0,
      failedRuns: 0,
      successRatePercent: 100.0,
      avgOverallLatencyMs: 0.0,
      avgWebhookLatencyMs: 0.0,
      avgAiLatencyMs: 0.0,
      avgActionLatencyMs: 0.0,
      dailyVolume: [],
    );
  }

  static FlowAnalytics mock() => empty();
}
