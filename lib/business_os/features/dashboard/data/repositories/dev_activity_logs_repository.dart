import 'dart:async';
import '../../domain/entities/activity_log_item.dart';
import '../../domain/repositories/activity_logs_repository.dart';

/// In-memory development repository for audit activity logs.
class DevActivityLogsRepository implements ActivityLogsRepository {
  final List<ActivityLogItem> _logs = [];
  final StreamController<ActivityLogItem> _streamController =
      StreamController<ActivityLogItem>.broadcast();
  final bool simulateDelay;

  DevActivityLogsRepository({this.simulateDelay = true});

  void addLogSync(ActivityLogItem item) {
    _logs.insert(0, item);
    _streamController.add(item);
  }

  @override
  Future<List<ActivityLogItem>> getActivityLogs(
    String organizationId, {
    int limit = 20,
  }) async {
    if (simulateDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    final filtered = _logs
        .where((log) => log.organizationId == organizationId)
        .toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(limit).toList();
  }

  @override
  Stream<ActivityLogItem> subscribeToActivityLogs(String organizationId) {
    return _streamController.stream.where(
      (log) => log.organizationId == organizationId,
    );
  }

  @override
  Future<void> logActivity(ActivityLogItem item) async {
    if (simulateDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    addLogSync(item);
  }

  void dispose() {
    _streamController.close();
  }
}
