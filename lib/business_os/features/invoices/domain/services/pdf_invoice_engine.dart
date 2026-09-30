import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../auth/domain/entities/organization.dart';
import '../../../customers/domain/entities/customer.dart';
import '../entities/invoice.dart';
import '../utils/financial_calculator.dart';

/// Metadata for rendering company/issuer information on corporate invoices.
class CompanyProfile {
  final String name;
  final String address;
  final String cityStateZip;
  final String country;
  final String email;
  final String phone;
  final String taxId;
  final String website;

  const CompanyProfile({
    this.name = 'VALIXIS Inc.',
    this.address = '100 Enterprise Way, Suite 500',
    this.cityStateZip = 'San Francisco, CA 94105',
    this.country = 'United States',
    this.email = 'billing@valixis.com',
    this.phone = '+1 (415) 800-9290',
    this.taxId = 'US-EIN-94-3829104',
    this.website = 'www.valixis.com',
  });

  factory CompanyProfile.fromOrganization(Organization? org) {
    if (org == null) return const CompanyProfile();
    return CompanyProfile(
      name: org.name.isNotEmpty ? org.name : 'VALIXIS Inc.',
      email: 'billing@${org.slug.isNotEmpty ? org.slug : 'valixis'}.com',
    );
  }
}

/// Pure Dart Vector PDF Invoice Generation Engine.
///
/// Produces pixel-perfect, vector-based corporate A4 invoices compliant with
/// international enterprise billing standards without any Flutter widget or
/// DOM dependencies.
class PdfInvoiceEngine {
  const PdfInvoiceEngine();

  // Corporate Brand Color Palette
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF4F46E5); // Indigo 600
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF3730A3); // Indigo 800
  static const PdfColor textDark = PdfColor.fromInt(0xFF0F172A); // Slate 900
  static const PdfColor textMedium = PdfColor.fromInt(0xFF334155); // Slate 700
  static const PdfColor textLight = PdfColor.fromInt(0xFF64748B); // Slate 500
  static const PdfColor borderLight = PdfColor.fromInt(0xFFE2E8F0); // Slate 200
  static const PdfColor bgMuted = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
  static const PdfColor bgHighlight = PdfColor.fromInt(0xFFEEF2FF); // Indigo 50
  static const PdfColor successColor = PdfColor.fromInt(0xFF059669); // Emerald 600
  static const PdfColor warningColor = PdfColor.fromInt(0xFFD97706); // Amber 600
  static const PdfColor errorColor = PdfColor.fromInt(0xFFDC2626); // Red 600

  /// Generates a PDF byte array representing the given invoice.
  Future<Uint8List> generateInvoicePdf({
    required Invoice invoice,
    Customer? customer,
    Organization? organization,
    CompanyProfile? company,
  }) async {
    final companyInfo = company ?? CompanyProfile.fromOrganization(organization);
    final doc = pw.Document(
      title: 'Invoice ${invoice.invoiceNumber}',
      author: companyInfo.name,
      creator: 'VALIXIS BUSINESS OS Vector PDF Engine',
      subject: 'Commercial Invoice for ${customer?.companyName ?? invoice.customerDisplay}',
    );

    final dateFormatter = DateFormat('MMM dd, yyyy');
    final issueDateStr = dateFormatter.format(invoice.issueDate);
    final dueDateStr = dateFormatter.format(invoice.dueDate);

    // QR Code Verification Payload
    final qrPayload = 'VALIXIS:INV:${invoice.invoiceNumber}'
        ':TOTAL=${invoice.totalAmount.toStringAsFixed(2)}'
        ':CURR=${invoice.currency}'
        ':DUE=${invoice.dueDate.toIso8601String().substring(0, 10)}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Modern Enterprise Header
              _buildHeader(invoice, companyInfo),
              pw.SizedBox(height: 24),

              // 2. Billing & Invoice Metadata Row
              _buildBillingAndMetaRow(
                invoice: invoice,
                customer: customer,
                company: companyInfo,
                issueDate: issueDateStr,
                dueDate: dueDateStr,
              ),
              pw.SizedBox(height: 24),

              // 3. Itemized Line Items Table
              _buildLineItemsTable(invoice),
              pw.SizedBox(height: 16),

              // 4. Financial Totals & Summary Block
              _buildFinancialSummaryBlock(invoice),
              pw.SizedBox(height: 20),

              // Spacer to push notes and footer to bottom
              pw.Spacer(),

              // 5. Notes, Terms & Verification QR Code
              _buildNotesAndQrSection(invoice, qrPayload),
              pw.SizedBox(height: 16),

              // 6. Security & Page Footer
              _buildFooter(invoice, context),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // --- Sub-component builders ---

  pw.Widget _buildHeader(Invoice invoice, CompanyProfile company) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Brand Identity & Company
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Geometric Vector Logo
            pw.Container(
              width: 44,
              height: 44,
              decoration: const pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Center(
                child: pw.Text(
                  'V',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 14),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  company.name,
                  style: const pw.TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'ENTERPRISE BUSINESS OS',
                  style: const pw.TextStyle(
                    color: primaryColor,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Document Type & Status Badge & Optional Vector PAID Stamp
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (invoice.isPaid || invoice.status.toLowerCase() == 'paid') ...[
              _buildPaidStamp(),
              pw.SizedBox(width: 16),
            ],
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'INVOICE',
                  style: const pw.TextStyle(
                    color: textDark,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 4),
                _buildStatusBadge(invoice.status),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPaidStamp() {
    return pw.Transform.rotate(
      angle: -0.22,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: successColor, width: 2.2),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'PAID',
              style: const pw.TextStyle(
                color: successColor,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 3.5,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Text(
              'VALIXIS VERIFIED',
              style: const pw.TextStyle(
                color: successColor,
                fontSize: 6.5,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildStatusBadge(String status) {
    PdfColor badgeBg;
    PdfColor badgeText;
    final String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'paid':
        badgeBg = const PdfColor.fromInt(0xFFD1FAE5); // Emerald 100
        badgeText = successColor;
        break;
      case 'sent':
        badgeBg = bgHighlight;
        badgeText = primaryColor;
        break;
      case 'overdue':
        badgeBg = const PdfColor.fromInt(0xFFFEE2E2); // Red 100
        badgeText = errorColor;
        break;
      case 'partially_paid':
        badgeBg = const PdfColor.fromInt(0xFFFEF3C7); // Amber 100
        badgeText = warningColor;
        break;
      case 'draft':
      default:
        badgeBg = const PdfColor.fromInt(0xFFF1F5F9); // Slate 100
        badgeText = textMedium;
        break;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: badgeBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: badgeText, width: 0.5),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          color: badgeText,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  pw.Widget _buildBillingAndMetaRow({
    required Invoice invoice,
    required Customer? customer,
    required CompanyProfile company,
    required String issueDate,
    required String dueDate,
  }) {
    final clientName = customer?.name ?? invoice.customerName ?? 'Valued Customer';
    final clientCompany = customer?.companyName ?? invoice.customerCompany ?? '';
    final clientEmail = customer?.email ?? '';
    final clientAddress = customer?.billingAddress ?? '';
    final clientTaxId = customer?.taxId ?? '';

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: bgMuted,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderLight, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Left: Billed From (Company Info)
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FROM',
                  style: const pw.TextStyle(
                    color: textLight,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  company.name,
                  style: const pw.TextStyle(
                    color: textDark,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(company.address, style: const pw.TextStyle(color: textMedium, fontSize: 9)),
                pw.Text('${company.cityStateZip}, ${company.country}',
                    style: const pw.TextStyle(color: textMedium, fontSize: 9)),
                pw.Text('Email: ${company.email}',
                    style: const pw.TextStyle(color: textMedium, fontSize: 9)),
                pw.Text('Tax ID: ${company.taxId}',
                    style: const pw.TextStyle(color: textMedium, fontSize: 9)),
              ],
            ),
          ),

          // Center: Billed To (Customer Info)
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILLED TO',
                  style: const pw.TextStyle(
                    color: textLight,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (clientCompany.isNotEmpty) ...[
                  pw.Text(
                    clientCompany,
                    style: const pw.TextStyle(
                      color: textDark,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
                pw.Text(
                  clientName,
                  style: pw.TextStyle(
                    color: clientCompany.isEmpty ? textDark : textMedium,
                    fontSize: clientCompany.isEmpty ? 11 : 9,
                    fontWeight: clientCompany.isEmpty ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
                if (clientAddress.isNotEmpty)
                  pw.Text(clientAddress, style: const pw.TextStyle(color: textMedium, fontSize: 9)),
                if (clientEmail.isNotEmpty)
                  pw.Text('Email: $clientEmail', style: const pw.TextStyle(color: textMedium, fontSize: 9)),
                if (clientTaxId.isNotEmpty)
                  pw.Text('Tax ID: $clientTaxId', style: const pw.TextStyle(color: textMedium, fontSize: 9)),
              ],
            ),
          ),

          // Right: Invoice Metadata Box
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildMetaField('Invoice Number', invoice.invoiceNumber, isBoldValue: true),
                pw.SizedBox(height: 4),
                _buildMetaField('Issue Date', issueDate),
                pw.SizedBox(height: 4),
                _buildMetaField('Payment Due', dueDate, isHighlight: true),
                pw.SizedBox(height: 4),
                _buildMetaField('Currency', invoice.currency),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetaField(String label, String value, {bool isBoldValue = false, bool isHighlight = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          '$label: ',
          style: const pw.TextStyle(color: textLight, fontSize: 9),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: isHighlight ? primaryDark : textDark,
            fontSize: 9,
            fontWeight: isBoldValue || isHighlight ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildLineItemsTable(Invoice invoice) {
    const tableHeaders = ['#', 'DESCRIPTION', 'QTY', 'UNIT PRICE', 'AMOUNT'];

    return pw.Table(
      border: const pw.TableBorder(
        bottom: pw.BorderSide(color: borderLight, width: 0.8),
        horizontalInside: pw.BorderSide(color: borderLight, width: 0.5),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(5),
        2: const pw.FixedColumnWidth(48),
        3: const pw.FixedColumnWidth(80),
        4: const pw.FixedColumnWidth(90),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: primaryDark,
          ),
          children: tableHeaders.map((header) {
            final isRightAligned = header == 'QTY' || header == 'UNIT PRICE' || header == 'AMOUNT';
            final isCenter = header == '#';
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: pw.Text(
                header,
                textAlign: isRightAligned
                    ? pw.TextAlign.right
                    : (isCenter ? pw.TextAlign.center : pw.TextAlign.left),
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            );
          }).toList(),
        ),

        // Table Rows
        ...invoice.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isEven = idx % 2 == 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : bgMuted,
            ),
            children: [
              // Index
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: pw.Text(
                  '${idx + 1}',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(color: textLight, fontSize: 9),
                ),
              ),

              // Description
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: pw.Text(
                  item.description,
                  style: const pw.TextStyle(
                    color: textDark,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Quantity
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: pw.Text(
                  _formatQuantity(item.quantity),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(color: textMedium, fontSize: 9),
                ),
              ),

              // Unit Price
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: pw.Text(
                  _formatCurrency(item.unitPrice, invoice.currency),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(color: textMedium, fontSize: 9),
                ),
              ),

              // Line Amount
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: pw.Text(
                  _formatCurrency(item.amount, invoice.currency),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(
                    color: textDark,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildFinancialSummaryBlock(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 240,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: bgMuted,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: borderLight, width: 0.8),
          ),
          child: pw.Column(
            children: [
              // Subtotal
              _buildSummaryRow(
                'Subtotal',
                _formatCurrency(invoice.subtotal, invoice.currency),
              ),
              pw.SizedBox(height: 6),

              // Tax
              _buildSummaryRow(
                'Tax (${invoice.taxRate.toStringAsFixed(invoice.taxRate % 1 == 0 ? 0 : 1)}%)',
                _formatCurrency(invoice.taxAmount, invoice.currency),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Divider(color: borderLight, thickness: 0.8),
              ),

              // Grand Total
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: bgHighlight,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL DUE',
                      style: const pw.TextStyle(
                        color: primaryDark,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.Text(
                      _formatCurrency(invoice.totalAmount, invoice.currency),
                      style: const pw.TextStyle(
                        color: primaryDark,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(color: textLight, fontSize: 9.5),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(
            color: textDark,
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildNotesAndQrSection(Invoice invoice, String qrPayload) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Notes & Wire Instructions
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYMENT TERMS & INSTRUCTIONS',
                style: const pw.TextStyle(
                  color: textLight,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                invoice.notes?.isNotEmpty == true
                    ? invoice.notes!
                    : 'Payment is due within 30 days of issue date. Direct electronic bank transfers (ACH/Wire) preferred. Please quote the invoice number on your payment reference.',
                style: const pw.TextStyle(color: textMedium, fontSize: 8.5, lineSpacing: 1.3),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 24),

        // QR Code Verification
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderLight, width: 0.8),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                color: PdfColors.white,
              ),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qrPayload,
                width: 58,
                height: 58,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Scan to Verify',
              style: const pw.TextStyle(color: textLight, fontSize: 7),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter(Invoice invoice, pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderLight, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'VALIXIS BUSINESS OS | Intelligent Enterprise Operations Engine',
            style: const pw.TextStyle(color: textLight, fontSize: 7.5),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: textLight, fontSize: 7.5),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount, String currencyCode) {
    final rounded = FinancialCalculator.roundMoney(amount);
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedNum = formatter.format(rounded);
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$$formattedNum';
      case 'EUR':
        return 'EUR $formattedNum';
      case 'INR':
        return 'INR $formattedNum';
      case 'GBP':
        return 'GBP $formattedNum';
      default:
        return '$currencyCode $formattedNum';
    }
  }

  String _formatQuantity(double quantity) {
    if (quantity % 1 == 0) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(2);
  }
}
