/// Export Dataset representation for multi-format exports (CSV, Excel, SVG, PDF)
class ExportDataset {
  final String title;
  final String description;
  final String orgId;
  final DateTime generatedAt;
  final List<String> headers;
  final List<List<dynamic>> rows;
  final Map<String, dynamic> summaryStats;

  ExportDataset({
    required this.title,
    required this.description,
    required this.orgId,
    required this.generatedAt,
    required this.headers,
    required this.rows,
    required this.summaryStats,
  });

  factory ExportDataset.sample() {
    return ExportDataset(
      title: 'VALIXIS Pulse Executive Performance Audit',
      description: 'Historical telemetry, ARR trajectory & operational SLA breakdown.',
      orgId: 'org_valixis_01',
      generatedAt: DateTime.now(),
      headers: ['Timestamp', 'Metric Type', 'Observed Value', 'Target SLA', 'Status'],
      rows: [
        ['2026-10-15 08:00', 'ARR Velocity', '\$1,480,000', '\$1.50M Target', 'OPTIMAL'],
        ['2026-10-15 09:00', 'Gateway Latency (p95)', '18.4 ms', '< 50.0 ms', 'PASSING'],
        ['2026-10-15 10:00', 'CRM Conversion Rate', '28.4%', '25.0% Baseline', 'OPTIMAL'],
        ['2026-10-15 11:00', 'Customer Churn Risk', '14.2%', '< 20.0%', 'PASSING'],
        ['2026-10-15 12:00', 'Self-Healing SLA', '100.0%', '100.0%', 'VERIFIED'],
      ],
      summaryStats: {
        'Total ARR': '\$1.48M',
        'Avg Latency': '18.4ms',
        'Lead Conversion': '28.4%',
        'SLA Verification': '100% Passed',
      },
    );
  }
}
