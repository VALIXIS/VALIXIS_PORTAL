import 'package:flutter/material.dart';
import '../../../core/theme/pulse_theme.dart';
import '../../../core/widgets/animated_gradient_border.dart';
import '../../../core/widgets/rolling_digit_counter.dart';

class KpiMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final String trendLabel;
  final bool isPositiveTrend;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const KpiMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    required this.trendLabel,
    required this.isPositiveTrend,
    required this.icon,
    this.accentColor = PulseColors.electricCyan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBorder(
      borderRadius: 16,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PulseColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RollingDigitCounter(
                  value: value,
                  prefix: prefix,
                  suffix: suffix,
                  decimalPlaces: decimalPlaces,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                      color: isPositiveTrend ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPositiveTrend ? PulseColors.emeraldGrowth : PulseColors.coralRedAlert,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'vs last period',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: PulseColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
