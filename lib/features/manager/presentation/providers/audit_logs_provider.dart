import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../widgets/audit_logs_table.dart';

final auditLogsProvider = FutureProvider<List<AuditLogItem>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  
  final results = await Future.wait([
    supabase
        .from('audit_logs')
        .select('*')
        .order('timestamp', ascending: false),
    supabase
        .from('employees')
        .select('id, auth_id, name, full_name, email')
        .catchError((_) => []),
  ]);

  final list = results[0] as List<dynamic>;
  final employeesList = (results[1] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

  final empMap = <String, String>{};
  for (final emp in employeesList) {
    final id = emp['id']?.toString().trim();
    final authId = emp['auth_id']?.toString().trim();
    final name = (emp['name'] as String? ?? emp['full_name'] as String? ?? '').trim();
    final email = (emp['email'] as String? ?? '').trim();
    final displayName = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'Employee');
    if (id != null && id.isNotEmpty) empMap[id] = displayName;
    if (authId != null && authId.isNotEmpty) empMap[authId] = displayName;
  }

  final nowUtc = DateTime.now().toUtc();

  return list.map((item) {
    final timestampStr = item['timestamp'] as String? ?? '';
    final timestampUtc = DateTime.tryParse(timestampStr)?.toUtc() ?? nowUtc;

    final lastSeenStr = item['last_seen'] as String?;
    DateTime? lastSeenUtc;
    if (lastSeenStr != null && lastSeenStr.isNotEmpty) {
      lastSeenUtc = DateTime.tryParse(lastSeenStr)?.toUtc();
    }

    String details = 'Duration: Less than 1m';

    if (lastSeenUtc != null) {
      var diffSeconds = lastSeenUtc.difference(timestampUtc).inSeconds;
      if (diffSeconds < 0) diffSeconds = 0;

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

    final rawAction = item['action']?.toString() ?? 'Login';
    String status = item['status']?.toString() ?? 'Success';

    if (rawAction.toLowerCase() == 'login') {
      if (lastSeenUtc != null) {
        final secondsSinceLastSeen = nowUtc.difference(lastSeenUtc).inSeconds;
        if (secondsSinceLastSeen > 180) {
          status = 'Session Ended';
        } else {
          status = 'Active Session';
        }
      } else {
        status = 'Active Session';
      }
    } else if (rawAction.toLowerCase() == 'logout') {
      status = 'Logged Out';
    }

    var actorName = item['actor']?.toString().trim() ?? '';
    final actorId = item['actor_id']?.toString().trim() ?? '';
    if (actorName.isEmpty || actorName.toLowerCase() == 'unknown user') {
      if (actorId.isNotEmpty && empMap.containsKey(actorId)) {
        actorName = empMap[actorId]!;
      } else {
        actorName = 'User';
      }
    }

    return AuditLogItem(
      id: item['id']?.toString() ?? '',
      actor: actorName,
      action: rawAction,
      category: item['category']?.toString() ?? 'Authentication',
      timestamp: timestampUtc.toLocal(),
      lastSeen: lastSeenUtc?.toLocal(),
      ipAddress: item['ip_address']?.toString() ?? 'Web Client',
      status: status,
      details: details,
    );
  }).toList();
});
