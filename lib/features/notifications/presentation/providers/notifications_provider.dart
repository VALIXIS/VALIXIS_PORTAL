import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/app_notification.dart';

class NotificationsState {
  const NotificationsState({
    required this.notifications,
    this.isLoading = false,
  });

  final List<AppNotification> notifications;
  final bool isLoading;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier()
      : super(NotificationsState(
          notifications: _initialNotifications,
        ));

  static final _initialNotifications = [
    AppNotification(
      id: 'notif-1',
      title: 'New Task Assigned',
      message: 'You have been assigned to "Implement Auth Flow & JWT State".',
      category: NotificationCategory.taskAssigned,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Pull Request Approved',
      message: 'PR #104 "Refactor Manager Dashboard" was approved by Lead.',
      category: NotificationCategory.prApproved,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'notif-3',
      title: 'PR Submission Received',
      message: 'Employee Alex submitted PR for "Database Migration Setup".',
      category: NotificationCategory.prSubmitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    AppNotification(
      id: 'notif-4',
      title: 'PR Revision Requested',
      message: 'PR #98 "Profile UI" needs code cleanup & unit test coverage.',
      category: NotificationCategory.prRejected,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AppNotification(
      id: 'notif-5',
      title: 'System Announcement',
      message: 'VALIXIS Portal v2.5 update deployed with enhanced security.',
      category: NotificationCategory.announcement,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  void markAsRead(String id) {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});
