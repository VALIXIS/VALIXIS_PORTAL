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
    final now = DateTime.now();

    // Invoice 1
    const items1 = [
      InvoiceLineItem(
        id: 'item_dev_001',
        invoiceId: 'inv_dev_001',
        description: 'Enterprise Cloud Architecture & Multi-tenant RLS Setup',
        quantity: 1.0,
        unitPrice: 15000.0,
        amount: 15000.0,
      ),
      InvoiceLineItem(
        id: 'item_dev_002',
        invoiceId: 'inv_dev_001',
        description: 'PostgreSQL Performance Indexing & Query Tuning',
        quantity: 1.0,
        unitPrice: 3500.0,
        amount: 3500.0,
      ),
    ];
    final subtotal1 = FinancialCalculator.calculateSubtotal(items1);
    final taxAmount1 = FinancialCalculator.calculateTaxAmount(subtotal1, 18.0);
    final total1 = FinancialCalculator.calculateGrandTotal(subtotal1, taxAmount1);

    final inv1 = Invoice(
      id: 'inv_dev_001',
      organizationId: 'org_dev_001',
      customerId: 'cust_dev_001', // Acme Cloud Technologies
      invoiceNumber: 'INV-${now.year}-0001',
      issueDate: now.subtract(const Duration(days: 10)),
      dueDate: now.add(const Duration(days: 20)),
      status: 'paid',
      currency: 'USD',
      subtotal: subtotal1,
      taxRate: 18.0,
      taxAmount: taxAmount1,
      totalAmount: total1,
      notes: 'Payment received via Wire Transfer.',
      customerName: 'Sarah Jenkins',
      customerCompany: 'Acme Cloud Technologies',
      items: items1,
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );
    _invoices.add(inv1);
    _itemsMap[inv1.id] = items1;

    // Invoice 2
    const items2 = [
      InvoiceLineItem(
        id: 'item_dev_003',
        invoiceId: 'inv_dev_002',
        description: 'Gemini LLM Scoring Engine Pipeline Integration',
        quantity: 2.0,
        unitPrice: 4600.0,
        amount: 9200.0,
      ),
    ];
    final subtotal2 = FinancialCalculator.calculateSubtotal(items2);
    final taxAmount2 = FinancialCalculator.calculateTaxAmount(subtotal2, 18.0);
    final total2 = FinancialCalculator.calculateGrandTotal(subtotal2, taxAmount2);

    final inv2 = Invoice(
      id: 'inv_dev_002',
      organizationId: 'org_dev_001',
      customerId: 'cust_dev_002', // Nexus Financial
      invoiceNumber: 'INV-${now.year}-0002',
      issueDate: now.subtract(const Duration(days: 5)),
      dueDate: now.add(const Duration(days: 25)),
      status: 'sent',
      currency: 'USD',
      subtotal: subtotal2,
      taxRate: 18.0,
      taxAmount: taxAmount2,
      totalAmount: total2,
      notes: 'Net 30 payment terms.',
      customerName: 'Michael Chang',
      customerCompany: 'Nexus Financial',
      items: items2,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );
    _invoices.add(inv2);
    _itemsMap[inv2.id] = items2;

    // Invoice 3 (Draft)
    const items3 = [
      InvoiceLineItem(
        id: 'item_dev_004',
        invoiceId: 'inv_dev_003',
        description: 'Global Fleet Tracking Integration Phase 1',
        quantity: 1.0,
        unitPrice: 4500.0,
        amount: 4500.0,
      ),
    ];
    final subtotal3 = FinancialCalculator.calculateSubtotal(items3);
    final taxAmount3 = FinancialCalculator.calculateTaxAmount(subtotal3, 0.0);
    final total3 = FinancialCalculator.calculateGrandTotal(subtotal3, taxAmount3);

    final inv3 = Invoice(
      id: 'inv_dev_003',
      organizationId: 'org_dev_001',
      customerId: 'cust_dev_003', // Global Logistics Ltd
      invoiceNumber: 'INV-${now.year}-0003',
      issueDate: now,
      dueDate: now.add(const Duration(days: 14)),
      status: 'draft',
      currency: 'USD',
      subtotal: subtotal3,
      taxRate: 0.0,
      taxAmount: taxAmount3,
      totalAmount: total3,
      notes: 'Initial work order estimate.',
      customerName: 'Amina Al-Mansoor',
      customerCompany: 'Global Logistics Ltd',
      items: items3,
      createdAt: now,
      updatedAt: now,
    );
    _invoices.add(inv3);
    _itemsMap[inv3.id] = items3;
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
