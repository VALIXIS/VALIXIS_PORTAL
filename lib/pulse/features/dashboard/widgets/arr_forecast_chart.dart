import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/pulse_theme.dart';

class ArrForecastChart extends StatelessWidget {
  final Map<String, dynamic> forecastData;

  const ArrForecastChart({
    super.key,
    required this.forecastData,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> months = forecastData['forecast_12m'] ?? [];

    List<FlSpot> spots = [];
    List<FlSpot> upperSpots = [];
    List<FlSpot> lowerSpots = [];

    for (int i = 0; i < months.length; i++) {
      final item = months[i];
      final val = ((item['predicted_arr'] as num?)?.toDouble() ?? 0.0) /
          1000000.0;
      final up = ((item['upper'] as num?)?.toDouble() ?? 0.0) / 1000000.0;
      final low =
          ((item['lower'] as num?)?.toDouble() ?? 0.0) / 1000000.0;
      spots.add(FlSpot(i.toDouble(), val));
      upperSpots.add(FlSpot(i.toDouble(), up));
      lowerSpots.add(FlSpot(i.toDouble(), low));
    }

    final hasData = spots.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_graph,
                          color: PulseColors.electricCyan, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'GEMINI 2.5 PREDICTIVE ARR FORECAST (12M)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: PulseColors.textSecondary,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasData
                        ? 'Target baseline vs projected growth trajectory'
                        : 'Awaiting telemetry telemetry streams for predictive projection',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: PulseColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PulseColors.electricCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PulseColors.electricCyan, width: 1),
                ),
                child: Text(
                  'ZERO CoT LOGGING ENFORCED',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.electricCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!hasData)
            Container(
              height: 240,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights, size: 36, color: PulseColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No historical invoice or contract telemetry to project ARR.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: PulseColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Projections populate dynamically as live billing cycles execute.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: PulseColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: PulseColors.cardGlassBorder.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (val, meta) => Text(
                          '\$${val.toStringAsFixed(2)}M',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 10,
                            color: PulseColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          const labels = ['M1', 'M2', 'M3', 'M6', 'M12'];
                          final idx = val.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Text(
                              labels[idx],
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 11,
                                color: PulseColors.textSecondary,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: upperSpots,
                      isCurved: true,
                      color: PulseColors.electricCyan.withOpacity(0.3),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                      dashArray: [4, 4],
                    ),
                    LineChartBarData(
                      spots: lowerSpots,
                      isCurved: true,
                      color: PulseColors.electricCyan.withOpacity(0.3),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                      dashArray: [4, 4],
                    ),
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: PulseColors.electricCyan,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: PulseColors.electricCyan.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCashPill('30D CASH PROJECTION', '\$0.0k', '0 active contracts'),
                _buildCashPill('60D CASH PROJECTION', '\$0.0k', '0 active contracts'),
                _buildCashPill('90D CASH PROJECTION', '\$0.0k', '0 active contracts'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashPill(String title, String amount, String interval) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PulseColors.surfaceObsidian,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PulseColors.cardGlassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: PulseColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PulseColors.electricCyan,
              ),
            ),
            Text(
              interval,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: PulseColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
