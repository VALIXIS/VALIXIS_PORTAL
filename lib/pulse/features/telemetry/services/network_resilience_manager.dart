import 'dart:async';
import 'dart:math' as math;

typedef ConnectivityCallback = void Function(bool isOnline, int reconnectAttempt, int nextBackoffSec);

class NetworkResilienceManager {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  int _reconnectAttempts = 0;
  int get reconnectAttempts => _reconnectAttempts;

  Timer? _reconnectTimer;
  ConnectivityCallback? _onConnectivityChanged;

  void setConnectivityListener(ConnectivityCallback callback) {
    _onConnectivityChanged = callback;
  }

  /// Calculates exponential backoff delay in seconds for reconnection: 1s, 2s, 4s, 8s, 16s, max 32s.
  int getBackoffDelaySeconds(int attempt) {
    if (attempt <= 0) return 1;
    final delay = math.pow(2, attempt - 1).toInt();
    return delay.clamp(1, 32);
  }

  /// Simulates a network disconnection event.
  void simulateNetworkDrop() {
    _isOnline = false;
    _reconnectAttempts = 1;
    _scheduleReconnectTimer();
  }

  /// Simulates a network restoration event.
  void simulateNetworkReconnect() {
    _isOnline = true;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _onConnectivityChanged?.call(_isOnline, 0, 0);
  }

  void _scheduleReconnectTimer() {
    _reconnectTimer?.cancel();
    final backoffSec = getBackoffDelaySeconds(_reconnectAttempts);

    _onConnectivityChanged?.call(_isOnline, _reconnectAttempts, backoffSec);

    _reconnectTimer = Timer(Duration(seconds: backoffSec), () {
      if (!_isOnline) {
        _reconnectAttempts++;
        // Attempt reconnection
        _scheduleReconnectTimer();
      }
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
  }
}
