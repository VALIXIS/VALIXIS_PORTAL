import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../widgets/audit_logs_table.dart';

final auditLogsProvider = FutureProvider<List<AuditLogItem>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('audit_logs')
      .select('*')
      .order('timestamp', ascending: false);

  final list = response as List<dynamic>;
  return list.map((item) {
    final timestampStr = item['timestamp'] as String? ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    final lastSeenStr = item['last_seen'] as String?;
    String? details;
    if (lastSeenStr != null) {
      final lastSeen = DateTime.tryParse(lastSeenStr);
      if (lastSeen != null) {
        final diff = lastSeen.difference(timestamp);
        final minutes = diff.inMinutes;
        final hours = diff.inHours;
        final durationText = hours > 0
            ? '${hours}h ${minutes % 60}m'
            : '${minutes}m';
        details = 'Approx. Duration: $durationText';
      }
    }

    return AuditLogItem(
      id: item['id']?.toString() ?? '',
      actor: item['actor']?.toString() ?? 'Unknown User',
      action: item['action']?.toString() ?? '',
      category: item['category']?.toString() ?? 'Authentication',
      timestamp: timestamp,
      ipAddress: item['ip_address']?.toString() ?? 'N/A',
      status: item['status']?.toString() ?? 'Success',
      details: details,
    );
  }).toList();
});
