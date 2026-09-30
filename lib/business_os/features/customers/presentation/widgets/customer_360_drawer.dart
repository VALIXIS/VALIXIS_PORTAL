import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/customers_provider.dart';

/// Reusable slide-over Customer 360 profile drawer.
class Customer360Drawer extends ConsumerWidget {
  final Customer customer;
  final VoidCallback onClose;

  const Customer360Drawer({
    super.key,
    required this.customer,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer360Async = ref.watch(customer360Provider(customer.id));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated.withValues(alpha: 0.98),
        border: Border(left: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(context),
          Divider(height: 1, color: AppColors.border),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Company Overview Section
                  _buildCompanyDetailsSection(),
                  const SizedBox(height: 20),

                  // Customer 360 Async Content (Revenue, Tasks, Invoices)
                  customer360Async.when(
                    data: (data) => _build360Content(context, ref, data),
                    loading: () => _build360Skeleton(),
                    error: (error, _) => _build360Error(ref, error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
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
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        customer.companyName,
                        style: AppTypography.title.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: customer.isActive
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.textSecondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: customer.isActive
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        customer.status.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: customer.isActive
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Customer 360 Profile  •  Primary: ${customer.name}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close Customer 360 Drawer',
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailsSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Company Information', style: AppTypography.label),
          const SizedBox(height: 12),
          _detailItem(
            Icons.person_outline_rounded,
            'Primary Contact',
            customer.name,
          ),
          const SizedBox(height: 8),
          _detailItem(Icons.email_outlined, 'Email', customer.email),
          if (customer.phone != null && customer.phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailItem(Icons.phone_outlined, 'Phone', customer.phone!),
          ],
          if (customer.billingAddress != null &&
              customer.billingAddress!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailItem(
              Icons.location_on_outlined,
              'Billing Address',
              customer.billingAddress!,
            ),
          ],
          if (customer.taxId != null && customer.taxId!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailItem(Icons.receipt_outlined, 'Tax ID', customer.taxId!),
          ],
          const SizedBox(height: 8),
          _detailItem(
            Icons.calendar_today_outlined,
            'Account Created',
            '${customer.createdAt.year}-${customer.createdAt.month.toString().padLeft(2, '0')}-${customer.createdAt.day.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _build360Content(
    BuildContext context,
    WidgetRef ref,
    Customer360 data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Total Revenue Card
        _buildRevenueCard(data.totalRevenue),
        const SizedBox(height: 20),

        // Linked Tasks Section
        _buildTasksSection(data.tasks),
        const SizedBox(height: 20),

        // Linked Invoices Section
        _buildInvoicesSection(data.invoices),
      ],
    );
  }

  Widget _buildRevenueCard(double totalRevenue) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL REVENUE GENERATED', style: AppTypography.label),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lifetime',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppUtils.formatCurrency(totalRevenue),
            style: AppTypography.metric.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Aggregated billing across all finalized invoices',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(List<CustomerTask> tasks) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Linked Tasks (${tasks.length})',
                style: AppTypography.label,
              ),
              Text(
                '${tasks.where((t) => !t.isDone).length} Open',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No linked operational tasks found.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(CustomerTask task) {
    final Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'critical':
        priorityColor = AppColors.error;
        break;
      case 'high':
        priorityColor = AppColors.warning;
        break;
      case 'medium':
        priorityColor = AppColors.secondary;
        break;
      default:
        priorityColor = AppColors.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: priorityColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Status: ${task.status.replaceAll('_', ' ')}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (task.assignee != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rep: ${task.assignee}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesSection(List<CustomerInvoice> invoices) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Linked Invoices (${invoices.length})',
                style: AppTypography.label,
              ),
              Text(
                '${invoices.where((i) => i.isPaid).length} Paid',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (invoices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No linked billing invoices found.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...invoices.map((inv) => _buildInvoiceItem(inv)),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(CustomerInvoice inv) {
    final Color statusColor;
    switch (inv.status.toLowerCase()) {
      case 'paid':
        statusColor = AppColors.success;
        break;
      case 'sent':
        statusColor = AppColors.info;
        break;
      case 'overdue':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.invoiceNumber,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Due: ${inv.dueDate.year}-${inv.dueDate.month.toString().padLeft(2, '0')}-${inv.dueDate.day.toString().padLeft(2, '0')}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(inv.amount),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inv.status.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build360Skeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 36,
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

  Widget _build360Error(WidgetRef ref, Object error) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load 360 data',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.refresh(customer360Provider(customer.id)),
              icon: const Icon(Icons.refresh_rounded, size: 14),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
