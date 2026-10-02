import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/motion/staggered_card_animator.dart';
import '../../../core/theme/pulse_theme.dart';
import '../../../core/widgets/ambient_glow_background.dart';
import '../../../core/widgets/time_travel_scrubber.dart';
import '../../telemetry/models/telemetry_event.dart';
import '../../telemetry/providers/telemetry_provider.dart';
import '../../telemetry/widgets/offline_status_pill.dart';
import '../../alerts/services/multi_channel_alerting_engine.dart';
import '../../alerts/widgets/alert_dispatch_modal.dart';
import '../../alerts/widgets/alert_threshold_config_modal.dart';
import '../../alerts/widgets/realtime_notification_bell.dart';
import '../../export/widgets/export_center_modal.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/auditor_watermark_overlay.dart';
import '../../auth/widgets/role_switcher_pill.dart';
import '../../simulator/widgets/traffic_simulator_modal.dart';
import '../widgets/arr_forecast_chart.dart';
import '../widgets/churn_radar_widget.dart';
import '../widgets/forensic_log_drawer.dart';
import '../widgets/kpi_metric_card.dart';
import '../widgets/latency_gauge_widget.dart';
import '../widgets/self_healing_modal.dart';

class ExecutivePulseDashboard extends StatefulWidget {
  const ExecutivePulseDashboard({super.key});

  @override
  State<ExecutivePulseDashboard> createState() =>
      _ExecutivePulseDashboardState();
}

class _ExecutivePulseDashboardState extends State<ExecutivePulseDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MultiChannelAlertingEngine _alertingEngine = MultiChannelAlertingEngine();

  void _showSelfHealingDialog(BuildContext context, AnomalyAlert anomaly) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer<TelemetryProvider>(
          builder: (context, provider, child) {
            return SelfHealingModal(
              anomaly: anomaly,
              isLoading: provider.isSelfHealingActive,
              onConfirm: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final success = await provider.triggerSelfHealing(anomaly);
                if (success) {
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Self-healing event dispatched to VALIXIS Flow successfully!'),
                      backgroundColor: PulseColors.emeraldGrowth,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRestrictedArrCard(String roleLabel) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PulseColors.cardObsidian,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, color: Color(0xFFFF5252), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'ARR FORECAST ACCESS RESTRICTED',
            style: TextStyle(
              color: Color(0xFFFF5252),
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Role "$roleLabel" is denied access to executive financial ARR forecasts under Enterprise RBAC security policies.',
              style: TextStyle(color: PulseColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentRole;

    return Consumer<TelemetryProvider>(
      builder: (context, provider, child) {
        final currentSnap = provider.currentSnapshot;
        final healthStatus = currentSnap?.statusHealth ?? 'optimal';
        final activeAnomalies =
            provider.anomalies.where((a) => a.status == 'active').toList();

        return AuditorWatermarkOverlay(
          child: Scaffold(
            key: _scaffoldKey,
            endDrawer: ForensicLogDrawer(snapshots: provider.snapshots),
            body: AmbientGlowBackground(
              statusHealth: healthStatus,
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // 1. EXECUTIVE CANVAS HEADER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 600;
                            return Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 12,
                              spacing: 12,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            PulseColors.electricCyan,
                                            PulseColors.accentPurple
                                          ],
                                        ),
                                      ),
                                      child: const Icon(Icons.bolt,
                                          color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'VALIXIS PULSE',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: PulseColors.textPrimary,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        if (!isCompact)
                                          Text(
                                            'Autonomous Executive Intelligence & Telemetry Tower',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              color: PulseColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const RoleSwitcherPill(),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            provider.isOnline
                                                ? Icons.wifi_rounded
                                                : Icons.wifi_off_rounded,
                                            color: provider.isOnline
                                                ? PulseColors.emeraldGrowth
                                                : const Color(0xFFFFB74D),
                                          ),
                                          tooltip: provider.isOnline
                                              ? 'Simulate Network Drop (Test Offline Cache)'
                                              : 'Simulate Network Reconnect (Restore Stream)',
                                          onPressed: () {
                                            if (provider.isOnline) {
                                              provider.simulateNetworkDrop();
                                            } else {
                                              provider.simulateNetworkReconnect();
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.sensors_rounded,
                                              color: PulseColors.electricCyan),
                                          tooltip: 'Open Synthetic Traffic Simulator',
                                          onPressed: () {
                                            TrafficSimulatorModal.show(context);
                                          },
                                        ),
                                        RealtimeNotificationBell(engine: _alertingEngine),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.tune_rounded,
                                              color: PulseColors.electricCyan),
                                          tooltip: 'Configure Outbound Alert Threshold Rules',
                                          onPressed: () {
                                            AlertThresholdConfigModal.show(context, _alertingEngine);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.download_rounded,
                                              color: PulseColors.electricCyan),
                                          tooltip: 'Open Boardroom Export Studio',
                                          onPressed: () {
                                            ExportCenterModal.show(context);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share_outlined,
                                              color: PulseColors.emeraldGrowth),
                                          tooltip: 'Dispatch Slack & Teams Multi-Channel Alert',
                                          onPressed: () {
                                            AlertDispatchModal.show(context);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.terminal,
                                              color: PulseColors.electricCyan),
                                          tooltip: 'Open Forensic Log Audit Drawer',
                                          onPressed: () {
                                            _scaffoldKey.currentState?.openEndDrawer();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // UNCONTRUSIVE OFFLINE CACHED STATE PILL
                    if (!provider.isOnline || provider.isUsingCachedData)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: OfflineStatusPill(),
                        ),
                      ),

                    // LIVE SYNTHETIC STREAM INDICATOR BANNER
                    if (provider.isSimulating)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: provider.activeSimulationScenario!.accentColor
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: provider.activeSimulationScenario!.accentColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: provider.activeSimulationScenario!.accentColor,
                                    size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'SYNTHETIC TRAFFIC STREAM ACTIVE: ${provider.activeSimulationScenario!.title.toUpperCase()} (${provider.simulatedEventRate} events/sec)',
                                    style: TextStyle(
                                      color: provider.activeSimulationScenario!.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => provider.stopSimulation(),
                                  child: const Text('STOP STREAM',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 2. ACTIVE ANOMALY ALERT BANNER
                    if (activeAnomalies.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: PulseColors.coralRedAlert.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: PulseColors.coralRedAlert),
                            ),
                            child: LayoutBuilder(
                              builder: (context, bannerConstraints) {
                                final isSmall = bannerConstraints.maxWidth < 500;
                                return Flex(
                                  direction: isSmall ? Axis.vertical : Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: isSmall ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: isSmall ? 0 : 1,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.warning_rounded,
                                              color: PulseColors.coralRedAlert,
                                              size: 24),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'CRITICAL SYSTEM ANOMALY DETECTED',
                                                  style: TextStyle(
                                                    fontFamily: 'JetBrainsMono',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: PulseColors.coralRedAlert,
                                                  ),
                                                ),
                                                Text(
                                                  activeAnomalies.first.title,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: PulseColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSmall) const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _showSelfHealingDialog(
                                          context, activeAnomalies.first),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: PulseColors.coralRedAlert,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.flash_on, size: 16),
                                      label: Text(
                                        'TRIGGER SELF-HEALING',
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // 3. TOP ROW KPI CARDS (STAGGERED PHYSICS ENTRANCE)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 900;
                            return GridView.count(
                              crossAxisCount: isWide ? 4 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isWide ? 1.6 : 1.4,
                              children: [
                                StaggeredCardAnimator(
                                  index: 0,
                                  child: KpiMetricCard(
                                    title: 'ARR Velocity',
                                    value: currentSnap?.arrUsd ?? 1250000.0,
                                    prefix: '\$',
                                    trendLabel: '+14.2%',
                                    isPositiveTrend: true,
                                    icon: Icons.monetization_on,
                                    accentColor: PulseColors.electricCyan,
                                  ),
                                ),
                                StaggeredCardAnimator(
                                  index: 1,
                                  child: KpiMetricCard(
                                    title: 'Active Flow Automations',
                                    value: (currentSnap?.activeUsers ?? 4850)
                                        .toDouble(),
                                    trendLabel: '+8.4%',
                                    isPositiveTrend: true,
                                    icon: Icons.alt_route,
                                    accentColor: PulseColors.emeraldGrowth,
                                  ),
                                ),
                                StaggeredCardAnimator(
                                  index: 2,
                                  child: KpiMetricCard(
                                    title: 'CRM Conversion Rate',
                                    value: 28.4,
                                    suffix: '%',
                                    decimalPlaces: 1,
                                    trendLabel: '+3.2%',
                                    isPositiveTrend: true,
                                    icon: Icons.trending_up,
                                    accentColor: PulseColors.accentPurple,
                                  ),
                                ),
                                StaggeredCardAnimator(
                                  index: 3,
                                  child: KpiMetricCard(
                                    title: 'System Latency',
                                    value: (currentSnap?.webhookLatencyP95 ?? 22)
                                        .toDouble(),
                                    suffix: 'ms',
                                    trendLabel: 'p95 SLA',
                                    isPositiveTrend: true,
                                    icon: Icons.speed,
                                    accentColor: PulseColors.electricCyan,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // 4. TELEMETRY INGESTION SLA GAUGE
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: LatencyGaugeWidget(
                          currentLatencyMs: provider.lastIngestionLatencyMs,
                          targetSlaMs: 50,
                        ),
                      ),
                    ),

                    // 5. INTERACTIVE 60FPS TIME-TRAVEL SCRUBBER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: TimeTravelScrubber(
                          selectedIndex: provider.scrubberIndex,
                          maxSnapshots: provider.snapshots.isNotEmpty
                              ? provider.snapshots.length - 1
                              : 1,
                          currentTimestamp:
                              currentSnap?.timestamp ?? DateTime.now(),
                          isLive: !provider.isScrubbing,
                          onChanged: (val) {
                            provider.updateScrubberPosition(val);
                          },
                        ),
                      ),
                    ),

                    // 6. GEMINI 2.5 PREDICTIVE ARR CHART & CHURN RISK RADAR
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth > 1000;
                            final renderArrChart = userRole.canAccessArrForecasts
                                ? ArrForecastChart(forecastData: provider.arrPrediction)
                                : _buildRestrictedArrCard(userRole.label);

                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: renderArrChart,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: ChurnRadarWidget(
                                        churnData: provider.churnRadar),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                renderArrChart,
                                const SizedBox(height: 16),
                                ChurnRadarWidget(churnData: provider.churnRadar),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
