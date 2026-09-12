import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/core/network/realtime_sync_service.dart';

void main() {
  group('RealtimeSyncState', () {
    test('default state initialized as disconnected', () {
      const state = RealtimeSyncState(
        status: SyncConnectionState.disconnected,
        lastSyncedAt: null,
      );

      expect(state.status, equals(SyncConnectionState.disconnected));
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith properly updates status, timestamp, and errors', () {
      const initial = RealtimeSyncState(
        status: SyncConnectionState.connecting,
        lastSyncedAt: null,
      );

      final now = DateTime.now();
      final updated = initial.copyWith(
        status: SyncConnectionState.connected,
        lastSyncedAt: now,
      );

      expect(updated.status, equals(SyncConnectionState.connected));
      expect(updated.lastSyncedAt, equals(now));
      expect(updated.errorMessage, isNull);

      final errored = updated.copyWith(
        status: SyncConnectionState.error,
        errorMessage: 'Connection timeout',
      );

      expect(errored.status, equals(SyncConnectionState.error));
      expect(errored.errorMessage, equals('Connection timeout'));
    });
  });
}
