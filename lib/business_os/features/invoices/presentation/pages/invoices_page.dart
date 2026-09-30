import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../dialogs/record_payment_dialog.dart';
import '../providers/invoices_provider.dart';
import '../screens/invoice_builder_screen.dart';
import '../services/invoice_pdf_service.dart';

/// Central Invoices & Billing Page displaying live financial metrics,
/// directory of enterprise invoices, and entrypoint to the Invoice Builder.
class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  ConsumerState<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  bool _showingInlineBuilder = false;

  void _openBuilder() {
    // If running in GoRouter context, we can push or toggle
    try {
      context.push(RoutePaths.invoiceBuilder);
    } catch (_) {
      setState(() {
        _showingInlineBuilder = true;
      });
    }
  }

  void _closeBuilder() {
    setState(() {
      _showingInlineBuilder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingInlineBuilder) {
      return InvoiceBuilderScreen(onBack: _closeBuilder);
    }

    final invoicesState = ref.watch(invoicesListProvider);
    final invoices = invoicesState.invoices;

    // Derived metric aggregations
    double collectedAmount = 0.0;
    double pendingAmount = 0.0;
    double overdueAmount = 0.0;
    int pendingCount = 0;
    int overdueCount = 0;

    for (final inv in invoices) {
      if (inv.isPaid) {
        collectedAmount += inv.totalAmount;
      } else if (inv.isOverdue) {
        overdueAmount += inv.totalAmount;
        overdueCount++;
      } else if (inv.isSent || inv.isDraft) {
        pendingAmount += inv.totalAmount;
        pendingCount++;
      }
    }

    return AppPage(
      title: 'Invoices & Billing',
      subtitle:
          'Manage client billing records, tax reconciliation, automated receipts, and payments.',
      trailing: ElevatedButton.icon(
        key: const Key('create_invoice_button'),
        onPressed: _openBuilder,
        icon: const Icon(Icons.receipt_long_rounded, size: 16),
        label: const Text('Create Invoice'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Financial Summary Strip
          if (AppBreakpoints.isMobile(context))
            Column(
              children: [
                _BillingStatCard(
                  label: 'COLLECTED THIS MONTH',
                  amount: FinancialCalculator.formatCurrency(collectedAmount, 'USD'),
                  change: '${invoices.where((i) => i.isPaid).length} paid invoices',
                  indicatorColor: AppColors.success,
                ),
                const SizedBox(height: 12),
                _BillingStatCard(
                  label: 'PENDING DISPATCH',
                  amount: FinancialCalculator.formatCurrency(pendingAmount, 'USD'),
                  change: '$pendingCount invoices queued',
                  indicatorColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _BillingStatCard(
                  label: 'OVERDUE RECEIVABLES',
                  amount: FinancialCalculator.formatCurrency(overdueAmount, 'USD'),
                  change: '$overdueCount accounts past due',
                  indicatorColor: AppColors.warning,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _BillingStatCard(
                    label: 'COLLECTED THIS MONTH',
                    amount: FinancialCalculator.formatCurrency(collectedAmount, 'USD'),
                    change: '${invoices.where((i) => i.isPaid).length} paid invoices',
                    indicatorColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BillingStatCard(
                    label: 'PENDING DISPATCH',
                    amount: FinancialCalculator.formatCurrency(pendingAmount, 'USD'),
                    change: '$pendingCount invoices queued',
                    indicatorColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BillingStatCard(
                    label: 'OVERDUE RECEIVABLES',
                    amount: FinancialCalculator.formatCurrency(overdueAmount, 'USD'),
                    change: '$overdueCount accounts past due',
                    indicatorColor: AppColors.warning,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Invoices & Transactions (${invoices.length})',
                style: AppTypography.sectionTitle,
              ),
              if (invoicesState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (invoices.isEmpty && !invoicesState.isLoading)
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_outlined, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'No invoices created yet',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Click "Create Invoice" above to draft your first invoice.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...invoices.map((inv) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InvoiceRow(
                  key: Key('invoice_row_${inv.id}'),
                  invoice: inv,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _BillingStatCard extends StatelessWidget {
  final String label;
  final String amount;
  final String change;
  final Color indicatorColor;

  const _BillingStatCard({
    required this.label,
    required this.amount,
    required this.change,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(color: indicatorColor),
          ),
          const SizedBox(height: 8),
          Text(amount, style: AppTypography.metricSmall),
          const SizedBox(height: 4),
          Text(change, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceRow({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = invoice.statusColor;
    final date =
        '${invoice.issueDate.year}-${invoice.issueDate.month.toString().padLeft(2, '0')}-${invoice.issueDate.day.toString().padLeft(2, '0')}';
    final amount = FinancialCalculator.formatCurrency(
        invoice.totalAmount, invoice.currency);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 680),
          child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: AppTypography.title.copyWith(fontSize: 15),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        invoice.customerDisplay,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Issued: $date  •  Direct ACH transfer',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amount, style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              invoice.statusDisplayName.toUpperCase(),
              style: AppTypography.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!invoice.isPaid) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              key: Key('record_payment_button_${invoice.invoiceNumber}'),
              onPressed: () => RecordPaymentDialog.show(context, invoice),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.payments_outlined, size: 14),
              label: const Text('Record Payment', style: TextStyle(fontSize: 12)),
            ),
          ],
          const SizedBox(width: 6),
          IconButton(
            key: Key('preview_pdf_${invoice.invoiceNumber}'),
            tooltip: 'Preview PDF',
            icon: const Icon(
              Icons.visibility_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            onPressed: () => InvoicePdfService.previewInvoicePdf(
              context: context,
              invoice: invoice,
            ),
          ),
          IconButton(
            key: Key('download_pdf_${invoice.invoiceNumber}'),
            tooltip: 'Download PDF',
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            onPressed: () => InvoicePdfService.downloadInvoicePdf(
              context: context,
              invoice: invoice,
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
