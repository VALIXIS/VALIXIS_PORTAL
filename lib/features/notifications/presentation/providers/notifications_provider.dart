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
      : super(const NotificationsState(
          notifications: [],
        ));

  void addNotification(AppNotification notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }

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
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});
