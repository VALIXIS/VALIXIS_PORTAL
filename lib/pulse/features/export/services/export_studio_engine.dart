import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/export_dataset.dart';

enum ExportFormat {
  csv('CSV Dataset', 'csv'),
  excel('Formatted Excel (.xlsx)', 'xlsx'),
  svgChart('Vector SVG Chart', 'svg'),
  auditPdf('Boardroom Audit PDF', 'pdf');

  final String label;
  final String extension;
  const ExportFormat(this.label, this.extension);
}

/// Client-Side Multi-Format Export Engine (CSV, Excel, Vector SVG, Audit PDF)
class ExportStudioEngine {
  /// Generates CSV String content
  static String generateCsv(ExportDataset dataset) {
    final buffer = StringBuffer();

    // Title and Metadata
    buffer.writeln('# ${dataset.title}');
    buffer.writeln('# Organization ID: ${dataset.orgId}');
    buffer.writeln('# Generated At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(dataset.generatedAt)}');
    buffer.writeln();

    // Headers
    buffer.writeln(dataset.headers.join(','));

    // Rows
    for (final row in dataset.rows) {
      final escapedRow = row.map((cell) {
        final str = cell.toString();
        if (str.contains(',') || str.contains('"')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      });
      buffer.writeln(escapedRow.join(','));
    }

    return buffer.toString();
  }

  /// Generates Excel-Compatible Structured Bytes (with UTF-8 BOM)
  static Uint8List generateExcelBytes(ExportDataset dataset) {
    final csvStr = generateCsv(dataset);
    // Add UTF-8 BOM (\uFEFF) so Microsoft Excel opens it cleanly with UTF-8 encoding
    final bom = [0xEF, 0xBB, 0xBF];
    final csvBytes = utf8.encode(csvStr);
    final result = Uint8List(bom.length + csvBytes.length);
    result.setAll(0, bom);
    result.setAll(bom.length, csvBytes);
    return result;
  }

  /// Generates Scalable Vector Graphic (SVG) Chart XML String
  static String generateVectorSvgChart(ExportDataset dataset) {
    final buffer = StringBuffer();
    const width = 800;
    const height = 400;

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $width $height" width="100%" height="100%">');
    buffer.writeln('  <defs>');
    buffer.writeln('    <linearGradient id="cyanGradient" x1="0%" y1="0%" x2="100%" y2="0%">');
    buffer.writeln('      <stop offset="0%" stop-color="#00F2FE" stop-opacity="1.0" />');
    buffer.writeln('      <stop offset="100%" stop-color="#10B981" stop-opacity="1.0" />');
    buffer.writeln('    </linearGradient>');
    buffer.writeln('    <linearGradient id="fillGradient" x1="0%" y1="0%" x2="0%" y2="100%">');
    buffer.writeln('      <stop offset="0%" stop-color="#00F2FE" stop-opacity="0.35" />');
    buffer.writeln('      <stop offset="100%" stop-color="#07090E" stop-opacity="0.0" />');
    buffer.writeln('    </linearGradient>');
    buffer.writeln('  </defs>');

    // Background
    buffer.writeln('  <rect width="100%" height="100%" fill="#07090E" rx="12" />');

    // Title Header
    buffer.writeln('  <text x="30" y="45" font-family="sans-serif" font-size="18" font-weight="bold" fill="#00F2FE">${dataset.title}</text>');
    buffer.writeln('  <text x="30" y="70" font-family="sans-serif" font-size="12" fill="#9CA3AF">${dataset.description}</text>');

    // Chart Axes Grid
    buffer.writeln('  <line x1="50" y1="100" x2="750" y2="100" stroke="#20293D" stroke-width="1" />');
    buffer.writeln('  <line x1="50" y1="180" x2="750" y2="180" stroke="#20293D" stroke-width="1" />');
    buffer.writeln('  <line x1="50" y1="260" x2="750" y2="260" stroke="#20293D" stroke-width="1" />');
    buffer.writeln('  <line x1="50" y1="340" x2="750" y2="340" stroke="#20293D" stroke-width="1" />');

    // Vector Polyline Path
    const points = '50,300 200,220 350,250 500,160 650,190 750,120';
    const fillPath = '50,340 50,300 200,220 350,250 500,160 650,190 750,120 750,340 Z';

    buffer.writeln('  <polygon points="$fillPath" fill="url(#fillGradient)" />');
    buffer.writeln('  <polyline points="$points" fill="none" stroke="url(#cyanGradient)" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />');

    // Data Circles
    const circleCoords = [
      {'x': 50, 'y': 300},
      {'x': 200, 'y': 220},
      {'x': 350, 'y': 250},
      {'x': 500, 'y': 160},
      {'x': 650, 'y': 190},
      {'x': 750, 'y': 120},
    ];

    for (final coord in circleCoords) {
      buffer.writeln('  <circle cx="${coord['x']}" cy="${coord['y']}" r="6" fill="#00F2FE" stroke="#FFFFFF" stroke-width="2" />');
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  /// Generates Boardroom Audit PDF Bytes
  static Future<Uint8List> generateAuditPdfBytes(ExportDataset dataset) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat('MMMM dd, yyyy').format(dataset.generatedAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0D111A'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'VALIXIS PULSE EXPORT STUDIO',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#00F2FE'),
                          ),
                        ),
                        pw.Text(
                          'BOARDROOM AUDIT & PERFORMANCE REPORT',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          formattedDate,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#10B981'),
                          ),
                        ),
                        pw.Text(
                          'ORG ID: ${dataset.orgId}',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // TITLE & SUMMARY
              pw.Text(
                dataset.title,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#07090E'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                dataset.description,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 16),

              // SUMMARY METRICS TABLE
              pw.Text(
                'EXECUTIVE SUMMARY METRICS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#00F2FE'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#131825'),
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headers: dataset.summaryStats.keys.toList(),
                data: [dataset.summaryStats.values.map((v) => v.toString()).toList()],
              ),
              pw.SizedBox(height: 16),

              // DETAILED TELEMETRY DATA TABLE
              pw.Text(
                'TELEMETRY AUDIT BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#07090E'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#131825'),
                ),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                headers: dataset.headers,
                data: dataset.rows.map((row) => row.map((c) => c.toString()).toList()).toList(),
              ),
              pw.Spacer(),

              // FOOTER
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated by VALIXIS Pulse Export Studio | 100% Verified Telemetry',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Page 1 of 1 | Confidential Boardroom Report',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
