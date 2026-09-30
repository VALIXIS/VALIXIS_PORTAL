import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Supabase implementation of NotificationsRepository.
class SupabaseNotificationsRepository implements NotificationsRepository {
  final SupabaseClient _client;
  RealtimeChannel? _activeChannel;
  StreamController<NotificationItem>? _realtimeController;

  SupabaseNotificationsRepository(this._client);

  @override
  Future<List<NotificationItem>> getNotifications(
    String organizationId,
    String userId, {
    int limit = 50,
  }) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('organization_id', organizationId)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List).cast<Map<String, dynamic>>();
      return list.map((json) => NotificationItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications from Supabase: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      // Primary: attempt RPC mark_notification_as_read
      await _client.rpc(
        'mark_notification_as_read',
        params: {'p_notification_id': notificationId},
      );
    } catch (e) {
      debugPrint('RPC mark_notification_as_read failed, falling back to direct update: $e');
      try {
        await _client
            .from('notifications')
            .update({'is_read': true, 'read': true})
            .eq('id', notificationId);
      } catch (inner) {
        debugPrint('Error updating notification read state in Supabase: $inner');
        rethrow;
      }
    }
  }

  @override
  Future<void> markAllAsRead(String organizationId, String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true, 'read': true})
          .eq('organization_id', organizationId)
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all notifications read in Supabase: $e');
      rethrow;
    }
  }

  @override
  Stream<NotificationItem> subscribeToNotifications(
    String organizationId,
    String userId,
  ) {
    _cleanupChannel();

    final controller = StreamController<NotificationItem>.broadcast();
    _realtimeController = controller;

    try {
      final channelName = 'notifications_${organizationId}_$userId';
      final channel = _client.channel(channelName);
      _activeChannel = channel;

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              try {
                final record = payload.newRecord;
                if (record.isNotEmpty) {
                  final item = NotificationItem.fromJson(record);
                  if (item.organizationId == organizationId &&
                      !controller.isClosed) {
                    controller.add(item);
                  }
                }
              } catch (err) {
                debugPrint('Error parsing realtime notification payload: $err');
              }
            },
          )
          .subscribe();

      controller.onCancel = () {
        _cleanupChannel();
      };
    } catch (e) {
      debugPrint('Error establishing Supabase Realtime channel: $e');
    }

    return controller.stream;
  }

  void _cleanupChannel() {
    if (_activeChannel != null) {
      try {
        _client.removeChannel(_activeChannel!);
      } catch (e) {
        debugPrint('Error removing Supabase realtime channel: $e');
      }
      _activeChannel = null;
    }
    if (_realtimeController != null && !_realtimeController!.isClosed) {
      _realtimeController!.close();
      _realtimeController = null;
    }
  }

  @override
  void dispose() {
    _cleanupChannel();
  }
}
