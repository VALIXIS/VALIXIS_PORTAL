import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/app_page.dart';
import '../providers/customers_provider.dart';
import '../widgets/add_customer_dialog.dart';
import '../widgets/customer_360_drawer.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_table.dart';

/// Production Customer Directory Table & Slide-Over 360 Profile Drawer.
/// Canonical route: /customers
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddCustomerDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => const AddCustomerDialog(),
    );
  }

  void _selectCustomer(Customer customer) {
    ref.read(selectedCustomerIdProvider.notifier).state = customer.id;

    // On mobile, show modal bottom sheet
    if (AppBreakpoints.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.92,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Customer360Drawer(
              customer: customer,
              onClose: () {
                Navigator.of(ctx).pop();
                ref.read(selectedCustomerIdProvider.notifier).state = null;
              },
            ),
          ),
        ),
      ).whenComplete(() {
        if (mounted) {
          ref.read(selectedCustomerIdProvider.notifier).state = null;
        }
      });
    }
  }

  void _closeDrawer() {
    ref.read(selectedCustomerIdProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersProvider);
    final selectedId = ref.watch(selectedCustomerIdProvider);
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);

    // Find selected customer object if any
    Customer? selectedCustomer;
    if (selectedId != null) {
      try {
        selectedCustomer = state.customers.firstWhere(
          (c) => c.id == selectedId,
        );
      } catch (_) {
        selectedCustomer = null;
      }
    }

    final isDrawerOpenOnWideScreen = !isMobile && selectedCustomer != null;

    return AppPage(
      title: 'Customers',
      subtitle: 'Manage your customer relationships',
      scrollable: false,
      trailing: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Total customer count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.business_center_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Customers',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${state.totalCount}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add Customer Action
          ElevatedButton.icon(
            onPressed: _openAddCustomerDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Customer'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search & Filter Toolbar
          _buildToolbar(state),
          const SizedBox(height: 16),

          // Main Directory Content + Responsive Slide-Over Drawer
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Directory List / Table
                Expanded(
                  child: isMobile
                      ? _buildMobileList(state)
                      : isTablet
                      ? _buildTabletList(state)
                      : _buildDesktopTable(state),
                ),

                // Slide-over Customer 360 Drawer for Desktop/Tablet (300ms easeOutCubic)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: isDrawerOpenOnWideScreen
                      ? Row(
                          key: ValueKey(selectedCustomer.id),
                          children: [
                            const SizedBox(width: 16),
                            SizedBox(
                              width: isTablet ? 380 : 460,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Customer360Drawer(
                                  customer: selectedCustomer,
                                  onClose: _closeDrawer,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('drawer_closed')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(CustomersState state) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  ref.read(customersProvider.notifier).setSearchQuery(val),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search customers by company, contact, or email...',
                hintStyle: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(customersProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ),
        if (state.searchQuery.trim().isNotEmpty) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${state.filteredCustomers.length} results',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopTable(CustomersState state) {
    return CustomerTable(
      customers: state.filteredCustomers,
      isLoading: state.isLoading,
      error: state.error,
      onRetry: () => ref.read(customersProvider.notifier).refresh(),
      onSelectCustomer: _selectCustomer,
    );
  }

  Widget _buildTabletList(CustomersState state) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: ${state.error}', style: AppTypography.bodySmall),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(customersProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = state.filteredCustomers;
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          state.searchQuery.isNotEmpty
              ? 'No customers match your search.'
              : 'No customers available.',
          style: AppTypography.bodySmall,
        ),
      );
    }

    final selectedId = ref.watch(selectedCustomerIdProvider);

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final customer = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomerCard(
            customer: customer,
            isSelected: selectedId == customer.id,
            onSelect: () => _selectCustomer(customer),
          ),
        );
      },
    );
  }

  Widget _buildMobileList(CustomersState state) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: ${state.error}', style: AppTypography.bodySmall),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(customersProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = state.filteredCustomers;
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          state.searchQuery.isNotEmpty
              ? 'No customers match your search.'
              : 'No customers available.',
          style: AppTypography.bodySmall,
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final customer = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomerCard(
            customer: customer,
            onSelect: () => _selectCustomer(customer),
          ),
        );
      },
    );
  }
}
