import 'package:flutter/material.dart';
import '../../core/theme/pulse_theme.dart';
import '../telemetry/models/telemetry_event.dart';

class AnomalyInspectorScreen extends StatelessWidget {
  final List<AnomalyAlert> anomalies;

  const AnomalyInspectorScreen({
    super.key,
    this.anomalies = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseColors.backgroundObsidian,
      appBar: AppBar(
        title: const Text('Autonomous Anomaly & Self-Healing Monitor'),
        backgroundColor: PulseColors.surfaceObsidian,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: anomalies.length,
        itemBuilder: (context, idx) {
          final anom = anomalies[idx];
          return Card(
            color: PulseColors.surfaceObsidian,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.warning_amber, color: PulseColors.coralRedAlert),
              title: Text(anom.title, style: TextStyle(color: PulseColors.textPrimary)),
              subtitle: Text(
                'Source: ${anom.source} | Current: ${anom.currentValue}% (Threshold: ${anom.thresholdValue}%)',
                style: TextStyle(color: PulseColors.textSecondary),
              ),
              trailing: Chip(
                label: Text(anom.status.toUpperCase()),
                backgroundColor: PulseColors.coralRedAlert.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }
}
