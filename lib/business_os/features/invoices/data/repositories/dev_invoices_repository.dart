import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_line_item.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../../domain/utils/financial_calculator.dart';

/// In-memory development repository for invoices when offline or running widget tests.
class DevInvoicesRepository implements InvoicesRepository {
  final List<Invoice> _invoices = [];
  final Map<String, List<InvoiceLineItem>> _itemsMap = {};
  final bool simulateDelay;

  DevInvoicesRepository({this.simulateDelay = true}) {
    _seedInitialInvoices();
  }

  void addInvoiceSync({required Invoice invoice, List<InvoiceLineItem> items = const []}) {
    _invoices.removeWhere((i) => i.id == invoice.id);
    _invoices.insert(0, invoice);
    _itemsMap[invoice.id] = items;
  }

  void _seedInitialInvoices() {
    // Clean empty state - invoices populated dynamically.
  }

  @override
  Future<List<Invoice>> getInvoices({String? status, String? customerId}) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 60));
    var list = List<Invoice>.from(_invoices);
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      list = list.where((i) => i.status.toLowerCase() == status.toLowerCase()).toList();
    }
    if (customerId != null && customerId.isNotEmpty && customerId.toLowerCase() != 'all') {
      list = list.where((i) => i.customerId == customerId).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 30));
    final match = _invoices.where((i) => i.id == id);
    if (match.isEmpty) return null;
    final inv = match.first;
    final items = _itemsMap[inv.id] ?? [];
    return inv.copyWith(items: items);
  }

  @override
  Future<String> generateNextInvoiceNumber(String organizationId) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 20));
    final year = DateTime.now().year;
    final prefix = 'INV-$year-';
    int maxSeq = 0;

    for (final inv in _invoices) {
      if (inv.invoiceNumber.startsWith(prefix)) {
        final seqStr = inv.invoiceNumber.substring(prefix.length);
        final seq = int.tryParse(seqStr) ?? 0;
        if (seq > maxSeq) {
          maxSeq = seq;
        }
      }
    }

    final nextSeq = maxSeq + 1;
    return '$prefix${nextSeq.toString().padLeft(4, '0')}';
  }

  @override
  Future<Invoice> createInvoice({
    required Invoice invoice,
    required List<InvoiceLineItem> items,
  }) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 100));

    // Ensure valid calculation
    final subtotal = FinancialCalculator.calculateSubtotal(items);
    final taxAmount = FinancialCalculator.calculateTaxAmount(subtotal, invoice.taxRate);
    final totalAmount = FinancialCalculator.calculateGrandTotal(subtotal, taxAmount);

    final resolvedId = invoice.id.isEmpty
        ? 'inv_dev_${DateTime.now().millisecondsSinceEpoch}'
        : invoice.id;

    final resolvedItems = items.map((item) {
      final itemId = item.id.isEmpty
          ? 'item_dev_${DateTime.now().microsecondsSinceEpoch}'
          : item.id;
      final lineAmount = FinancialCalculator.calculateLineTotal(item.quantity, item.unitPrice);
      return item.copyWith(
        id: itemId,
        invoiceId: resolvedId,
        amount: lineAmount,
      );
    }).toList();

    final createdInvoice = invoice.copyWith(
      id: resolvedId,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      items: resolvedItems,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _invoices.removeWhere((i) => i.id == resolvedId);
    _invoices.insert(0, createdInvoice);
    _itemsMap[resolvedId] = resolvedItems;

    return createdInvoice;
  }

  @override
  Future<Invoice> updateInvoice({
    required Invoice invoice,
    required List<InvoiceLineItem> items,
  }) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 100));
    return createInvoice(invoice: invoice, items: items);
  }

  @override
  Future<Invoice> finalizeInvoice(String invoiceId) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 100));
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index == -1) {
      throw Exception('Invoice $invoiceId not found');
    }

    final updated = _invoices[index].copyWith(
      status: 'sent',
      updatedAt: DateTime.now(),
    );
    _invoices[index] = updated;
    return updated;
  }

  @override
  Future<Invoice> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? referenceNo,
    String? notes,
  }) async {
    if (simulateDelay) await Future.delayed(const Duration(milliseconds: 50));
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index == -1) {
      throw Exception('Invoice $invoiceId not found');
    }

    final existing = _invoices[index];
    final updatedNotes = notes != null && notes.isNotEmpty
        ? (existing.notes != null && existing.notes!.isNotEmpty
            ? '${existing.notes}\nPayment: $notes'
            : notes)
        : existing.notes;

    final updated = existing.copyWith(
      status: 'paid',
      notes: updatedNotes,
      updatedAt: DateTime.now(),
    );
    _invoices[index] = updated;
    return updated;
  }
}
