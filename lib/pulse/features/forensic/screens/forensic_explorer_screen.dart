import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../core/widgets/ambient_glow_background.dart';
import '../models/forensic_record.dart';
import '../widgets/forensic_pivot_table.dart';

/// Standalone Fullscreen Forensic Metric Explorer Screen
class ForensicExplorerScreen extends StatefulWidget {
  const ForensicExplorerScreen({super.key});

  @override
  State<ForensicExplorerScreen> createState() => _ForensicExplorerScreenState();
}

class _ForensicExplorerScreenState extends State<ForensicExplorerScreen> {
  late List<ForensicRecord> _records;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataset();
  }

  void _loadDataset() {
    _records = [];
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseColors.backgroundObsidian,
      appBar: AppBar(
        backgroundColor: PulseColors.surfaceObsidian,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PulseColors.cardObsidian,
              ),
              child: const Icon(Icons.search_rounded, color: PulseColors.electricCyan, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MULTI-DIMENSION FORENSIC EXPLORER',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PulseColors.textPrimary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'Instant slicing, grouping & sub-total aggregations over 5,000+ telemetry records',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: PulseColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: AmbientGlowBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: PulseColors.electricCyan),
                )
              : ForensicPivotTable(records: _records),
        ),
      ),
    );
  }
}
