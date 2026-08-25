import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/session_storage.dart';
import 'auth_provider.dart';

final heartbeatProvider = Provider<HeartbeatController>((ref) {
  final controller = HeartbeatController(ref.watch(supabaseClientProvider));

  ref.listen<AsyncValue<User?>>(authNotifierProvider, (previous, next) {
    final user = next.valueOrNull;
    if (user != null) {
      controller.initializeFromSession(user.id);
    } else {
      controller.stop();
    }
  });

  return controller;
});

class HeartbeatController {
  HeartbeatController(this._client);

  final SupabaseClient _client;
  Timer? _timer;
  String? _activeLogId;

  /// Initializes the heartbeat timer if an active audit log ID exists in browser session storage.
  /// If no active ID exists in session storage, creates a session audit record.
  Future<void> initializeFromSession([String? userId]) async {
    if (_timer != null) return;

    final storedId = getSessionItem('active_audit_log_id');
    if (storedId != null && storedId.isNotEmpty) {
      _activeLogId = storedId;
      _startTimer();
      debugPrint('[Heartbeat] Resumed heartbeat for session log $storedId');
      return;
    }

    if (userId != null && userId.isNotEmpty) {
      try {
        String? empId;
        try {
          final empRes = await _client
              .from('employees')
              .select('id')
              .eq('auth_id', userId)
              .maybeSingle();
          if (empRes != null) {
            empId = empRes['id']?.toString();
          }
        } catch (_) {}

        final res = await _client.from('audit_logs').insert({
          if (empId != null && empId.isNotEmpty) 'actor_id': empId,
          'action': 'Login',
          'category': 'Authentication',
          'status': 'Success',
          'ip_address': kIsWeb ? 'Web Client' : 'Mobile Client',
          'last_seen': DateTime.now().toUtc().toIso8601String(),
        }).select('id').single();

        final logId = res['id']?.toString();
        if (logId != null && logId.isNotEmpty) {
          startNewSession(logId);
        }
      } catch (e) {
        debugPrint('[Heartbeat] Failed to create session audit record on startup: $e');
      }
    }
  }

  /// Explicitly starts a heartbeat for a brand new login log ID created on authentication success.
  void startNewSession(String logId) {
    stop();
    _activeLogId = logId;
    setSessionItem('active_audit_log_id', logId);
    _startTimer();
    _sendHeartbeat();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      _sendHeartbeat();
    });
  }

  Future<void> _sendHeartbeat() async {
    if (_activeLogId == null) return;

    try {
      await _client.from('audit_logs').update({
        'last_seen': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', _activeLogId!);
      debugPrint('[Heartbeat] Updated last_seen for log $_activeLogId');
    } catch (e) {
      debugPrint('[Heartbeat] Failed to update heartbeat: $e');
    }
  }

  /// Stops the heartbeat timer and clears stored session key.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _activeLogId = null;
    removeSessionItem('active_audit_log_id');
    debugPrint('[Heartbeat] Heartbeat stopped.');
  }
}
