import 'dart:async';
import 'package:flutter/material.dart';
import '../models/telemetry_event.dart';
import '../models/dashboard_cache_payload.dart';
import '../services/telemetry_service.dart';
import '../services/offline_cache_service.dart';
import '../services/network_resilience_manager.dart';
import '../../simulator/models/simulation_scenario.dart';
import '../../simulator/services/synthetic_traffic_injector.dart';

class TelemetryProvider extends ChangeNotifier {
  final TelemetryService _service;
  final SyntheticTrafficInjector _injector = SyntheticTrafficInjector();
  final OfflineCacheService _offlineCacheService = OfflineCacheService();
  final NetworkResilienceManager _resilienceManager = NetworkResilienceManager();

  // Active Organization Context
  final String _organizationId = 'org_valixis_prod';
  String get organizationId => _organizationId;

  // Real-time Telemetry Snapshots
  List<MetricSnapshot> _snapshots = [];
  List<MetricSnapshot> get snapshots => _snapshots;

  // Time-Travel Scrubber State
  double _scrubberIndex = 0.0;
  double get scrubberIndex => _scrubberIndex;
  bool _isScrubbing = false;
  bool get isScrubbing => _isScrubbing;

  MetricSnapshot? get currentSnapshot {
    if (_snapshots.isEmpty) return null;
    final idx = _scrubberIndex.round();
    if (idx >= 0 && idx < _snapshots.length) {
      return _snapshots[idx];
    }
    return _snapshots.first;
  }

  // Anomalies & Alerts
  List<AnomalyAlert> _anomalies = [];
  List<AnomalyAlert> get anomalies => _anomalies;

  // Gemini Predictive State
  Map<String, dynamic> _arrPrediction = {};
  Map<String, dynamic> get arrPrediction => _arrPrediction;

  Map<String, dynamic> _churnRadar = {};
  Map<String, dynamic> get churnRadar => _churnRadar;

  // Real-time Ingestion Latency Stats
  int _lastIngestionLatencyMs = 18;
  int get lastIngestionLatencyMs => _lastIngestionLatencyMs;

  bool _isSelfHealingActive = false;
  bool get isSelfHealingActive => _isSelfHealingActive;

  // Live Synthetic Simulator State
  SimulationScenario? _activeSimulationScenario;
  SimulationScenario? get activeSimulationScenario => _activeSimulationScenario;
  bool get isSimulating => _activeSimulationScenario != null;

  int _simulatedEventRate = 100;
  int get simulatedEventRate => _simulatedEventRate;

  int _totalEventsInjected = 0;
  int get totalEventsInjected => _totalEventsInjected;

  // Offline Resilience & Local Cache State
  bool get isOnline => _resilienceManager.isOnline;
  bool _isUsingCachedData = false;
  bool get isUsingCachedData => _isUsingCachedData;

  DateTime? _lastCacheTimestamp;
  DateTime? get lastCacheTimestamp => _lastCacheTimestamp;

  int _nextBackoffSec = 1;
  int get nextBackoffSec => _nextBackoffSec;

  Timer? _realtimeTimer;
  Timer? _simulationTimer;

  TelemetryProvider(this._service) {
    _initializeDemoData();
    _startRealtimeStream();
    _setupResilienceManager();
  }

  void _setupResilienceManager() {
    _resilienceManager.setConnectivityListener((online, attempt, backoffSec) {
      _nextBackoffSec = backoffSec;
      if (!online) {
        _isUsingCachedData = true;
      } else {
        _isUsingCachedData = false;
      }
      notifyListeners();
    });
  }

  void _initializeDemoData() {
    _snapshots = [];
    _anomalies = [];
    _fetchPredictiveData();
    _saveStateToLocalCache();
  }

  void _saveStateToLocalCache() {
    _lastCacheTimestamp = DateTime.now();
    final payload = DashboardCachePayload(
      snapshots: _snapshots,
      arrPrediction: _arrPrediction,
      churnRadar: _churnRadar,
      anomalies: _anomalies,
      cachedAt: _lastCacheTimestamp!,
    );
    _offlineCacheService.saveDashboardCache(payload);
  }

  void _fetchPredictiveData() async {
    _arrPrediction = await _service.fetchPredictiveAnalytics(
      organizationId: _organizationId,
      forecastType: 'arr_12m',
    );
    _churnRadar = await _service.fetchPredictiveAnalytics(
      organizationId: _organizationId,
      forecastType: 'churn_radar',
    );
    _saveStateToLocalCache();
    notifyListeners();
  }

  void _startRealtimeStream() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isScrubbing && !isSimulating && isOnline && _snapshots.isNotEmpty) {
        final latest = _snapshots.first;
        final updated = MetricSnapshot(
          id: 'snap_live_${DateTime.now().millisecondsSinceEpoch}',
          organizationId: _organizationId,
          timestamp: DateTime.now(),
          arrUsd: latest.arrUsd + 120.0,
          activeUsers: latest.activeUsers + 1,
          churnRiskScore: latest.churnRiskScore,
          webhookLatencyP95: 20 + (DateTime.now().second % 6),
          statusHealth: _anomalies.any((a) => a.status == 'active')
              ? 'critical'
              : 'optimal',
        );

        _snapshots.insert(0, updated);
        if (_snapshots.length > 50) _snapshots.removeLast();
        _lastIngestionLatencyMs = 14 + (DateTime.now().second % 10);
        _saveStateToLocalCache();
        notifyListeners();
      }
    });
  }

  /// Simulates a network drop and activates local fallback mode.
  Future<void> simulateNetworkDrop() async {
    _resilienceManager.simulateNetworkDrop();
    _isUsingCachedData = true;

    final cachedPayload = await _offlineCacheService.getDashboardCache();
    if (cachedPayload != null) {
      _snapshots = cachedPayload.snapshots;
      _arrPrediction = cachedPayload.arrPrediction;
      _churnRadar = cachedPayload.churnRadar;
      _anomalies = cachedPayload.anomalies;
      _lastCacheTimestamp = cachedPayload.cachedAt;
    }
    notifyListeners();
  }

  /// Simulates network reconnection and restores live streaming.
  void simulateNetworkReconnect() {
    _resilienceManager.simulateNetworkReconnect();
    _isUsingCachedData = false;
    _saveStateToLocalCache();
    notifyListeners();
  }

  /// Injects a synthetic operational traffic scenario into the live telemetry stream.
  void injectSyntheticScenario(SimulationScenario scenario, {int ratePerSec = 100}) {
    _activeSimulationScenario = scenario;
    _simulatedEventRate = ratePerSec;
    _simulationTimer?.cancel();

    final newSnap = _injector.computeSimulatedSnapshot(
      scenario: scenario,
      organizationId: _organizationId,
      stepIndex: _totalEventsInjected,
    );
    _snapshots.insert(0, newSnap);
    if (_snapshots.length > 50) _snapshots.removeLast();

    _lastIngestionLatencyMs = scenario.targetLatencyMs;
    _totalEventsInjected += ratePerSec;

    if (scenario.anomalyTitle != null) {
      final newAnomaly = AnomalyAlert(
        id: 'anom_sim_${DateTime.now().millisecondsSinceEpoch}',
        organizationId: _organizationId,
        title: scenario.anomalyTitle!,
        severity: scenario.anomalySeverity ?? 'critical',
        source: scenario.anomalySource ?? 'Synthetic Simulator',
        metric: 'simulated_fault',
        currentValue: 98.4,
        thresholdValue: 5.0,
        status: 'active',
        createdAt: DateTime.now(),
      );
      _anomalies.insert(0, newAnomaly);
    }

    _saveStateToLocalCache();
    notifyListeners();

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_activeSimulationScenario != null && !_isScrubbing && isOnline) {
        final stepSnap = _injector.computeSimulatedSnapshot(
          scenario: _activeSimulationScenario!,
          organizationId: _organizationId,
          stepIndex: _totalEventsInjected,
        );
        _snapshots.insert(0, stepSnap);
        if (_snapshots.length > 50) _snapshots.removeLast();

        _lastIngestionLatencyMs = _activeSimulationScenario!.targetLatencyMs;
        _totalEventsInjected += ratePerSec * 2;
        _saveStateToLocalCache();
        notifyListeners();
      }
    });
  }

  /// Stops active simulation and restores baseline live stream.
  void stopSimulation() {
    _activeSimulationScenario = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _lastIngestionLatencyMs = 18;
    notifyListeners();
  }

  void updateScrubberPosition(double index) {
    _scrubberIndex = index;
    _isScrubbing = index > 0.5;
    notifyListeners();
  }

  void resetToLiveStream() {
    _scrubberIndex = 0.0;
    _isScrubbing = false;
    notifyListeners();
  }

  Future<bool> triggerSelfHealing(AnomalyAlert anomaly) async {
    _isSelfHealingActive = true;
    notifyListeners();

    final success = await _service.dispatchSelfHealingAction(
      anomalyId: anomaly.id,
      organizationId: _organizationId,
      actionType: 'retry_webhook_queue_and_scale_workers',
      parameters: {'target_service': anomaly.source, 'metric': anomaly.metric},
    );

    if (success) {
      final index = _anomalies.indexWhere((a) => a.id == anomaly.id);
      if (index != -1) {
        _anomalies[index] = AnomalyAlert(
          id: anomaly.id,
          organizationId: anomaly.organizationId,
          title: anomaly.title,
          severity: anomaly.severity,
          source: anomaly.source,
          metric: anomaly.metric,
          currentValue: anomaly.currentValue,
          thresholdValue: anomaly.thresholdValue,
          status: 'self_healing_dispatched',
          createdAt: anomaly.createdAt,
        );
      }
    }

    _isSelfHealingActive = false;
    _saveStateToLocalCache();
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    _simulationTimer?.cancel();
    _resilienceManager.dispose();
    super.dispose();
  }
}
