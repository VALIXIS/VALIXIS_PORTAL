import 'dart:async';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Development/Mock implementation of NotificationsRepository.
class DevNotificationsRepository implements NotificationsRepository {
  final List<NotificationItem> _items = [];
  final StreamController<NotificationItem> _realtimeController =
      StreamController<NotificationItem>.broadcast();

  DevNotificationsRepository();

  @override
  Future<List<NotificationItem>> getNotifications(
    String organizationId,
    String userId, {
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final filtered = _items
        .where(
          (item) =>
              item.organizationId == organizationId && item.userId == userId,
        )
        .toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(limit).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _items.indexWhere((item) => item.id == notificationId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead(String organizationId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].organizationId == organizationId &&
          _items[i].userId == userId) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    }
  }

  @override
  Stream<NotificationItem> subscribeToNotifications(
    String organizationId,
    String userId,
  ) {
    return _realtimeController.stream.where(
      (item) => item.organizationId == organizationId && item.userId == userId,
    );
  }

  /// Helper for testing or dev simulation of incoming realtime notification
  void emitRealtimeNotification(NotificationItem item) {
    _items.insert(0, item);
    if (!_realtimeController.isClosed) {
      _realtimeController.add(item);
    }
  }

  @override
  void dispose() {
    _realtimeController.close();
  }
}
