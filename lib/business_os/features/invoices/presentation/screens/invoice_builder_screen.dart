import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/domain/entities/organization.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../domain/entities/invoice.dart';
import '../providers/invoice_builder_provider.dart';
import '../services/invoice_pdf_service.dart';
import '../widgets/customer_selector_dropdown.dart';
import '../widgets/invoice_line_item_row.dart';
import '../widgets/live_totals_panel.dart';
import '../widgets/tax_selector_widget.dart';

/// Full production-grade Invoice Builder Screen for VALIXIS BUSINESS OS.
class InvoiceBuilderScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const InvoiceBuilderScreen({super.key, this.onBack});

  @override
  ConsumerState<InvoiceBuilderScreen> createState() => _InvoiceBuilderScreenState();
}

class _InvoiceBuilderScreenState extends ConsumerState<InvoiceBuilderScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSaveDraft() async {
    final notifier = ref.read(invoiceBuilderProvider.notifier);
    notifier.setNotes(_notesController.text);
    final saved = await notifier.saveDraft();
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Draft ${saved.invoiceNumber} saved successfully',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleFinalize() async {
    final notifier = ref.read(invoiceBuilderProvider.notifier);
    notifier.setNotes(_notesController.text);
    final saved = await notifier.finalizeInvoice();
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice ${saved.invoiceNumber} finalized and dispatched',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      if (widget.onBack != null) {
        widget.onBack!();
      }
    }
  }

  Future<void> _handlePreviewPdf() async {
    final state = ref.read(invoiceBuilderProvider);
    Customer? selectedCustomer;
    if (state.selectedCustomerId != null) {
      final customersState = ref.read(customersProvider);
      for (final c in customersState.customers) {
        if (c.id == state.selectedCustomerId) {
          selectedCustomer = c;
          break;
        }
      }
    }

    final invoice = Invoice(
      id: state.existingInvoiceId ?? 'preview-draft',
      organizationId: 'org-current',
      customerId: state.selectedCustomerId ?? 'unknown',
      invoiceNumber: state.existingInvoiceId != null
          ? (state.savedInvoice?.invoiceNumber ?? 'INV-PREVIEW')
          : 'INV-DRAFT-PREVIEW',
      issueDate: state.issueDate,
      dueDate: state.dueDate,
      status: 'draft',
      currency: state.currency,
      subtotal: state.subtotal,
      taxRate: state.taxRate,
      taxAmount: state.taxAmount,
      totalAmount: state.grandTotal,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      customerName: selectedCustomer?.name,
      customerCompany: selectedCustomer?.companyName,
      items: state.lineItems.map((item) => item.toDomain()).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await InvoicePdfService.previewInvoicePdf(
      context: context,
      invoice: invoice,
      customer: selectedCustomer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceBuilderProvider);
    final notifier = ref.read(invoiceBuilderProvider.notifier);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isMobile = AppBreakpoints.isMobile(context);

    final error = state.error;

    return AppPage(
      title: 'Invoice Builder',
      subtitle: 'Draft corporate invoices, configure itemized billing, and calculate taxes in real-time.',
      trailing: widget.onBack != null
          ? OutlinedButton.icon(
              key: const Key('back_to_invoices_button'),
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Invoices'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Validation / Backend Error Banner
          if (error != null) ...[
            Container(
              key: const Key('builder_error_banner'),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Details & Dynamic Line Items (flex 7)
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderCard(context, state, notifier, isMobile),
                      const SizedBox(height: 18),
                      _buildLineItemsSection(context, state, notifier, isMobile),
                      const SizedBox(height: 18),
                      _buildNotesSection(isMobile),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right Column: Tax, Live Totals & Action Buttons (flex 4)
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: TaxSelectorWidget(
                          selectedTaxRate: state.taxRate,
                          onTaxRateSelected: notifier.setTaxRate,
                        ),
                      ),
                      const SizedBox(height: 18),
                      LiveTotalsPanel(
                        subtotal: state.subtotal,
                        taxRate: state.taxRate,
                        taxAmount: state.taxAmount,
                        grandTotal: state.grandTotal,
                        currency: state.currency,
                      ),
                      const SizedBox(height: 20),
                      _buildActionButtons(state),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            // Stacked Tablet / Mobile Layout
            _buildHeaderCard(context, state, notifier, isMobile),
            const SizedBox(height: 18),
            _buildLineItemsSection(context, state, notifier, isMobile),
            const SizedBox(height: 18),
            GlassContainer(
              padding: const EdgeInsets.all(18),
              child: TaxSelectorWidget(
                selectedTaxRate: state.taxRate,
                onTaxRateSelected: notifier.setTaxRate,
              ),
            ),
            const SizedBox(height: 18),
            LiveTotalsPanel(
              subtotal: state.subtotal,
              taxRate: state.taxRate,
              taxAmount: state.taxAmount,
              grandTotal: state.grandTotal,
              currency: state.currency,
            ),
            const SizedBox(height: 18),
            _buildNotesSection(isMobile),
            const SizedBox(height: 20),
            _buildActionButtons(state),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    InvoiceBuilderState state,
    InvoiceBuilderNotifier notifier,
    bool isMobile,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Invoice Header & Recipient',
                  style: AppTypography.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Customer Selector
          CustomerSelectorDropdown(
            selectedCustomerId: state.selectedCustomerId,
            onCustomerSelected: notifier.setCustomer,
          ),
          const SizedBox(height: 16),

          // Dates and Currency
          if (isMobile) ...[
            _buildDatePickerField(
              key: const Key('issue_date_picker'),
              label: 'Issue Date *',
              value: _formatDate(state.issueDate),
              onTap: () => _pickDate(
                context: context,
                initialDate: state.issueDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                onPicked: notifier.setIssueDate,
              ),
            ),
            const SizedBox(height: 12),
            _buildDatePickerField(
              key: const Key('due_date_picker'),
              label: 'Due Date *',
              value: _formatDate(state.dueDate),
              onTap: () => _pickDate(
                context: context,
                initialDate: state.dueDate,
                firstDate: state.issueDate,
                onPicked: notifier.setDueDate,
              ),
            ),
            const SizedBox(height: 12),
            _buildCurrencyDropdown(state, notifier),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerField(
                    key: const Key('issue_date_picker'),
                    label: 'Issue Date *',
                    value: _formatDate(state.issueDate),
                    onTap: () => _pickDate(
                      context: context,
                      initialDate: state.issueDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                      onPicked: notifier.setIssueDate,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildDatePickerField(
                    key: const Key('due_date_picker'),
                    label: 'Due Date *',
                    value: _formatDate(state.dueDate),
                    onTap: () => _pickDate(
                      context: context,
                      initialDate: state.dueDate,
                      firstDate: state.issueDate,
                      onPicked: notifier.setDueDate,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildCurrencyDropdown(state, notifier),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required Key key,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(InvoiceBuilderState state, InvoiceBuilderNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency *',
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('currency_selector'),
              value: state.currency,
              isExpanded: true,
              dropdownColor: AppColors.surfaceElevated,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
              items: AppCurrency.supportedCurrencies.map((c) {
                return DropdownMenuItem<String>(
                  key: Key('currency_option_${c.code}'),
                  value: c.code,
                  child: Text('${c.code} - ${c.name} (${c.symbol})', overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (code) {
                if (code != null) {
                  notifier.setCurrency(code);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineItemsSection(
    BuildContext context,
    InvoiceBuilderState state,
    InvoiceBuilderNotifier notifier,
    bool isMobile,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.view_list_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Line Items (${state.lineItems.length})',
                        style: AppTypography.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key('add_line_item_button'),
                onPressed: notifier.addLineItem,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header Labels (for non-mobile)
          if (!isMobile) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 36, right: 40),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('Description', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text('Quantity', textAlign: TextAlign.center, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text('Unit Price', textAlign: TextAlign.right, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: Text('Line Total', textAlign: TextAlign.right, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
          ],

          // Dynamic line item rows
          ...state.lineItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return InvoiceLineItemRow(
              key: ValueKey(item.id),
              index: idx,
              item: item,
              currency: state.currency,
              canRemove: state.lineItems.length > 1,
              onDescriptionChanged: (desc) => notifier.updateLineItem(idx, description: desc),
              onQuantityChanged: (qty) => notifier.updateLineItem(idx, quantity: qty),
              onUnitPriceChanged: (price) => notifier.updateLineItem(idx, unitPrice: price),
              onRemove: () => notifier.removeLineItem(idx),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isMobile) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_alt_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Notes & Payment Terms',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key('invoice_notes_field'),
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'e.g. Net 30 days. Wire transfer details: Acme Bank IBAN ...',
              contentPadding: EdgeInsets.all(12),
            ),
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(InvoiceBuilderState state) {
    final isDrafting = state.isSubmitting && state.submissionType == 'draft';
    final isFinalizing = state.isSubmitting && state.submissionType == 'finalize';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Finalize Invoice (Primary Action)
        ElevatedButton(
          key: const Key('finalize_invoice_button'),
          onPressed: state.isSubmitting ? null : _handleFinalize,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppColors.primary,
          ),
          child: isFinalizing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Finalize & Issue Invoice',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 10),

        // Save Draft (Secondary Action)
        OutlinedButton(
          key: const Key('save_draft_button'),
          onPressed: state.isSubmitting ? null : _handleSaveDraft,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          child: isDrafting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.save_outlined, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Save Draft',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 10),

        // Preview Vector PDF (Tertiary Action)
        OutlinedButton(
          key: const Key('preview_pdf_button'),
          onPressed: _handlePreviewPdf,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf_outlined, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Preview PDF Document',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
