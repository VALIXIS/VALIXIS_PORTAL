import '../entities/notification_item.dart';

/// Abstract contract for fetching, marking, and subscribing to notifications.
abstract class NotificationsRepository {
  /// Fetch recent notifications for an authenticated user and organization.
  Future<List<NotificationItem>> getNotifications(
    String organizationId,
    String userId, {
    int limit = 50,
  });

  /// Mark a single notification as read by its unique ID.
  Future<void> markAsRead(String notificationId);

  /// Mark all unread notifications as read for the user in the organization.
  Future<void> markAllAsRead(String organizationId, String userId);

  /// Realtime stream listener for incoming notification INSERT events.
  Stream<NotificationItem> subscribeToNotifications(
    String organizationId,
    String userId,
  );

  /// Cleanup resources or cancel active subscriptions.
  void dispose();
}
