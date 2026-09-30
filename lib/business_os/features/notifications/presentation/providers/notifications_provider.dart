// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/dev_notifications_repository.dart';
import '../../data/repositories/supabase_notifications_repository.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';

enum NotificationsStatus { loading, loaded, error }

/// Immutable state for the Notification Center & Realtime Listener.
@immutable
class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationItem> notifications;
  final int unreadCount;
  final String? errorMessage;
  final bool isDrawerOpen;
  final NotificationItem? latestRealtimeItem;

  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
    this.isDrawerOpen = false,
    this.latestRealtimeItem,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationItem>? notifications,
    int? unreadCount,
    String? errorMessage,
    bool? isDrawerOpen,
    NotificationItem? latestRealtimeItem,
    bool clearLatestRealtime = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      latestRealtimeItem: clearLatestRealtime
          ? null
          : (latestRealtimeItem ?? this.latestRealtimeItem),
    );
  }
}

/// Provider exposing the active NotificationsRepository.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      final repo = DevNotificationsRepository();
      ref.onDispose(() => repo.dispose());
      return repo;
    }
    final repo = SupabaseNotificationsRepository(client);
    ref.onDispose(() => repo.dispose());
    return repo;
  } catch (e) {
    debugPrint('Supabase client unavailable for notifications, using DevNotificationsRepository: $e');
    final repo = DevNotificationsRepository();
    ref.onDispose(() => repo.dispose());
    return repo;
  }
});

/// Riverpod StateNotifier managing Notification state and Realtime Subscriptions.
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;
  final String? _organizationId;
  final String? _userId;
  final Set<String> _seenIds = {};
  StreamSubscription<NotificationItem>? _subscription;

  NotificationsNotifier({
    required NotificationsRepository repository,
    required String? organizationId,
    required String? userId,
  })  : _repository = repository,
        _organizationId = organizationId,
        _userId = userId,
        super(const NotificationsState()) {
    if (_organizationId != null && _userId != null) {
      _init();
    } else {
      state = state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: [],
        unreadCount: 0,
      );
    }
  }

  Future<void> _init() async {
    await loadNotifications();
    _subscribeToRealtime();
  }

  /// Load recent notifications from the repository and merge safely with realtime state.
  Future<void> loadNotifications() async {
    final orgId = _organizationId;
    final usrId = _userId;
    if (orgId == null || usrId == null) return;

    try {
      state = state.copyWith(status: NotificationsStatus.loading, errorMessage: null);

      final fetched = await _repository.getNotifications(
        orgId,
        usrId,
        limit: 50,
      );

      // Deduplicate authoritative IDs
      final List<NotificationItem> merged = [];
      for (final item in fetched) {
        if (!_seenIds.contains(item.id)) {
          _seenIds.add(item.id);
          merged.add(item);
        }
      }

      // Preserve any new realtime items that arrived during initial load query
      for (final existing in state.notifications) {
        if (!merged.any((m) => m.id == existing.id)) {
          merged.add(existing);
        }
      }

      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final unread = merged.where((n) => !n.isRead).length;

      state = state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: merged,
        unreadCount: unread,
      );
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: 'Failed to load notifications. Please try again.',
      );
    }
  }

  /// Establish realtime subscription for incoming INSERT events.
  void _subscribeToRealtime() {
    final orgId = _organizationId;
    final usrId = _userId;
    if (orgId == null || usrId == null) return;

    _subscription?.cancel();
    _subscription = _repository
        .subscribeToNotifications(orgId, usrId)
        .listen(
      (item) {
        // Strict deduplication using authoritative notification ID
        if (_seenIds.contains(item.id)) return;
        _seenIds.add(item.id);

        final wasLoaded = state.status == NotificationsStatus.loaded;
        final updatedList = [item, ...state.notifications];
        final newUnread = state.unreadCount + (item.isRead ? 0 : 1);

        state = state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: updatedList,
          unreadCount: newUnread,
          latestRealtimeItem: wasLoaded ? item : null,
        );
      },
      onError: (err) {
        debugPrint('Realtime notification listener error: $err');
      },
    );
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    final index = state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final target = state.notifications[index];
    if (target.isRead) return; // Already read

    // Optimistic UI update
    final updatedList = List<NotificationItem>.from(state.notifications);
    updatedList[index] = target.copyWith(isRead: true);
    final newUnread = (state.unreadCount - 1).clamp(0, 9999);

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: newUnread,
    );

    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Failed to mark notification $notificationId read: $e');
      // Revert if error
      final revertedList = List<NotificationItem>.from(state.notifications);
      revertedList[index] = target;
      state = state.copyWith(
        notifications: revertedList,
        unreadCount: state.unreadCount + 1,
      );
    }
  }

  /// Mark all notifications as read for current user/org.
  Future<void> markAllAsRead() async {
    final orgId = _organizationId;
    final usrId = _userId;
    if (orgId == null || usrId == null) return;
    if (state.unreadCount == 0) return;

    final originalList = List<NotificationItem>.from(state.notifications);
    final updatedList = state.notifications.map((n) => n.copyWith(isRead: true)).toList();

    // Optimistic UI update
    state = state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
    );

    try {
      await _repository.markAllAsRead(orgId, usrId);
    } catch (e) {
      debugPrint('Failed to mark all notifications read: $e');
      // Revert optimistic update
      state = state.copyWith(
        notifications: originalList,
        unreadCount: originalList.where((n) => !n.isRead).length,
      );
    }
  }

  /// Clear transient latest realtime item after toast has been displayed.
  void clearLatestRealtimeItem() {
    if (state.latestRealtimeItem != null) {
      state = state.copyWith(clearLatestRealtime: true);
    }
  }

  /// Toggle or set drawer state.
  void toggleDrawer() {
    state = state.copyWith(isDrawerOpen: !state.isDrawerOpen);
  }

  void openDrawer() {
    state = state.copyWith(isDrawerOpen: true);
  }

  void closeDrawer() {
    state = state.copyWith(isDrawerOpen: false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _seenIds.clear();
    super.dispose();
  }
}

/// Primary Riverpod StateNotifierProvider for Notifications.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final user = ref.watch(currentUserProvider);
  final org = ref.watch(currentOrganizationProvider);
  final repo = ref.watch(notificationsRepositoryProvider);

  return NotificationsNotifier(
    repository: repo,
    organizationId: org?.id,
    userId: user?.id,
  );
});

/// Selectors for fine-grained rebuild performance.
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider.select((s) => s.unreadCount));
});

final isNotificationDrawerOpenProvider = Provider<bool>((ref) {
  return ref.watch(notificationsProvider.select((s) => s.isDrawerOpen));
});
