import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_line_item.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../../domain/utils/financial_calculator.dart';

/// Supabase implementation of InvoicesRepository.
class SupabaseInvoicesRepository implements InvoicesRepository {
  final SupabaseClient _client;

  SupabaseInvoicesRepository(this._client);

  @override
  Future<List<Invoice>> getInvoices({String? status, String? customerId}) async {
    var query = _client.from('invoices').select('''
      *,
      customers (
        name,
        company_name
      ),
      invoice_items (
        id,
        invoice_id,
        description,
        quantity,
        unit_price,
        amount
      )
    ''');

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      query = query.eq('status', status.toLowerCase());
    }
    if (customerId != null && customerId.isNotEmpty && customerId.toLowerCase() != 'all') {
      query = query.eq('customer_id', customerId);
    }

    final response = await query.order('created_at', ascending: false);
    final list = (response as List).cast<Map<String, dynamic>>();

    return list.map((json) {
      final rawItems = json['invoice_items'] as List? ?? [];
      final items = rawItems
          .map((i) => InvoiceLineItem.fromJson(i as Map<String, dynamic>))
          .toList();
      return Invoice.fromJson(json, items: items);
    }).toList();
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    final response = await _client.from('invoices').select('''
      *,
      customers (
        name,
        company_name
      ),
      invoice_items (
        id,
        invoice_id,
        description,
        quantity,
        unit_price,
        amount
      )
    ''').eq('id', id).maybeSingle();

    if (response == null) return null;
    final json = response;
    final rawItems = json['invoice_items'] as List? ?? [];
    final items = rawItems
        .map((i) => InvoiceLineItem.fromJson(i as Map<String, dynamic>))
        .toList();
    return Invoice.fromJson(json, items: items);
  }

  @override
  Future<String> generateNextInvoiceNumber(String organizationId) async {
    try {
      final res = await _client.rpc(
        'generate_next_invoice_number',
        params: {'p_org_id': organizationId},
      );
      if (res != null && res.toString().trim().isNotEmpty) {
        return res.toString().trim();
      }
    } catch (e) {
      debugPrint('generate_next_invoice_number RPC failed, falling back to local sequential: $e');
    }

    // Fallback: Query highest number for current year
    final year = DateTime.now().year;
    final prefix = 'INV-$year-';
    final rows = await _client
        .from('invoices')
        .select('invoice_number')
        .eq('organization_id', organizationId)
        .like('invoice_number', '$prefix%');

    int maxSeq = 0;
    for (final row in rows as List) {
      final numStr = row['invoice_number'] as String? ?? '';
      if (numStr.startsWith(prefix)) {
        final seq = int.tryParse(numStr.substring(prefix.length)) ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      }
    }
    return '$prefix${(maxSeq + 1).toString().padLeft(4, '0')}';
  }

  @override
  Future<Invoice> createInvoice({
    required Invoice invoice,
    required List<InvoiceLineItem> items,
  }) async {
    // 1. Compute exact monetary values
    final subtotal = FinancialCalculator.calculateSubtotal(items);
    final taxAmount = FinancialCalculator.calculateTaxAmount(subtotal, invoice.taxRate);
    final totalAmount = FinancialCalculator.calculateGrandTotal(subtotal, taxAmount);

    final payload = {
      'organization_id': invoice.organizationId,
      'customer_id': invoice.customerId,
      'invoice_number': invoice.invoiceNumber,
      'issue_date': '${invoice.issueDate.year}-${invoice.issueDate.month.toString().padLeft(2, '0')}-${invoice.issueDate.day.toString().padLeft(2, '0')}',
      'due_date': '${invoice.dueDate.year}-${invoice.dueDate.month.toString().padLeft(2, '0')}-${invoice.dueDate.day.toString().padLeft(2, '0')}',
      'status': invoice.status,
      'subtotal': subtotal,
      'tax_rate': invoice.taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      if (invoice.notes != null && invoice.notes!.isNotEmpty) 'notes': invoice.notes,
    };

    final inserted = await _client
        .from('invoices')
        .insert(payload)
        .select('''
          *,
          customers (
            name,
            company_name
          )
        ''')
        .single();

    final invoiceId = inserted['id'] as String;

    // 2. Insert line items
    final itemPayloads = items.map((item) {
      final lineAmount = FinancialCalculator.calculateLineTotal(item.quantity, item.unitPrice);
      return {
        'invoice_id': invoiceId,
        'description': item.description,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'amount': lineAmount,
      };
    }).toList();

    List<InvoiceLineItem> savedItems = [];
    if (itemPayloads.isNotEmpty) {
      final insertedItems = await _client
          .from('invoice_items')
          .insert(itemPayloads)
          .select();
      savedItems = (insertedItems as List)
          .map((i) => InvoiceLineItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return Invoice.fromJson(inserted, items: savedItems);
  }

  @override
  Future<Invoice> updateInvoice({
    required Invoice invoice,
    required List<InvoiceLineItem> items,
  }) async {
    final subtotal = FinancialCalculator.calculateSubtotal(items);
    final taxAmount = FinancialCalculator.calculateTaxAmount(subtotal, invoice.taxRate);
    final totalAmount = FinancialCalculator.calculateGrandTotal(subtotal, taxAmount);

    final payload = {
      'customer_id': invoice.customerId,
      'issue_date': '${invoice.issueDate.year}-${invoice.issueDate.month.toString().padLeft(2, '0')}-${invoice.issueDate.day.toString().padLeft(2, '0')}',
      'due_date': '${invoice.dueDate.year}-${invoice.dueDate.month.toString().padLeft(2, '0')}-${invoice.dueDate.day.toString().padLeft(2, '0')}',
      'status': invoice.status,
      'subtotal': subtotal,
      'tax_rate': invoice.taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': invoice.notes,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final updated = await _client
        .from('invoices')
        .update(payload)
        .eq('id', invoice.id)
        .select('''
          *,
          customers (
            name,
            company_name
          )
        ''')
        .single();

    // Replace items: Delete existing and insert new
    await _client.from('invoice_items').delete().eq('invoice_id', invoice.id);

    final itemPayloads = items.map((item) {
      final lineAmount = FinancialCalculator.calculateLineTotal(item.quantity, item.unitPrice);
      return {
        'invoice_id': invoice.id,
        'description': item.description,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'amount': lineAmount,
      };
    }).toList();

    List<InvoiceLineItem> savedItems = [];
    if (itemPayloads.isNotEmpty) {
      final insertedItems = await _client
          .from('invoice_items')
          .insert(itemPayloads)
          .select();
      savedItems = (insertedItems as List)
          .map((i) => InvoiceLineItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return Invoice.fromJson(updated, items: savedItems);
  }

  @override
  Future<Invoice> finalizeInvoice(String invoiceId) async {
    final updated = await _client
        .from('invoices')
        .update({
          'status': 'sent',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', invoiceId)
        .select('''
          *,
          customers (
            name,
            company_name
          ),
          invoice_items (
            id,
            invoice_id,
            description,
            quantity,
            unit_price,
            amount
          )
        ''')
        .single();

    final rawItems = updated['invoice_items'] as List? ?? [];
    final items = rawItems
        .map((i) => InvoiceLineItem.fromJson(i as Map<String, dynamic>))
        .toList();
    return Invoice.fromJson(updated, items: items);
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
    final date = paymentDate ?? DateTime.now();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      await _client.rpc('record_payment', params: {
        'p_invoice_id': invoiceId,
        'p_amount': amount,
        'p_payment_method': paymentMethod,
        'p_payment_date': dateStr,
        if (referenceNo != null && referenceNo.isNotEmpty)
          'p_reference_no': referenceNo,
        if (notes != null && notes.isNotEmpty) 'p_notes': notes,
      });
    } catch (e) {
      debugPrint('record_payment RPC failed, executing direct fallback: $e');
      final invoice = await getInvoiceById(invoiceId);
      if (invoice == null) {
        throw Exception('Invoice $invoiceId not found');
      }

      await _client.from('payments').insert({
        'organization_id': invoice.organizationId,
        'invoice_id': invoiceId,
        'amount': amount,
        'payment_method': paymentMethod.toLowerCase(),
        'payment_date': dateStr,
        if (referenceNo != null && referenceNo.isNotEmpty)
          'reference_no': referenceNo,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      await _client.from('invoices').update({
        'status': 'paid',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', invoiceId);
    }

    final updatedInvoice = await getInvoiceById(invoiceId);
    if (updatedInvoice == null) {
      throw Exception('Failed to reload invoice after recording payment');
    }
    return updatedInvoice;
  }
}
