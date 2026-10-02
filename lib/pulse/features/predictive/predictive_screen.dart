import 'package:flutter/material.dart';
import '../../core/theme/pulse_theme.dart';
import '../dashboard/widgets/arr_forecast_chart.dart';
import '../dashboard/widgets/churn_radar_widget.dart';

class PredictiveScreen extends StatelessWidget {
  final Map<String, dynamic> arrData;
  final Map<String, dynamic> churnData;

  const PredictiveScreen({
    super.key,
    this.arrData = const {},
    this.churnData = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseColors.backgroundObsidian,
      appBar: AppBar(
        title: const Text('Gemini 2.5 Predictive Intelligence Node'),
        backgroundColor: PulseColors.surfaceObsidian,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ArrForecastChart(forecastData: arrData),
            const SizedBox(height: 24),
            ChurnRadarWidget(churnData: churnData),
          ],
        ),
      ),
    );
  }
}
