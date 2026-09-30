import '../entities/invoice.dart';
import '../entities/invoice_line_item.dart';

/// Repository interface governing invoice persistence, numbering, and status transitions.
abstract class InvoicesRepository {
  /// Fetches all organization invoices, optionally filtered by status or customer.
  Future<List<Invoice>> getInvoices({String? status, String? customerId});

  /// Fetches an individual invoice with all its line items.
  Future<Invoice?> getInvoiceById(String id);

  /// Generates the next sequential invoice number for the given organization (e.g. INV-2026-0001).
  Future<String> generateNextInvoiceNumber(String organizationId);

  /// Creates a new invoice (draft or sent) along with its line items.
  Future<Invoice> createInvoice({
    required Invoice invoice,
    required List<InvoiceLineItem> items,
  });

  /// Updates an existing draft invoice and replaces its line items.
  Future<Invoice> updateInvoice({
    required Invoice invoice,
    required List<InvoiceLineItem> items,
  });

  /// Finalizes an invoice by transitioning status from 'draft' to 'sent'.
  Future<Invoice> finalizeInvoice(String invoiceId);

  /// Records a verified payment against an invoice via backend RPC.
  Future<Invoice> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? referenceNo,
    String? notes,
  });
}
