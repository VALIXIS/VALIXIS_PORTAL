import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/activity_log_item.dart';
import '../../domain/repositories/activity_logs_repository.dart';

/// Supabase implementation of ActivityLogsRepository consuming public.activity_logs.
class SupabaseActivityLogsRepository implements ActivityLogsRepository {
  final SupabaseClient _client;

  SupabaseActivityLogsRepository(this._client);

  @override
  Future<List<ActivityLogItem>> getActivityLogs(
    String organizationId, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('activity_logs')
          .select()
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List).cast<Map<String, dynamic>>();
      return list.map((json) => ActivityLogItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching activity logs from Supabase: $e');
      rethrow;
    }
  }

  @override
  Stream<ActivityLogItem> subscribeToActivityLogs(String organizationId) {
    final controller = StreamController<ActivityLogItem>.broadcast();

    try {
      final channel = _client.channel('activity_logs_feed_$organizationId');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'activity_logs',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'organization_id',
              value: organizationId,
            ),
            callback: (payload) {
              try {
                final item = ActivityLogItem.fromJson(payload.newRecord);
                if (!controller.isClosed) {
                  controller.add(item);
                }
              } catch (e) {
                debugPrint('Error parsing realtime activity log payload: $e');
              }
            },
          )
          .subscribe();

      controller.onCancel = () {
        _client.removeChannel(channel);
      };
    } catch (e) {
      debugPrint('Error setting up Supabase Realtime channel for activity logs: $e');
    }

    return controller.stream;
  }

  @override
  Future<void> logActivity(ActivityLogItem item) async {
    try {
      await _client.from('activity_logs').insert(item.toJson());
    } catch (e) {
      debugPrint('Error inserting activity log: $e');
      rethrow;
    }
  }
}
