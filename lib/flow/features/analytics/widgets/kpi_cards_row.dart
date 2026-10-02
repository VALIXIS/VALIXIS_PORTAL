import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/flow_analytics_model.dart';

class KpiCardsRow extends StatelessWidget {
  final FlowAnalytics analytics;

  const KpiCardsRow({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final cards = [
          _buildKpiCard(
            title: 'Total Automations Executed',
            value: analytics.totalRuns.toString(),
            subtitle: '${analytics.successfulRuns} succeeded · ${analytics.failedRuns} failed',
            icon: Icons.bolt,
            color: AppColors.electricCyan,
          ),
          _buildKpiCard(
            title: '7-Day Reliability Rate',
            value: '${analytics.successRatePercent.toStringAsFixed(1)}%',
            subtitle: 'Target SLA: 99.90%',
            icon: Icons.verified_user,
            color: analytics.successRatePercent >= 98.0
                ? AppColors.emeraldGreen
                : AppColors.coralRed,
          ),
          _buildKpiCard(
            title: 'Avg Execution Latency',
            value: '${analytics.avgOverallLatencyMs.toStringAsFixed(0)} ms',
            subtitle: 'Webhook intake: ${analytics.avgWebhookLatencyMs.toStringAsFixed(0)} ms',
            icon: Icons.speed,
            color: AppColors.violetAccent,
          ),
        ];

        if (isMobile) {
          return Column(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: card,
                    ))
                .toList(),
          );
        }

        return Row(
          children: cards
              .map((card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: card,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: AppColors.obsidianCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
