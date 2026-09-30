import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/dashboard_kpi_providers.dart';

/// Interactive 5-stage sales conversion funnel visualization.
class ConversionFunnelWidget extends StatelessWidget {
  final ConversionFunnelData funnelData;

  const ConversionFunnelWidget({
    super.key,
    required this.funnelData,
  });

  @override
  Widget build(BuildContext context) {
    final stages = funnelData.stages;
    final totalLeads = funnelData.totalLeads;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pipeline Conversion Funnel', style: AppTypography.sectionTitle),
                    const SizedBox(height: 4),
                    Text(
                      '$totalLeads total leads in CRM pipeline',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${funnelData.overallWinRate.toStringAsFixed(1)}% WIN RATE',
                  style: AppTypography.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (totalLeads == 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Text(
                'No leads in CRM pipeline yet',
                style: AppTypography.bodySmall,
              ),
            )
          else
            Column(
              children: stages.map((stageItem) {
                final stage = stageItem.stage;
                final count = stageItem.count;
                final percentage = stageItem.percentageOfTotal;
                final fillRatio = totalLeads > 0 ? (count / totalLeads) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(stage.icon, size: 16, color: stage.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stage.label,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '$count leads',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: fillRatio.clamp(0.02, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: stage.color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: stage.color.withValues(alpha: 0.35),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
