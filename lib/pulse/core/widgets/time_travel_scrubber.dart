import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/pulse_theme.dart';

class TimeTravelScrubber extends StatelessWidget {
  final double selectedIndex; // 0 (now) to maxSnapshots
  final int maxSnapshots;
  final ValueChanged<double> onChanged;
  final VoidCallback? onResetLive;
  final DateTime currentTimestamp;
  final bool isLive;
  final String activeWindow; // '24h', '7d'
  final ValueChanged<String>? onWindowChanged;

  const TimeTravelScrubber({
    super.key,
    required this.selectedIndex,
    required this.maxSnapshots,
    required this.onChanged,
    this.onResetLive,
    required this.currentTimestamp,
    this.isLive = true,
    this.activeWindow = '24h',
    this.onWindowChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm:ss');
    final timeStr = dateFormat.format(currentTimestamp);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: PulseColors.cardObsidian.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PulseColors.cardGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    color: isLive ? PulseColors.emeraldGrowth : PulseColors.electricCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'FORENSIC TIME-TRAVEL SCRUBBER',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: PulseColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 6,
                spacing: 8,
                children: [
                  // Timeframe Window Selectors (24h / 7d)
                  Container(
                    decoration: BoxDecoration(
                      color: PulseColors.surfaceObsidian,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PulseColors.cardGlassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['24h', '7d'].map((w) {
                        final isSelected = activeWindow == w;
                        return GestureDetector(
                          onTap: () => onWindowChanged?.call(w),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? PulseColors.electricCyan.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              w,
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? PulseColors.electricCyan : PulseColors.textMuted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Live Stream Indicator & Reset Button
                  GestureDetector(
                    onTap: onResetLive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? PulseColors.emeraldGrowth.withOpacity(0.2)
                            : PulseColors.electricCyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLive ? PulseColors.emeraldGrowth : PulseColors.electricCyan,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLive ? PulseColors.emeraldGrowth : PulseColors.electricCyan,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLive ? 'LIVE TELEMETRY STREAM' : 'SCRUBBING: $timeStr (RESET)',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isLive ? PulseColors.emeraldGrowth : PulseColors.electricCyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: PulseColors.electricCyan,
              inactiveTrackColor: PulseColors.cardGlassBorder,
              thumbColor: PulseColors.electricCyan,
              overlayColor: PulseColors.electricCyan.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              trackHeight: 4,
            ),
            child: Slider(
              value: selectedIndex,
              min: 0,
              max: maxSnapshots.toDouble() > 0 ? maxSnapshots.toDouble() : 1.0,
              divisions: maxSnapshots > 0 ? maxSnapshots : 1,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
