import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/invoices_provider.dart';

/// Modal dialog allowing operators to record a verified payment against an invoice.
class RecordPaymentDialog extends ConsumerStatefulWidget {
  final Invoice invoice;

  const RecordPaymentDialog({
    super.key,
    required this.invoice,
  });

  static Future<Invoice?> show(BuildContext context, Invoice invoice) {
    return showDialog<Invoice>(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (context) => RecordPaymentDialog(invoice: invoice),
    );
  }

  @override
  ConsumerState<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  late PaymentMethod _selectedMethod;
  late DateTime _paymentDate;
  bool _confirmed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedMethod = PaymentMethod.bankTransfer;
    _paymentDate = DateTime.now();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (widget.invoice.isPaid) {
      setState(() {
        _errorMessage = 'This invoice has already been fully paid.';
      });
      return;
    }

    if (!_confirmed) {
      setState(() {
        _errorMessage = 'Please confirm that the payment has been received and verified.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final updated = await ref.read(invoicesListProvider.notifier).recordPayment(
            invoiceId: widget.invoice.id,
            amount: widget.invoice.totalAmount,
            paymentMethod: _selectedMethod.value,
            paymentDate: _paymentDate,
            referenceNo: _referenceController.text.trim().isNotEmpty
                ? _referenceController.text.trim()
                : null,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pop(updated);

      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Payment of ${FinancialCalculator.formatCurrency(widget.invoice.totalAmount, widget.invoice.currency)} recorded for ${widget.invoice.invoiceNumber}',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final formattedAmount =
        FinancialCalculator.formatCurrency(invoice.totalAmount, invoice.currency);
    final isAlreadyPaid = invoice.isPaid;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.payments_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Record Payment',
                                      style: AppTypography.title,
                                    ),
                                    Text(
                                      invoice.invoiceNumber,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const Key('close_record_payment_dialog'),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Error banner
                    if (_errorMessage != null) ...[
                      Container(
                        key: const Key('record_payment_error_banner'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.caption.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Invoice Summary Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Customer', style: AppTypography.caption),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  invoice.customerDisplay,
                                  style: AppTypography.bodySmall.copyWith(
                                     fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Current Status', style: AppTypography.caption),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: invoice.statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  invoice.statusDisplayName.toUpperCase(),
                                  style: AppTypography.caption.copyWith(
                                    color: invoice.statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 16, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Payable Amount', style: AppTypography.bodyMedium),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  formattedAmount,
                                  style: AppTypography.title.copyWith(
                                    color: AppColors.success,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isAlreadyPaid) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This invoice is already fully paid. No further payments can be recorded.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ] else ...[
                      // Payment Method Selector
                      Text('Payment Method *', style: AppTypography.label),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<PaymentMethod>(
                        key: const Key('payment_method_dropdown'),
                        isExpanded: true,
                        initialValue: _selectedMethod,
                        dropdownColor: AppColors.surfaceElevated,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                        ),
                        items: PaymentMethod.values.map((method) {
                          return DropdownMenuItem<PaymentMethod>(
                            value: method,
                            child: Text(method.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMethod = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Reference Number
                      Text('Transaction Reference / UTR #', style: AppTypography.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const Key('payment_reference_input'),
                        controller: _referenceController,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'e.g. WIRE-849204 or CHQ-001239',
                          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      const SizedBox(height: 14),

                      // Transaction Notes
                      Text('Notes (Optional)', style: AppTypography.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const Key('payment_notes_input'),
                        controller: _notesController,
                        maxLines: 2,
                        maxLength: 500,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Add audit remarks or receipt details...',
                          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      const SizedBox(height: 10),

                      // Explicit Confirmation Checkbox
                      InkWell(
                        key: const Key('payment_confirmation_checkbox_tile'),
                        onTap: () {
                          setState(() {
                            _confirmed = !_confirmed;
                            if (_confirmed) _errorMessage = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: _confirmed
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _confirmed ? AppColors.success : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                key: const Key('payment_confirmation_checkbox'),
                                value: _confirmed,
                                activeColor: AppColors.success,
                                onChanged: (val) {
                                  setState(() {
                                    _confirmed = val ?? false;
                                    if (_confirmed) _errorMessage = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'I confirm that payment of $formattedAmount has been received and verified.',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: _confirmed ? FontWeight.w600 : FontWeight.normal,
                                    color: _confirmed ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          OutlinedButton(
                            key: const Key('cancel_record_payment_button'),
                            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            key: const Key('submit_record_payment_button'),
                            onPressed: (_isSubmitting || !_confirmed) ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded, size: 16),
                                        SizedBox(width: 8),
                                        Text('Confirm & Record Payment'),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
