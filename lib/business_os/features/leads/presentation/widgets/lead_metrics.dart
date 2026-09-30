import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/leads_provider.dart';

/// Responsive CRM Pipeline Metrics display.
class LeadMetricsBar extends ConsumerWidget {
  const LeadMetricsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(leadMetricsProvider);
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);

    final cardTotalLeads = _LeadMetricCard(
      title: 'TOTAL LEADS',
      value: metrics.totalLeads.toString(),
      subtitle: '${metrics.wonLeads} deals closed won',
      icon: Icons.people_alt_outlined,
      accentColor: AppColors.info,
    );

    final cardPipelineValue = _LeadMetricCard(
      title: 'PIPELINE VALUE',
      value: metrics.formattedValue,
      subtitle: 'Active sales opportunity',
      icon: Icons.account_balance_wallet_outlined,
      accentColor: AppColors.primary,
    );

    final cardWinRate = _LeadMetricCard(
      title: 'WIN RATE',
      value: metrics.formattedWinRate,
      subtitle: metrics.totalLeads > 0
          ? '${metrics.wonLeads} of ${metrics.totalLeads} converted'
          : 'No closed pipeline yet',
      icon: Icons.show_chart_rounded,
      accentColor: AppColors.success,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cardTotalLeads,
          const SizedBox(height: 12),
          cardPipelineValue,
          const SizedBox(height: 12),
          cardWinRate,
        ],
      );
    }

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: cardTotalLeads),
              const SizedBox(width: 16),
              Expanded(child: cardPipelineValue),
            ],
          ),
          const SizedBox(height: 16),
          cardWinRate,
        ],
      );
    }

    // Desktop: 3 cards across
    return Row(
      children: [
        Expanded(child: cardTotalLeads),
        const SizedBox(width: 16),
        Expanded(child: cardPipelineValue),
        const SizedBox(width: 16),
        Expanded(child: cardWinRate),
      ],
    );
  }
}

class _LeadMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _LeadMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.title.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
