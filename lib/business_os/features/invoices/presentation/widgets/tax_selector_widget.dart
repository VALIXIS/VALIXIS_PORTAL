import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/utils/financial_calculator.dart';

/// Tax percentage rate selector constrained strictly to 0%, 5%, 12%, 18%, 28%.
class TaxSelectorWidget extends StatelessWidget {
  final double selectedTaxRate;
  final ValueChanged<double> onTaxRateSelected;

  const TaxSelectorWidget({
    super.key,
    required this.selectedTaxRate,
    required this.onTaxRateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.percent_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Tax / GST Rate *',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FinancialCalculator.allowedTaxRates.map((rate) {
            final isSelected = (selectedTaxRate - rate).abs() < 0.01;
            final intRate = rate.toInt();
            final label = '$intRate%';

            return InkWell(
              key: Key('tax_rate_$intRate'),
              onTap: () => onTaxRateSelected(rate),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceElevated.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
