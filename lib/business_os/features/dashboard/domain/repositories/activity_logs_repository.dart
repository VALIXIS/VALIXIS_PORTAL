import '../entities/activity_log_item.dart';

/// Contract for fetching and subscribing to audit activity logs from public.activity_logs.
abstract class ActivityLogsRepository {
  /// Fetches the recent activity logs for an organization.
  Future<List<ActivityLogItem>> getActivityLogs(
    String organizationId, {
    int limit = 20,
  });

  /// Subscribes to real-time additions to activity logs for an organization.
  Stream<ActivityLogItem> subscribeToActivityLogs(String organizationId);

  /// Records an activity log entry.
  Future<void> logActivity(ActivityLogItem item);
}
