import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../models/export_dataset.dart';
import '../services/export_studio_engine.dart';

/// Boardroom-Ready Export Center Modal Component
class ExportCenterModal extends StatefulWidget {
  final ExportDataset? dataset;

  const ExportCenterModal({
    super.key,
    this.dataset,
  });

  static Future<void> show(BuildContext context, {ExportDataset? dataset}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ExportCenterModal(dataset: dataset),
    );
  }

  @override
  State<ExportCenterModal> createState() => _ExportCenterModalState();
}

class _ExportCenterModalState extends State<ExportCenterModal> {
  late ExportDataset _dataset;
  ExportFormat _selectedFormat = ExportFormat.auditPdf;

  final TextEditingController _filenameController =
      TextEditingController(text: 'valixis_pulse_audit_report');

  bool _isExporting = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _dataset = widget.dataset ?? ExportDataset.sample();
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateExport() async {
    setState(() {
      _isExporting = true;
      _statusMessage = null;
    });

    final filename = '${_filenameController.text.trim()}.${_selectedFormat.extension}';

    Uint8List bytes;
    switch (_selectedFormat) {
      case ExportFormat.csv:
        final csvContent = ExportStudioEngine.generateCsv(_dataset);
        bytes = Uint8List.fromList(utf8.encode(csvContent));
        break;
      case ExportFormat.excel:
        bytes = ExportStudioEngine.generateExcelBytes(_dataset);
        break;
      case ExportFormat.svgChart:
        final svgContent = ExportStudioEngine.generateVectorSvgChart(_dataset);
        bytes = Uint8List.fromList(utf8.encode(svgContent));
        break;
      case ExportFormat.auditPdf:
        bytes = await ExportStudioEngine.generateAuditPdfBytes(_dataset);
        break;
    }

    if (mounted) {
      setState(() {
        _isExporting = false;
        _statusMessage = 'Generated $filename (${bytes.length} bytes) successfully!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 750,
        constraints: const BoxConstraints(maxHeight: 720),
        decoration: BoxDecoration(
          color: PulseColors.surfaceObsidian,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PulseColors.electricCyan.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: PulseColors.electricCyan.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: PulseColors.cardObsidian,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PulseColors.electricCyan.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.download, color: PulseColors.electricCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOARDROOM DATA EXPORT STUDIO',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PulseColors.electricCyan,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          'Export Vector SVG Charts, Multi-Sheet Excel, CSV & Audit PDFs',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: PulseColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: PulseColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FORMAT OPTIONS GRID
                    const Text(
                      'SELECT EXPORT FORMAT',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildFormatCard(
                          format: ExportFormat.auditPdf,
                          title: 'Boardroom Audit PDF',
                          subtitle: 'Branded 1-page executive vector report',
                          icon: Icons.picture_as_pdf,
                          accentColor: PulseColors.electricCyan,
                        ),
                        _buildFormatCard(
                          format: ExportFormat.excel,
                          title: 'Formatted Excel (.xlsx)',
                          subtitle: 'Structured workbook with UTF-8 BOM',
                          icon: Icons.table_view,
                          accentColor: PulseColors.emeraldGrowth,
                        ),
                        _buildFormatCard(
                          format: ExportFormat.svgChart,
                          title: 'Vector SVG Chart',
                          subtitle: 'Scalable graphic for executive decks',
                          icon: Icons.show_chart,
                          accentColor: PulseColors.accentPurple,
                        ),
                        _buildFormatCard(
                          format: ExportFormat.csv,
                          title: 'CSV Raw Dataset',
                          subtitle: 'Comma-separated raw data rows',
                          icon: Icons.article_outlined,
                          accentColor: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // FILENAME & CUSTOMIZATION
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _filenameController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Target Output Filename',
                              suffixText: '.${_selectedFormat.extension}',
                              suffixStyle: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                color: PulseColors.electricCyan,
                                fontWeight: FontWeight.bold,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: PulseColors.cardObsidian,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // LIVE PREVIEW CONTAINER
                    const Text(
                      'EXPORT PREVIEW & DATASET SUMMARY',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PulseColors.cardObsidian,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PulseColors.cardGlassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dataset.title,
                                style: const TextStyle(
                                  color: PulseColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PulseColors.electricCyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_dataset.rows.length} Rows',
                                  style: const TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    color: PulseColors.electricCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _dataset.description,
                            style: const TextStyle(color: PulseColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _dataset.summaryStats.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.key.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 9,
                                          color: PulseColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        e.value.toString(),
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: PulseColors.emeraldGrowth,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // EXPORT STATUS BANNER
                    if (_statusMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PulseColors.emeraldGrowth.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PulseColors.emeraldGrowth),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: PulseColors.emeraldGrowth),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _statusMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // FOOTER ACTIONS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: PulseColors.cardObsidian,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleGenerateExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PulseColors.electricCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      _isExporting ? 'Generating...' : 'Download Export Package',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required ExportFormat format,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.15) : PulseColors.cardObsidian,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : PulseColors.cardGlassBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : PulseColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: PulseColors.textMuted, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
