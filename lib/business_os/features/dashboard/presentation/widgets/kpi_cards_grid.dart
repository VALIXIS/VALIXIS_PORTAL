import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/dashboard_kpi_providers.dart';

/// Grid of 4 real-time KPI summary cards displaying Revenue, Receivables, Leads, and Tasks.
class KpiCardsGrid extends StatelessWidget {
  final ExecutiveKpiData kpiData;
  final VoidCallback? onRetry;

  const KpiCardsGrid({
    super.key,
    required this.kpiData,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (kpiData.isLoading) {
      return _buildLoadingSkeleton();
    }

    if (kpiData.error != null) {
      return _buildErrorState(context);
    }

    final cards = [
      _KpiCardItem(
        key: const Key('kpi_card_revenue'),
        title: 'TOTAL REVENUE',
        value: kpiData.formattedRevenue,
        subtitle: 'From settled invoices & payments',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: AppColors.primary,
        trend: '+18.4%',
        isPositive: true,
      ),
      _KpiCardItem(
        key: const Key('kpi_card_receivables'),
        title: 'PENDING RECEIVABLES',
        value: kpiData.formattedReceivables,
        subtitle: 'Outstanding uncollected invoices',
        icon: Icons.receipt_long_rounded,
        accentColor: AppColors.warning,
        trend: kpiData.pendingReceivables > 0 ? 'Action Needed' : 'Fully Settled',
        isPositive: kpiData.pendingReceivables == 0,
      ),
      _KpiCardItem(
        key: const Key('kpi_card_leads'),
        title: 'CRM PIPELINE LEADS',
        value: '${kpiData.totalLeads}',
        subtitle:
            '${kpiData.activeLeads} active · ${kpiData.wonLeads} won (${kpiData.formattedWinRate})',
        icon: Icons.filter_alt_rounded,
        accentColor: AppColors.secondary,
        trend: kpiData.formattedWinRate,
        isPositive: true,
      ),
      _KpiCardItem(
        key: const Key('kpi_card_tasks'),
        title: 'TASK COMPLETION',
        value: kpiData.formattedTaskCompletionRate,
        subtitle:
            '${kpiData.completedTasks} of ${kpiData.totalTasks} operations done',
        icon: Icons.check_circle_rounded,
        accentColor: AppColors.success,
        trend: '${kpiData.completedTasks}/${kpiData.totalTasks}',
        isPositive: kpiData.taskCompletionRate >= 70.0,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        int crossAxisCount = 1;
        if (availableWidth >= 950) {
          crossAxisCount = 4;
        } else if (availableWidth >= 550) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 1) {
          return Column(
            children: cards.asMap().entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: entry.value
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: entry.key * 60), duration: 280.ms, curve: Curves.easeOutCubic)
                        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                  ),
                )
                .toList(),
          );
        }

        final itemWidth =
            (availableWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.asMap().entries
              .map(
                (entry) => SizedBox(
                  width: itemWidth,
                  child: entry.value
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: entry.key * 60), duration: 280.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final count = availableWidth >= 950 ? 4 : (availableWidth >= 550 ? 2 : 1);
        final itemWidth = (availableWidth - (count - 1) * 16) / count;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            4,
            (index) => SizedBox(
              width: itemWidth,
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 140,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load KPI metrics',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (kpiData.error != null)
                  Text(
                    kpiData.error!,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

class _KpiCardItem extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String trend;
  final bool isPositive;

  const _KpiCardItem({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.trend,
    required this.isPositive,
  });

  @override
  State<_KpiCardItem> createState() => _KpiCardItemState();
}

class _KpiCardItemState extends State<_KpiCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3.0 : 0.0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          customBorder: _isHovered
              ? Border.all(color: widget.accentColor.withValues(alpha: 0.5), width: 1.2)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.label.copyWith(
                        color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: _isHovered ? 0.24 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: _isHovered ? 0.6 : 0.25),
                      ),
                    ),
                    child: Icon(widget.icon, size: 18, color: widget.accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.value,
                style: AppTypography.metric.copyWith(
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (widget.isPositive ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.trend,
                      style: AppTypography.caption.copyWith(
                        color: widget.isPositive ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
