import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/flow_analytics_model.dart';

class LatencyBreakdownCard extends StatelessWidget {
  final FlowAnalytics analytics;

  const LatencyBreakdownCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final total = analytics.avgWebhookLatencyMs +
        analytics.avgAiLatencyMs +
        analytics.avgActionLatencyMs;
    final totalSafe = total > 0 ? total : 1.0;

    return Card(
      color: AppColors.obsidianCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: AppColors.violetAccent, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sub-Step Latency Breakdown & SLA Sparklines',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Real-time execution latency across edge triggers, Gemini AI inference, and database transactions.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            _buildLatencyBar(
              stepName: '1. Inbound Webhook Ingestion',
              latencyMs: analytics.avgWebhookLatencyMs,
              percent: analytics.avgWebhookLatencyMs / totalSafe,
              slaLimitMs: 150,
              color: AppColors.electricCyan,
            ),
            const SizedBox(height: 16),
            _buildLatencyBar(
              stepName: '2. Gemini 2.5 Flash Reasoning',
              latencyMs: analytics.avgAiLatencyMs,
              percent: analytics.avgAiLatencyMs / totalSafe,
              slaLimitMs: 1500,
              color: AppColors.violetAccent,
            ),
            const SizedBox(height: 16),
            _buildLatencyBar(
              stepName: '3. Business OS Action Dispatcher',
              latencyMs: analytics.avgActionLatencyMs,
              percent: analytics.avgActionLatencyMs / totalSafe,
              slaLimitMs: 200,
              color: AppColors.emeraldGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatencyBar({
    required String stepName,
    required double latencyMs,
    required double percent,
    required int slaLimitMs,
    required Color color,
  }) {
    final isCompliant = latencyMs <= slaLimitMs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                stepName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  '${latencyMs.toStringAsFixed(1)} ms',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isCompliant ? AppColors.emeraldGreen : AppColors.statusRetrying)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (isCompliant ? AppColors.emeraldGreen : AppColors.statusRetrying)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    isCompliant ? 'SLA OK' : 'SLA OVER',
                    style: TextStyle(
                      color: isCompliant ? AppColors.emeraldGreen : AppColors.statusRetrying,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.02, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.obsidianSurface,
            color: color,
          ),
        ),
      ],
    );
  }
}
