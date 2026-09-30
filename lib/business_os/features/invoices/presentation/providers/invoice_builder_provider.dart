import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import 'invoices_provider.dart';

/// Mutable draft representation of an individual line item in the builder.
@immutable
class LineItemDraft {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;

  const LineItemDraft({
    required this.id,
    this.description = '',
    this.quantity = 1.0,
    this.unitPrice = 0.0,
  });

  double get lineTotal => FinancialCalculator.calculateLineTotal(quantity, unitPrice);

  LineItemDraft copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
  }) {
    return LineItemDraft(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  InvoiceLineItem toDomain({String? invoiceId}) {
    return InvoiceLineItem(
      id: id,
      invoiceId: invoiceId,
      description: description.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      amount: lineTotal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineItemDraft &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          description == other.description &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice;

  @override
  int get hashCode =>
      id.hashCode ^
      description.hashCode ^
      quantity.hashCode ^
      unitPrice.hashCode;
}

/// State holding all active inputs, live financial calculations, and submission status.
@immutable
class InvoiceBuilderState {
  final String? existingInvoiceId;
  final String? selectedCustomerId;
  final DateTime issueDate;
  final DateTime dueDate;
  final String currency;
  final List<LineItemDraft> lineItems;
  final double taxRate; // Allowed: 0, 5, 12, 18, 28
  final String? notes;
  final bool isSubmitting;
  final String? submissionType; // 'draft' | 'finalize' | null
  final String? error;
  final bool isSuccess;
  final Invoice? savedInvoice;

  const InvoiceBuilderState({
    this.existingInvoiceId,
    this.selectedCustomerId,
    required this.issueDate,
    required this.dueDate,
    this.currency = 'USD',
    required this.lineItems,
    this.taxRate = 18.0,
    this.notes,
    this.isSubmitting = false,
    this.submissionType,
    this.error,
    this.isSuccess = false,
    this.savedInvoice,
  });

  /// Factory for clean initial state with 1 default blank line item.
  factory InvoiceBuilderState.initial({String defaultCurrency = 'USD'}) {
    final now = DateTime.now();
    return InvoiceBuilderState(
      issueDate: now,
      dueDate: now.add(const Duration(days: 14)),
      currency: defaultCurrency,
      lineItems: [
        LineItemDraft(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}_0',
          description: '',
          quantity: 1.0,
          unitPrice: 0.0,
        ),
      ],
      taxRate: 18.0,
    );
  }

  /// Factory to populate builder from an existing draft invoice.
  factory InvoiceBuilderState.fromInvoice(Invoice invoice) {
    final drafts = invoice.items.map((i) {
      return LineItemDraft(
        id: i.id,
        description: i.description,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
      );
    }).toList();

    return InvoiceBuilderState(
      existingInvoiceId: invoice.id,
      selectedCustomerId: invoice.customerId,
      issueDate: invoice.issueDate,
      dueDate: invoice.dueDate,
      currency: invoice.currency,
      lineItems: drafts.isNotEmpty
          ? drafts
          : [
              LineItemDraft(
                id: 'item_${DateTime.now().millisecondsSinceEpoch}_0',
                description: '',
                quantity: 1.0,
                unitPrice: 0.0,
              ),
            ],
      taxRate: invoice.taxRate,
      notes: invoice.notes,
    );
  }

  // Live financial calculations
  double get subtotal {
    double sum = 0.0;
    for (final item in lineItems) {
      sum += item.lineTotal;
    }
    return FinancialCalculator.roundMoney(sum);
  }

  double get taxAmount => FinancialCalculator.calculateTaxAmount(subtotal, taxRate);

  double get grandTotal => FinancialCalculator.calculateGrandTotal(subtotal, taxAmount);

  InvoiceBuilderState copyWith({
    String? existingInvoiceId,
    String? selectedCustomerId,
    DateTime? issueDate,
    DateTime? dueDate,
    String? currency,
    List<LineItemDraft>? lineItems,
    double? taxRate,
    String? notes,
    bool? isSubmitting,
    String? submissionType,
    String? error,
    bool? isSuccess,
    Invoice? savedInvoice,
  }) {
    return InvoiceBuilderState(
      existingInvoiceId: existingInvoiceId ?? this.existingInvoiceId,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      currency: currency ?? this.currency,
      lineItems: lineItems ?? this.lineItems,
      taxRate: taxRate ?? this.taxRate,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionType: submissionType ?? this.submissionType,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      savedInvoice: savedInvoice ?? this.savedInvoice,
    );
  }
}

/// StateNotifier orchestrating invoice drafting, dynamic item modifications, and persistence.
class InvoiceBuilderNotifier extends StateNotifier<InvoiceBuilderState> {
  final InvoicesRepository _repository;
  final Ref _ref;

  InvoiceBuilderNotifier(this._repository, this._ref)
      : super(InvoiceBuilderState.initial(
          defaultCurrency: _resolveInitialCurrency(_ref),
        ));

  static String _resolveInitialCurrency(Ref ref) {
    try {
      final org = ref.read(currentOrganizationProvider);
      return org?.currency ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  void initializeForInvoice(Invoice invoice) {
    state = InvoiceBuilderState.fromInvoice(invoice);
  }

  void setCustomer(String customerId) {
    state = state.copyWith(selectedCustomerId: customerId, error: null);
  }

  void setIssueDate(DateTime date) {
    final cleanIssue = DateTime(date.year, date.month, date.day);
    state = state.copyWith(issueDate: cleanIssue, error: null);
  }

  void setDueDate(DateTime date) {
    final cleanDue = DateTime(date.year, date.month, date.day);
    state = state.copyWith(dueDate: cleanDue, error: null);
  }

  void setCurrency(String code) {
    state = state.copyWith(currency: code);
  }

  void setTaxRate(double rate) {
    // Only accept allowed standard rates
    if (FinancialCalculator.allowedTaxRates.contains(rate)) {
      state = state.copyWith(taxRate: rate);
    }
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void addLineItem() {
    final newItem = LineItemDraft(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}_${state.lineItems.length}',
      description: '',
      quantity: 1.0,
      unitPrice: 0.0,
    );
    state = state.copyWith(
      lineItems: [...state.lineItems, newItem],
      error: null,
    );
  }

  void updateLineItem(
    int index, {
    String? description,
    double? quantity,
    double? unitPrice,
  }) {
    if (index < 0 || index >= state.lineItems.length) return;
    final items = List<LineItemDraft>.from(state.lineItems);
    items[index] = items[index].copyWith(
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    state = state.copyWith(lineItems: items, error: null);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.lineItems.length) return;
    final items = List<LineItemDraft>.from(state.lineItems);
    items.removeAt(index);
    // If user removes the last row, leave 1 blank row to maintain builder ergonomics
    if (items.isEmpty) {
      items.add(LineItemDraft(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}_0',
        description: '',
        quantity: 1.0,
        unitPrice: 0.0,
      ));
    }
    state = state.copyWith(lineItems: items, error: null);
  }

  /// Validates builder fields for Draft or Finalize.
  List<String> validate({required bool isFinalize}) {
    final errors = <String>[];

    if (state.selectedCustomerId == null || state.selectedCustomerId!.trim().isEmpty) {
      errors.add('Please select a customer for this invoice.');
    }

    final cleanIssue = DateTime(state.issueDate.year, state.issueDate.month, state.issueDate.day);
    final cleanDue = DateTime(state.dueDate.year, state.dueDate.month, state.dueDate.day);
    if (cleanDue.isBefore(cleanIssue)) {
      errors.add('Due date cannot be earlier than issue date.');
    }

    if (state.lineItems.isEmpty) {
      errors.add('Invoice must contain at least one line item.');
    } else {
      for (int i = 0; i < state.lineItems.length; i++) {
        final item = state.lineItems[i];
        if (item.description.trim().isEmpty) {
          errors.add('Line item #${i + 1} requires a description.');
        }
        if (item.quantity <= 0) {
          errors.add('Line item #${i + 1} quantity must be greater than 0.');
        }
        if (item.unitPrice < 0) {
          errors.add('Line item #${i + 1} unit price cannot be negative.');
        }
      }
    }

    return errors;
  }

  /// Persists invoice as a draft.
  Future<Invoice?> saveDraft() async {
    return _submit(isFinalize: false);
  }

  /// Finalizes and commits the invoice with status 'sent'.
  Future<Invoice?> finalizeInvoice() async {
    return _submit(isFinalize: true);
  }

  Future<Invoice?> _submit({required bool isFinalize}) async {
    // Duplicate submission guard
    if (state.isSubmitting) return null;

    final validationErrors = validate(isFinalize: isFinalize);
    if (validationErrors.isNotEmpty) {
      state = state.copyWith(error: validationErrors.first);
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      submissionType: isFinalize ? 'finalize' : 'draft',
      error: null,
      isSuccess: false,
    );

    try {
      final org = _ref.read(currentOrganizationProvider);
      final orgId = org?.id ?? 'org_dev_001';
      final listNotifier = _ref.read(invoicesListProvider.notifier);

      // 1. Generate or preserve invoice number
      String invoiceNum;
      if (state.existingInvoiceId != null && state.savedInvoice != null) {
        invoiceNum = state.savedInvoice!.invoiceNumber;
      } else {
        invoiceNum = await _repository.generateNextInvoiceNumber(orgId);
      }

      final domainItems = state.lineItems.map((d) => d.toDomain()).toList();
      final subtotal = state.subtotal;
      final taxAmount = state.taxAmount;
      final totalAmount = state.grandTotal;

      final invoiceToSave = Invoice(
        id: state.existingInvoiceId ?? '',
        organizationId: orgId,
        customerId: state.selectedCustomerId!,
        invoiceNumber: invoiceNum,
        issueDate: state.issueDate,
        dueDate: state.dueDate,
        status: isFinalize ? 'sent' : 'draft',
        currency: state.currency,
        subtotal: subtotal,
        taxRate: state.taxRate,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        notes: state.notes?.trim().isNotEmpty == true ? state.notes!.trim() : null,
        items: domainItems,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = state.existingInvoiceId != null
          ? await _repository.updateInvoice(invoice: invoiceToSave, items: domainItems)
          : await _repository.createInvoice(invoice: invoiceToSave, items: domainItems);

      // Update parent invoices list
      listNotifier.addOrUpdateInvoice(saved);

      if (!mounted) return saved;

      state = state.copyWith(
        isSubmitting: false,
        submissionType: null,
        isSuccess: true,
        savedInvoice: saved,
        existingInvoiceId: saved.id,
      );

      return saved;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        submissionType: null,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  void reset() {
    state = InvoiceBuilderState.initial(
      defaultCurrency: _resolveInitialCurrency(_ref),
    );
  }
}

final invoiceBuilderProvider =
    StateNotifierProvider.autoDispose<InvoiceBuilderNotifier, InvoiceBuilderState>((ref) {
  final repository = ref.watch(invoicesRepositoryProvider);
  return InvoiceBuilderNotifier(repository, ref);
});
