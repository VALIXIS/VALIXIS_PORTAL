import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/customers_provider.dart';

/// Desktop & wide-screen production-quality customer directory table.
class CustomerTable extends ConsumerWidget {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final void Function(Customer customer) onSelectCustomer;

  const CustomerTable({
    super.key,
    required this.customers,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onSelectCustomer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedCustomerIdProvider);

    if (isLoading && customers.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (error != null && customers.isEmpty) {
      return _buildErrorState();
    }

    if (customers.isEmpty) {
      return _buildEmptyState(ref);
    }

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 880),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              horizontalMargin: 20,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(
                AppColors.surfaceElevated.withValues(alpha: 0.6),
              ),
              columns: [
                DataColumn(label: Text('Company', style: AppTypography.label)),
                DataColumn(
                  label: Text('Primary Contact', style: AppTypography.label),
                ),
                DataColumn(label: Text('Status', style: AppTypography.label)),
                DataColumn(
                  label: Text('Account ID', style: AppTypography.label),
                ),
                DataColumn(label: Text('Actions', style: AppTypography.label)),
              ],
              rows: customers.map((customer) {
                final isSelected = selectedId == customer.id;

                return DataRow(
                  selected: isSelected,
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (isSelected) {
                      return AppColors.primary.withValues(alpha: 0.12);
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.surfaceElevated.withValues(alpha: 0.8);
                    }
                    return Colors.transparent;
                  }),
                  onSelectChanged: (_) => onSelectCustomer(customer),
                  cells: [
                    // Company Column
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                customer.initial,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                customer.companyName,
                                style: AppTypography.title.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              if (customer.taxId != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Tax ID: ${customer.taxId}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Primary Contact Column
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customer.email,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Column
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: customer.isActive
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.textSecondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: customer.isActive
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                        ),
                        child: Text(
                          customer.status.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: customer.isActive
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Account ID / Source Lead
                    DataCell(
                      Text(
                        customer.convertedFromLeadId != null
                            ? 'Lead Conv.'
                            : customer.id.length > 12
                            ? '${customer.id.substring(0, 10)}...'
                            : customer.id,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),

                    // Actions Column
                    DataCell(
                      OutlinedButton.icon(
                        onPressed: () => onSelectCustomer(customer),
                        icon: const Icon(Icons.visibility_rounded, size: 14),
                        label: const Text('View 360'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          textStyle: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load customers',
              style: AppTypography.title.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 6),
            Text(
              error ?? 'An unexpected error occurred.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    final query = ref.watch(customersProvider).searchQuery;
    final isFiltering = query.trim().isNotEmpty;

    return GlassContainer(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltering
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltering
                  ? 'No customers match "$query"'
                  : 'No customer accounts yet',
              style: AppTypography.title,
            ),
            const SizedBox(height: 6),
            Text(
              isFiltering
                  ? 'Try searching by a different company name, contact, or email.'
                  : 'Add your first enterprise customer or convert a won sales lead.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (isFiltering) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(customersProvider.notifier).setSearchQuery(''),
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear Search Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
