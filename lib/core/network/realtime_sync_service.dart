import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/manager/presentation/providers/audit_logs_provider.dart';
import '../../features/manager/presentation/providers/employee_management_provider.dart';
import '../../features/manager/presentation/providers/manager_dashboard_provider.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';
import 'supabase_client_provider.dart';

/// Connection and synchronization state of the Supabase Realtime channel.
enum SyncConnectionState {
  connecting,
  connected,
  disconnected,
  error,
}

/// State data class holding live sync information.
class RealtimeSyncState {
  const RealtimeSyncState({
    required this.status,
    required this.lastSyncedAt,
    this.errorMessage,
  });

  final SyncConnectionState status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  RealtimeSyncState copyWith({
    SyncConnectionState? status,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return RealtimeSyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Service managing real-time postgres changes across VALIXIS tables.
class RealtimeSyncService extends StateNotifier<RealtimeSyncState> {
  RealtimeSyncService(this._ref, this._client)
      : super(const RealtimeSyncState(
          status: SyncConnectionState.disconnected,
          lastSyncedAt: null,
        )) {
    _initSubscription();
  }

  final Ref _ref;
  final SupabaseClient _client;
  RealtimeChannel? _channel;
  Timer? _debounceTimer;

  void _initSubscription() {
    try {
      state = state.copyWith(status: SyncConnectionState.connecting);

      final channel = _client.channel('public:valixis_manager_realtime');

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'tasks',
            callback: (payload) => _handleTableChange('tasks', payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'task_assignments',
            callback: (payload) => _handleTableChange('task_assignments', payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'submissions',
            callback: (payload) => _handleTableChange('submissions', payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'audit_logs',
            callback: (payload) => _handleTableChange('audit_logs', payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'employees',
            callback: (payload) => _handleTableChange('employees', payload),
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              state = RealtimeSyncState(
                status: SyncConnectionState.connected,
                lastSyncedAt: DateTime.now(),
              );
              debugPrint('[RealtimeSync] Subscribed to VALIXIS real-time channels successfully.');
            } else if (status == RealtimeSubscribeStatus.closed ||
                status == RealtimeSubscribeStatus.timedOut) {
              state = state.copyWith(
                status: SyncConnectionState.disconnected,
                errorMessage: error?.toString(),
              );
              debugPrint('[RealtimeSync] Realtime channel closed/timed out: $error');
            }
          });

      _channel = channel;
    } catch (e) {
      debugPrint('[RealtimeSync] Failed to initialize subscription: $e');
      state = state.copyWith(
        status: SyncConnectionState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _handleTableChange(String table, PostgresChangePayload payload) {
    debugPrint('[RealtimeSync] Received change on $table: ${payload.eventType}');
    state = state.copyWith(
      status: SyncConnectionState.connected,
      lastSyncedAt: DateTime.now(),
    );

    // Debounce provider invalidations to prevent rapid UI thrashing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _ref.invalidate(managerDashboardProvider);
      _ref.invalidate(auditLogsProvider);
      _ref.invalidate(tasksProvider);
      _ref.invalidate(employeeManagementProvider);
    });
  }

  /// Manually force a sync and refresh all providers.
  void forceRefresh() {
    state = state.copyWith(
      status: SyncConnectionState.connected,
      lastSyncedAt: DateTime.now(),
    );
    _ref.invalidate(managerDashboardProvider);
    _ref.invalidate(auditLogsProvider);
    _ref.invalidate(tasksProvider);
    _ref.invalidate(employeeManagementProvider);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_channel != null) {
      _client.removeChannel(_channel!);
      _channel = null;
    }
    super.dispose();
  }
}

/// Global provider for the [RealtimeSyncService].
final realtimeSyncProvider =
    StateNotifierProvider<RealtimeSyncService, RealtimeSyncState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RealtimeSyncService(ref, client);
});
