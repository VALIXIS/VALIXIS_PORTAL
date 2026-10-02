import 'package:flutter/material.dart';
import '../../../core/theme/pulse_theme.dart';

class LatencyGaugeWidget extends StatelessWidget {
  final int currentLatencyMs;
  final int targetSlaMs;

  const LatencyGaugeWidget({
    super.key,
    required this.currentLatencyMs,
    this.targetSlaMs = 50,
  });

  bool get isSlaMet => currentLatencyMs <= targetSlaMs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PulseColors.cardObsidian.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PulseColors.cardGlassBorder),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSlaMet ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.speed,
                  color: isSlaMet ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TELEMETRY INGESTION SLA',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textSecondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text(
                            '${currentLatencyMs}ms',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: PulseColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(SLA Goal < ${targetSlaMs}ms)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: PulseColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isSlaMet ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSlaMet ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert,
                width: 1,
              ),
            ),
            child: Text(
              isSlaMet ? 'SLA OPTIMAL (<50ms)' : 'SLA WARNING',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSlaMet ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
