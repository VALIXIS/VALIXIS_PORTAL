import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'providers/analytics_provider.dart';
import 'widgets/kpi_cards_row.dart';
import 'widgets/latency_breakdown_card.dart';
import 'widgets/throughput_chart_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VALIXIS Flow — Executive Analytics & Latency Sparklines'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [7, 14, 30].map((days) {
                final isSelected = state.selectedDays == days;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${days}d'),
                    selected: isSelected,
                    onSelected: (_) => notifier.setDays(days),
                    selectedColor: AppColors.electricCyan,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.obsidianDark : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.obsidianCard,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.electricCyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KpiCardsRow(analytics: state.analytics),
                  const SizedBox(height: 24),
                  ThroughputChartCard(items: state.analytics.dailyVolume),
                  const SizedBox(height: 24),
                  LatencyBreakdownCard(analytics: state.analytics),
                ],
              ),
            ),
    );
  }
}
