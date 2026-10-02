import 'dart:math';

/// High-throughput Forensic Metric Record for multi-dimensional pivot slicing
class ForensicRecord {
  final String id;
  final DateTime timestamp;
  final String channel; // e.g. 'Outbound', 'Paid Ads', 'Organic', 'Direct', 'Referral'
  final String owner; // e.g. 'Alex Mercer', 'Sarah Chen', 'David Miller', 'Elena Rostova'
  final String status; // e.g. 'Closed Won', 'In Negotiation', 'Discovery', 'Closed Lost'
  final String region; // e.g. 'North America', 'EMEA', 'APAC', 'LATAM'
  final double arrValue;
  final int conversionDays;

  ForensicRecord({
    required this.id,
    required this.timestamp,
    required this.channel,
    required this.owner,
    required this.status,
    required this.region,
    required this.arrValue,
    required this.conversionDays,
  });

  /// High-performance synthetic dataset generator for benchmarking 5,000+ records
  static List<ForensicRecord> generateDataset(int count) {
    final rand = Random(42); // Deterministic seed for reproducible benchmarks
    final channels = ['Outbound', 'Paid Ads', 'Organic', 'Direct', 'Referral'];
    final owners = ['Alex Mercer', 'Sarah Chen', 'David Miller', 'Elena Rostova'];
    final statuses = ['Closed Won', 'In Negotiation', 'Discovery', 'Closed Lost'];
    final regions = ['North America', 'EMEA', 'APAC', 'LATAM'];

    final now = DateTime.now();

    return List.generate(count, (i) {
      final daysAgo = rand.nextInt(30);
      final channel = channels[rand.nextInt(channels.length)];
      final owner = owners[rand.nextInt(owners.length)];
      final status = statuses[rand.nextInt(statuses.length)];
      final region = regions[rand.nextInt(regions.length)];
      final arr = (rand.nextDouble() * 250000 + 10000).roundToDouble();
      final convDays = rand.nextInt(90) + 5;

      return ForensicRecord(
        id: 'rec_${(i + 1000).toString()}',
        timestamp: now.subtract(Duration(days: daysAgo, hours: rand.nextInt(24))),
        channel: channel,
        owner: owner,
        status: status,
        region: region,
        arrValue: arr,
        conversionDays: convDays,
      );
    });
  }

  /// Date string helper formatted as YYYY-MM
  String get dateGroupKey {
    final month = timestamp.month.toString().padLeft(2, '0');
    return '${timestamp.year}-$month';
  }
}
