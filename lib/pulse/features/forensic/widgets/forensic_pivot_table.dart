import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/pulse_theme.dart';
import '../models/forensic_record.dart';
import '../services/forensic_pivot_engine.dart';

/// Virtualized 60fps Multi-Dimension Drill-Down Pivot Table Component
class ForensicPivotTable extends StatefulWidget {
  final List<ForensicRecord> records;

  const ForensicPivotTable({
    super.key,
    required this.records,
  });

  @override
  State<ForensicPivotTable> createState() => _ForensicPivotTableState();
}

class _ForensicPivotTableState extends State<ForensicPivotTable> {
  late ForensicFilterState _filterState;
  late List<PivotTreeNode> _rootNodes;
  late List<FlatRowItem> _flatRows;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _availableChannels = ['Outbound', 'Paid Ads', 'Organic', 'Direct', 'Referral'];
  final List<String> _availableOwners = ['Alex Mercer', 'Sarah Chen', 'David Miller', 'Elena Rostova'];
  final List<String> _availableStatuses = ['Closed Won', 'In Negotiation', 'Discovery', 'Closed Lost'];

  @override
  void initState() {
    super.initState();
    _filterState = ForensicFilterState();
    _recomputePivotTree();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _recomputePivotTree() {
    _rootNodes = ForensicPivotEngine.buildPivotTree(widget.records, _filterState);
    _flatRows = ForensicPivotEngine.flattenTree(_rootNodes);
  }

  void _updateFilter(ForensicFilterState newFilter) {
    setState(() {
      _filterState = newFilter;
      _recomputePivotTree();
    });
  }

  void _toggleGroupExpansion(PivotTreeNode node) {
    setState(() {
      node.isExpanded = !node.isExpanded;
      _flatRows = ForensicPivotEngine.flattenTree(_rootNodes);
    });
  }

  void _swapDimensions(int indexA, int indexB) {
    if (indexA < 0 || indexB < 0 || indexA >= _filterState.dimensions.length || indexB >= _filterState.dimensions.length) {
      return;
    }
    final dims = List<GroupDimension>.from(_filterState.dimensions);
    final temp = dims[indexA];
    dims[indexA] = dims[indexB];
    dims[indexB] = temp;
    _updateFilter(_filterState.copyWith(dimensions: dims));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    // Compute Summary Stats
    double totalArr = 0;
    int totalCount = 0;
    for (final node in _rootNodes) {
      totalArr += node.totalArr;
      totalCount += node.recordCount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. TOP METRICS SUMMARY BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: PulseColors.surfaceObsidian,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PulseColors.cardGlassBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryStat(
                  label: 'TOTAL FILTERED ARR',
                  value: currencyFormat.format(totalArr),
                  color: PulseColors.electricCyan,
                  icon: Icons.monetization_on_outlined,
                ),
                const SizedBox(width: 24),
                _buildSummaryStat(
                  label: 'RECORD COUNT',
                  value: totalCount.toString(),
                  color: PulseColors.emeraldGrowth,
                  icon: Icons.table_chart_outlined,
                ),
                const SizedBox(width: 24),
                _buildSummaryStat(
                  label: 'ACTIVE PIVOT DEPTH',
                  value: '${_filterState.dimensions.length} Levels',
                  color: PulseColors.accentPurple,
                  icon: Icons.account_tree_outlined,
                ),
                const SizedBox(width: 24),
                // Dimension Reorder Controls
                Row(
                  children: [
                    const Text(
                      'GROUP BY: ',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...List.generate(_filterState.dimensions.length, (idx) {
                      final dim = _filterState.dimensions[idx];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          backgroundColor: PulseColors.cardObsidian,
                          side: const BorderSide(color: PulseColors.electricCyan),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${idx + 1}. ${dim.label}',
                                style: const TextStyle(
                                  color: PulseColors.electricCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (idx < _filterState.dimensions.length - 1)
                                const Icon(Icons.chevron_right, size: 14, color: PulseColors.textMuted),
                            ],
                          ),
                          onPressed: () {
                            if (idx < _filterState.dimensions.length - 1) {
                              _swapDimensions(idx, idx + 1);
                            } else if (idx > 0) {
                              _swapDimensions(idx, idx - 1);
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. FACET FILTER CONTROLS BAR
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PulseColors.cardObsidian,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PulseColors.cardGlassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _updateFilter(_filterState.copyWith(searchQuery: val));
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search channel, owner, or status...',
                    hintStyle: const TextStyle(color: PulseColors.textMuted, fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 16, color: PulseColors.electricCyan),
                    isDense: true,
                    filled: true,
                    fillColor: PulseColors.surfaceObsidian,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Channel Facet Dropdown
              _buildFacetFilterMenu(
                title: 'Channel',
                selectedItems: _filterState.selectedChannels,
                allItems: _availableChannels,
                onChanged: (updated) => _updateFilter(_filterState.copyWith(selectedChannels: updated)),
              ),
              const SizedBox(width: 8),
              // Owner Facet Dropdown
              _buildFacetFilterMenu(
                title: 'Owner',
                selectedItems: _filterState.selectedOwners,
                allItems: _availableOwners,
                onChanged: (updated) => _updateFilter(_filterState.copyWith(selectedOwners: updated)),
              ),
              const SizedBox(width: 8),
              // Status Facet Dropdown
              _buildFacetFilterMenu(
                title: 'Status',
                selectedItems: _filterState.selectedStatuses,
                allItems: _availableStatuses,
                onChanged: (updated) => _updateFilter(_filterState.copyWith(selectedStatuses: updated)),
              ),
              if (_filterState.selectedChannels.isNotEmpty ||
                  _filterState.selectedOwners.isNotEmpty ||
                  _filterState.selectedStatuses.isNotEmpty ||
                  _filterState.searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off, color: PulseColors.coralRedAlert, size: 20),
                  tooltip: 'Reset Filters',
                  onPressed: () {
                    _searchController.clear();
                    _updateFilter(ForensicFilterState());
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. TABLE HEADER ROW
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF181F30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'DIMENSION SLICE / RECORD',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'SUB-TOTAL ARR',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.electricCyan,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'RECORDS',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.emeraldGrowth,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'AVG CONV. DAYS',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. VIRTUALIZED LIST VIEW FOR SMOOTH 60FPS SCROLLING
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: PulseColors.surfaceObsidian,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border.all(color: PulseColors.cardGlassBorder),
            ),
            child: _flatRows.isEmpty
                ? const Center(
                    child: Text(
                      'No forensic records matching search criteria.',
                      style: TextStyle(color: PulseColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: _flatRows.length,
                    itemExtent: 44, // Fixed height per row for extreme 60fps performance
                    itemBuilder: (context, index) {
                      final item = _flatRows[index];
                      if (item is GroupHeaderRowItem) {
                        return _buildGroupHeaderRow(item.node, currencyFormat);
                      } else if (item is LeafRecordRowItem) {
                        return _buildLeafRecordRow(item.record, item.depth, currencyFormat);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: PulseColors.textMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacetFilterMenu({
    required String title,
    required Set<String> selectedItems,
    required List<String> allItems,
    required ValueChanged<Set<String>> onChanged,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Filter by $title',
      color: PulseColors.cardObsidian,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selectedItems.isNotEmpty ? PulseColors.electricCyan.withOpacity(0.15) : PulseColors.surfaceObsidian,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selectedItems.isNotEmpty ? PulseColors.electricCyan : PulseColors.cardGlassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedItems.isEmpty ? title : '$title (${selectedItems.length})',
              style: TextStyle(
                color: selectedItems.isNotEmpty ? PulseColors.electricCyan : PulseColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: selectedItems.isNotEmpty ? PulseColors.electricCyan : PulseColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (ctx) {
        return allItems.map((item) {
          final isChecked = selectedItems.contains(item);
          return PopupMenuItem<String>(
            value: item,
            onTap: () {
              final updated = Set<String>.from(selectedItems);
              if (isChecked) {
                updated.remove(item);
              } else {
                updated.add(item);
              }
              onChanged(updated);
            },
            child: Row(
              children: [
                Icon(
                  isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isChecked ? PulseColors.electricCyan : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  item,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildGroupHeaderRow(PivotTreeNode node, NumberFormat currencyFormat) {
    final indent = node.depth * 20.0;

    return InkWell(
      onTap: () => _toggleGroupExpansion(node),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(width: indent),
            Icon(
              node.isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              color: PulseColors.electricCyan,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${node.dimension.label.toUpperCase()}: ',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textMuted,
                      ),
                    ),
                    TextSpan(
                      text: node.key,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                currencyFormat.format(node.totalArr),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: PulseColors.electricCyan,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${node.recordCount} recs',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PulseColors.emeraldGrowth,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${node.avgConversionDays.toStringAsFixed(1)} days',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: PulseColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeafRecordRow(ForensicRecord record, int depth, NumberFormat currencyFormat) {
    final indent = depth * 20.0 + 8.0;

    final statusColor = record.status == 'Closed Won'
        ? PulseColors.emeraldGrowth
        : (record.status == 'In Negotiation' ? PulseColors.electricCyan : Colors.orangeAccent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: PulseColors.surfaceObsidian.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(width: indent),
          const Icon(Icons.circle, size: 6, color: PulseColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              '${record.id} — ${record.owner} (${record.region})',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: PulseColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(record.arrValue),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: PulseColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${record.conversionDays} days',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: PulseColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
