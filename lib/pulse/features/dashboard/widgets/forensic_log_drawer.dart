import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../forensic/models/forensic_record.dart';
import '../../forensic/screens/forensic_explorer_screen.dart';
import '../../forensic/widgets/forensic_pivot_table.dart';
import '../../telemetry/models/telemetry_event.dart';

class ForensicLogDrawer extends StatefulWidget {
  final List<MetricSnapshot> snapshots;

  const ForensicLogDrawer({
    super.key,
    required this.snapshots,
  });

  @override
  State<ForensicLogDrawer> createState() => _ForensicLogDrawerState();
}

class _ForensicLogDrawerState extends State<ForensicLogDrawer> {
  late List<ForensicRecord> _forensicRecords;

  @override
  void initState() {
    super.initState();
    _forensicRecords = [];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: PulseColors.backgroundObsidian,
      width: 780,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DRAWER HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, color: PulseColors.electricCyan, size: 22),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FORENSIC AUDIT & PIVOT EXPLORER',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: PulseColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Live Multi-Dimension Pivot Slicing (5,000 Records)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: PulseColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_full, color: PulseColors.electricCyan, size: 20),
                        tooltip: 'Open Fullscreen Explorer',
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForensicExplorerScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: PulseColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: PulseColors.cardGlassBorder, height: 1),

            // EMBEDDED VIRTUALIZED PIVOT TABLE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ForensicPivotTable(records: _forensicRecords),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
