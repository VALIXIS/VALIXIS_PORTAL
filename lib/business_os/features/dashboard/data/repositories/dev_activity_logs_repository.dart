import 'dart:async';
import '../../domain/entities/activity_log_item.dart';
import '../../domain/repositories/activity_logs_repository.dart';

/// In-memory development repository for audit activity logs.
class DevActivityLogsRepository implements ActivityLogsRepository {
  final List<ActivityLogItem> _logs = [];
  final StreamController<ActivityLogItem> _streamController =
      StreamController<ActivityLogItem>.broadcast();
  final bool simulateDelay;

  DevActivityLogsRepository({this.simulateDelay = true}) {
    _seedInitialLogs();
  }

  void _seedInitialLogs() {
    final now = DateTime.now();
    _logs.addAll([
      ActivityLogItem(
        id: 'act_dev_001',
        organizationId: 'org_dev_001',
        userId: 'usr_dev_001',
        action: 'payment_recorded',
        entityType: 'payment',
        entityId: 'pay_dev_001',
        metadata: {
          'invoice_number': 'INV-${now.year}-0001',
          'amount': r'$21,830.00',
          'customer_name': 'Acme Cloud Technologies',
        },
        createdAt: now.subtract(const Duration(minutes: 14)),
      ),
      ActivityLogItem(
        id: 'act_dev_002',
        organizationId: 'org_dev_001',
        userId: 'usr_dev_001',
        action: 'lead_stage_updated',
        entityType: 'lead',
        entityId: 'lead_dev_002',
        metadata: const {
          'name': 'Horizon Healthcare Systems',
          'stage': 'Qualified',
        },
        createdAt: now.subtract(const Duration(hours: 1, minutes: 5)),
      ),
      ActivityLogItem(
        id: 'act_dev_003',
        organizationId: 'org_dev_001',
        userId: 'usr_dev_002',
        action: 'task_completed',
        entityType: 'task',
        entityId: 'tsk_dev_001',
        metadata: const {
          'title': 'Q3 Financial Audit Consolidation',
          'task_title': 'Q3 Financial Audit Consolidation',
        },
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ActivityLogItem(
        id: 'act_dev_004',
        organizationId: 'org_dev_001',
        userId: 'usr_dev_001',
        action: 'invoice_created',
        entityType: 'invoice',
        entityId: 'inv_dev_002',
        metadata: {
          'invoice_number': 'INV-${now.year}-0002',
          'amount': r'$14,336.00',
          'customer_name': 'Nexus Dynamics',
        },
        createdAt: now.subtract(const Duration(hours: 5, minutes: 20)),
      ),
      ActivityLogItem(
        id: 'act_dev_005',
        organizationId: 'org_dev_001',
        userId: 'usr_dev_001',
        action: 'lead_created',
        entityType: 'lead',
        entityId: 'lead_dev_005',
        metadata: const {
          'name': 'Starlight AI Research Lab',
          'stage': 'New',
        },
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

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
