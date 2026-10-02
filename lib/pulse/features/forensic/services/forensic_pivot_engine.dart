import '../models/forensic_record.dart';

enum GroupDimension {
  channel('Channel'),
  owner('Owner'),
  status('Status'),
  region('Region'),
  date('Month');

  final String label;
  const GroupDimension(this.label);
}

class ForensicFilterState {
  final Set<String> selectedChannels;
  final Set<String> selectedOwners;
  final Set<String> selectedStatuses;
  final String searchQuery;
  final List<GroupDimension> dimensions;

  ForensicFilterState({
    Set<String>? selectedChannels,
    Set<String>? selectedOwners,
    Set<String>? selectedStatuses,
    this.searchQuery = '',
    List<GroupDimension>? dimensions,
  })  : selectedChannels = selectedChannels ?? {},
        selectedOwners = selectedOwners ?? {},
        selectedStatuses = selectedStatuses ?? {},
        dimensions = dimensions ?? [GroupDimension.channel, GroupDimension.owner, GroupDimension.status];

  ForensicFilterState copyWith({
    Set<String>? selectedChannels,
    Set<String>? selectedOwners,
    Set<String>? selectedStatuses,
    String? searchQuery,
    List<GroupDimension>? dimensions,
  }) {
    return ForensicFilterState(
      selectedChannels: selectedChannels ?? this.selectedChannels,
      selectedOwners: selectedOwners ?? this.selectedOwners,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      searchQuery: searchQuery ?? this.searchQuery,
      dimensions: dimensions ?? this.dimensions,
    );
  }
}

class PivotTreeNode {
  final String id;
  final String key;
  final GroupDimension dimension;
  final int depth;
  final double totalArr;
  final int recordCount;
  final double avgConversionDays;
  final List<PivotTreeNode> children;
  final List<ForensicRecord> leafRecords;
  bool isExpanded;

  PivotTreeNode({
    required this.id,
    required this.key,
    required this.dimension,
    required this.depth,
    required this.totalArr,
    required this.recordCount,
    required this.avgConversionDays,
    required this.children,
    required this.leafRecords,
    this.isExpanded = true,
  });
}

/// Abstract item representing a row in virtualized list view
abstract class FlatRowItem {
  final String rowId;
  final int depth;
  FlatRowItem(this.rowId, this.depth);
}

class GroupHeaderRowItem extends FlatRowItem {
  final PivotTreeNode node;
  GroupHeaderRowItem(this.node) : super(node.id, node.depth);
}

class LeafRecordRowItem extends FlatRowItem {
  final ForensicRecord record;
  LeafRecordRowItem(this.record, int depth) : super(record.id, depth);
}

/// Multi-dimension grouping and aggregation engine
class ForensicPivotEngine {
  /// Filters records and builds multi-level nested pivot tree
  static List<PivotTreeNode> buildPivotTree(
    List<ForensicRecord> records,
    ForensicFilterState filter,
  ) {
    // 1. Client-Side Facet Filtering
    final filtered = records.where((rec) {
      if (filter.selectedChannels.isNotEmpty && !filter.selectedChannels.contains(rec.channel)) {
        return false;
      }
      if (filter.selectedOwners.isNotEmpty && !filter.selectedOwners.contains(rec.owner)) {
        return false;
      }
      if (filter.selectedStatuses.isNotEmpty && !filter.selectedStatuses.contains(rec.status)) {
        return false;
      }
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final match = rec.channel.toLowerCase().contains(query) ||
            rec.owner.toLowerCase().contains(query) ||
            rec.status.toLowerCase().contains(query) ||
            rec.id.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();

    if (filter.dimensions.isEmpty) return [];

    // 2. Recursive Grouping
    return _groupSubTree(filtered, filter.dimensions, 0, 'root');
  }

  static List<PivotTreeNode> _groupSubTree(
    List<ForensicRecord> subset,
    List<GroupDimension> dimensions,
    int dimensionIndex,
    String parentId,
  ) {
    if (subset.isEmpty || dimensionIndex >= dimensions.length) {
      return [];
    }

    final currentDim = dimensions[dimensionIndex];
    final Map<String, List<ForensicRecord>> groupedMap = {};

    for (final rec in subset) {
      final key = _extractKey(rec, currentDim);
      groupedMap.putIfAbsent(key, () => []).add(rec);
    }

    final List<PivotTreeNode> nodes = [];

    groupedMap.forEach((key, groupRecords) {
      final totalArr = groupRecords.fold<double>(0.0, (sum, r) => sum + r.arrValue);
      final avgDays = groupRecords.fold<double>(0.0, (sum, r) => sum + r.conversionDays) / groupRecords.length;
      final nodeId = '${parentId}_${currentDim.name}_$key';

      final isLastDimension = dimensionIndex == dimensions.length - 1;
      final children = isLastDimension
          ? <PivotTreeNode>[]
          : _groupSubTree(groupRecords, dimensions, dimensionIndex + 1, nodeId);

      nodes.add(
        PivotTreeNode(
          id: nodeId,
          key: key,
          dimension: currentDim,
          depth: dimensionIndex,
          totalArr: totalArr,
          recordCount: groupRecords.length,
          avgConversionDays: avgDays,
          children: children,
          leafRecords: isLastDimension ? groupRecords : [],
          isExpanded: dimensionIndex < 2, // Auto-expand top 2 levels
        ),
      );
    });

    // Sort nodes by totalArr descending for executive priority view
    nodes.sort((a, b) => b.totalArr.compareTo(a.totalArr));
    return nodes;
  }

  static String _extractKey(ForensicRecord record, GroupDimension dimension) {
    switch (dimension) {
      case GroupDimension.channel:
        return record.channel;
      case GroupDimension.owner:
        return record.owner;
      case GroupDimension.status:
        return record.status;
      case GroupDimension.region:
        return record.region;
      case GroupDimension.date:
        return record.dateGroupKey;
    }
  }

  /// Flattens expanded nodes in tree into virtualized list items
  static List<FlatRowItem> flattenTree(List<PivotTreeNode> rootNodes) {
    final List<FlatRowItem> flatList = [];

    void traverse(PivotTreeNode node) {
      flatList.add(GroupHeaderRowItem(node));

      if (node.isExpanded) {
        if (node.children.isNotEmpty) {
          for (final child in node.children) {
            traverse(child);
          }
        } else if (node.leafRecords.isNotEmpty) {
          for (final rec in node.leafRecords) {
            flatList.add(LeafRecordRowItem(rec, node.depth + 1));
          }
        }
      }
    }

    for (final node in rootNodes) {
      traverse(node);
    }

    return flatList;
  }
}
