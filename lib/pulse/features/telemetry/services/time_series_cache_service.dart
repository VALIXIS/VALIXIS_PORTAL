import 'dart:math';
import '../models/materialized_metric_aggregate.dart';
import '../models/telemetry_event.dart';

/// High-speed Time-Series Cache & Continuous Materialized Aggregation Service (Sub-20ms Engine)
class TimeSeriesCacheService {
  // L1 In-Memory Cache Lookup Tables: Map<Key, List<MaterializedMetricAggregate>>
  final Map<String, List<MaterializedMetricAggregate>> _hourlyCache = {};
  final Map<String, List<MaterializedMetricAggregate>> _dailyCache = {};

  int _totalRecordsCached = 0;
  int _lastAggregationDurationMs = 0;

  int get totalRecordsCached => _totalRecordsCached;
  int get lastAggregationDurationMs => _lastAggregationDurationMs;

  /// High-performance continuous materialized view engine computation over raw telemetry
  void computeContinuousMaterializedViews(List<TelemetryEvent> events) {
    final stopwatch = Stopwatch()..start();

    _hourlyCache.clear();
    _dailyCache.clear();
    _totalRecordsCached = events.length;

    // 1. Group events by organizationId + metricName + hourly/daily buckets
    final Map<String, List<double>> hourlyBuckets = {};
    final Map<String, List<double>> dailyBuckets = {};

    for (final event in events) {
      final value = (event.payload['value'] as num?)?.toDouble() ?? 0.0;
      final time = event.createdAt;

      final hourKey = '${event.organizationId}::${event.eventType}::${time.year}-${time.month}-${time.day}-${time.hour}';
      final dayKey = '${event.organizationId}::${event.eventType}::${time.year}-${time.month}-${time.day}';

      hourlyBuckets.putIfAbsent(hourKey, () => []).add(value);
      dailyBuckets.putIfAbsent(dayKey, () => []).add(value);
    }

    // 2. Build Hourly Aggregates
    hourlyBuckets.forEach((key, values) {
      final parts = key.split('::');
      final orgId = parts[0];
      final metricName = parts[1];
      final timeStr = parts[2];
      final timeParts = timeStr.split('-');
      final bucketTime = DateTime(
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
        int.parse(timeParts[3]),
      );

      final agg = _buildAggregate(orgId, metricName, bucketTime, values);
      final cacheKey = '${orgId}_$metricName';
      _hourlyCache.putIfAbsent(cacheKey, () => []).add(agg);
    });

    // 3. Build Daily Aggregates
    dailyBuckets.forEach((key, values) {
      final parts = key.split('::');
      final orgId = parts[0];
      final metricName = parts[1];
      final timeStr = parts[2];
      final timeParts = timeStr.split('-');
      final bucketTime = DateTime(
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      final agg = _buildAggregate(orgId, metricName, bucketTime, values);
      final cacheKey = '${orgId}_$metricName';
      _dailyCache.putIfAbsent(cacheKey, () => []).add(agg);
    });

    stopwatch.stop();
    _lastAggregationDurationMs = stopwatch.elapsedMilliseconds;
  }

  /// Fast percentile and summary aggregator helper
  MaterializedMetricAggregate _buildAggregate(
    String orgId,
    String metricName,
    DateTime bucket,
    List<double> values,
  ) {
    values.sort();
    final count = values.length;
    final sum = values.fold<double>(0.0, (acc, v) => acc + v);
    final avg = sum / count;
    final minVal = values.first;
    final maxVal = values.last;

    double calcPercentile(double p) {
      final index = ((count - 1) * p).round();
      return values[index.clamp(0, count - 1)];
    }

    return MaterializedMetricAggregate(
      orgId: orgId,
      metricName: metricName,
      bucket: bucket,
      totalCount: count,
      avgValue: avg,
      minValue: minVal,
      maxValue: maxVal,
      p50Value: calcPercentile(0.50),
      p95Value: calcPercentile(0.95),
      p99Value: calcPercentile(0.99),
    );
  }

  /// Sub-20ms high-speed query execution from L1 hourly materialized cache
  List<MaterializedMetricAggregate> queryHourlyAggregates(String orgId, String metricName) {
    final cacheKey = '${orgId}_$metricName';
    return _hourlyCache[cacheKey] ?? [];
  }

  /// Sub-20ms high-speed query execution from L1 daily materialized cache
  List<MaterializedMetricAggregate> queryDailyAggregates(String orgId, String metricName) {
    final cacheKey = '${orgId}_$metricName';
    return _dailyCache[cacheKey] ?? [];
  }

  /// High-throughput synthetic telemetry generator for 100,000 records
  static List<TelemetryEvent> generate100kDataset() {
    final rand = Random(42);
    final metrics = ['arr_growth', 'system_latency_p95', 'lead_conversion', 'churn_risk'];
    final now = DateTime.now();

    return List.generate(100000, (i) {
      final daysAgo = rand.nextInt(30);
      final metric = metrics[rand.nextInt(metrics.length)];
      final value = (rand.nextDouble() * 500 + 10).roundToDouble();

      return TelemetryEvent(
        id: 'evt_${i + 1}',
        organizationId: 'org_valixis_01',
        sourceSystem: 'pulse',
        eventType: metric,
        createdAt: now.subtract(Duration(days: daysAgo, hours: rand.nextInt(24))),
        payload: {'value': value},
      );
    });
  }
}
