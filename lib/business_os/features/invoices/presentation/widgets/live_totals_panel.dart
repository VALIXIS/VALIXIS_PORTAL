import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../domain/utils/financial_calculator.dart';

/// Real-time financial summary breakdown displaying subtotal, tax amount, and grand total.
class LiveTotalsPanel extends StatelessWidget {
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double grandTotal;
  final String currency;

  const LiveTotalsPanel({
    super.key,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.grandTotal,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Financial Summary',
                style: AppTypography.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              Text(
                key: const Key('total_subtotal'),
                FinancialCalculator.formatCurrency(subtotal, currency),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tax Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (${taxRate.toInt()}%)',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                key: const Key('total_tax_amount'),
                FinancialCalculator.formatCurrency(taxAmount, currency),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border),
          ),

          // Grand Total (Hero Metric)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Including all taxes & duties ($currency)',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  key: const Key('total_grand_total'),
                  FinancialCalculator.formatCurrency(grandTotal, currency),
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
