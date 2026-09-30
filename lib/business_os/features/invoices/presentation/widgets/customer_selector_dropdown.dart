import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../customers/presentation/providers/customers_provider.dart';

/// Glassmorphic customer selector pulling real customers from CRM.
class CustomerSelectorDropdown extends ConsumerWidget {
  final String? selectedCustomerId;
  final ValueChanged<String> onCustomerSelected;

  const CustomerSelectorDropdown({
    super.key,
    required this.selectedCustomerId,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersState = ref.watch(customersProvider);

    if (customersState.isLoading && customersState.customers.isEmpty) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Expanded(
              child: Text(
                'Loading organization customers...',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (customersState.error != null && customersState.customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 18, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Failed to load customers: ${customersState.error}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(customersProvider.notifier).loadCustomers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final customers = customersState.customers;

    if (customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.business_outlined, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No customers found in this organization. Add customers in CRM first.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      key: const Key('customer_selector_dropdown'),
      initialValue: selectedCustomerId != null &&
              customers.any((c) => c.id == selectedCustomerId)
          ? selectedCustomerId
          : null,
      isExpanded: true,
      dropdownColor: AppColors.surfaceElevated,
      decoration: const InputDecoration(
        hintText: 'Select Bill-to Customer *',
        prefixIcon: Icon(Icons.business_rounded, size: 18, color: AppColors.primary),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
      items: customers.map((c) {
        final label = c.companyName.isNotEmpty
            ? '${c.companyName} (${c.name})'
            : c.name;
        return DropdownMenuItem<String>(
          key: Key('customer_dropdown_item_${c.id}'),
          value: c.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  c.initial,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (c.taxId != null && c.taxId!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  'Tax: ${c.taxId}',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          onCustomerSelected(val);
        }
      },
    );
  }
}
