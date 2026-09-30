import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/services/pdf_invoice_engine.dart';

/// Presentation service providing seamless UI integration for previewing,
/// printing, and downloading vector PDF invoices.
class InvoicePdfService {
  static const PdfInvoiceEngine _engine = PdfInvoiceEngine();

  /// Opens the system print/PDF preview dialog.
  static Future<void> previewInvoicePdf({
    required BuildContext context,
    required Invoice invoice,
    Customer? customer,
  }) async {
    try {
      await Printing.layoutPdf(
        name: invoice.invoiceNumber,
        onLayout: (format) async {
          return await _engine.generateInvoicePdf(
            invoice: invoice,
            customer: customer,
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to preview PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Downloads or shares the generated vector PDF file.
  static Future<void> downloadInvoicePdf({
    required BuildContext context,
    required Invoice invoice,
    Customer? customer,
  }) async {
    try {
      final bytes = await _engine.generateInvoicePdf(
        invoice: invoice,
        customer: customer,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: '${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
