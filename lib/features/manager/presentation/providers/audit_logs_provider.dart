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
    final timestampUtc = DateTime.tryParse(timestampStr)?.toUtc() ?? DateTime.now().toUtc();

    final lastSeenStr = item['last_seen'] as String?;
    DateTime? lastSeenUtc;
    if (lastSeenStr != null && lastSeenStr.isNotEmpty) {
      lastSeenUtc = DateTime.tryParse(lastSeenStr)?.toUtc();
    }

    String details = 'Duration: Less than 1m';

    if (lastSeenUtc != null) {
      var diffSeconds = lastSeenUtc.difference(timestampUtc).inSeconds;

      if (diffSeconds < 0) {
        diffSeconds = 0;
      }

      final totalMinutes = diffSeconds ~/ 60;
      final hours = totalMinutes ~/ 60;
      final remMinutes = totalMinutes % 60;

      if (totalMinutes < 1) {
        details = 'Duration: Less than 1m';
      } else if (hours < 1) {
        details = 'Duration: ${totalMinutes}m';
      } else {
        details = 'Duration: ${hours}h ${remMinutes}m';
      }
    }

    return AuditLogItem(
      id: item['id']?.toString() ?? '',
      actor: item['actor']?.toString() ?? 'Unknown User',
      action: item['action']?.toString() ?? '',
      category: item['category']?.toString() ?? 'Authentication',
      timestamp: timestampUtc.toLocal(),
      lastSeen: lastSeenUtc?.toLocal(),
      ipAddress: item['ip_address']?.toString() ?? 'N/A',
      status: item['status']?.toString() ?? 'Success',
      details: details,
    );
  }).toList();
});
