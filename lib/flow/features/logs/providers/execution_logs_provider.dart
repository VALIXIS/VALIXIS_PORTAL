import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/execution_log_model.dart';

class ExecutionLogsState {
  final List<ExecutionLog> logs;
  final String searchQuery;
  final String selectedStatusFilter; // 'all' | 'running' | 'completed' | 'failed' | 'retrying'
  final ExecutionLog? selectedLogForDrawer;

  const ExecutionLogsState({
    required this.logs,
    required this.searchQuery,
    required this.selectedStatusFilter,
    this.selectedLogForDrawer,
  });

  List<ExecutionLog> get filteredLogs {
    return logs.where((log) {
      final matchesStatus = selectedStatusFilter == 'all' ||
          log.status.toLowerCase() == selectedStatusFilter.toLowerCase();
      final query = searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          log.id.toLowerCase().contains(query) ||
          log.workflowName.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  ExecutionLogsState copyWith({
    List<ExecutionLog>? logs,
    String? searchQuery,
    String? selectedStatusFilter,
    ExecutionLog? selectedLogForDrawer,
    bool clearDrawer = false,
  }) {
    return ExecutionLogsState(
      logs: logs ?? this.logs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedLogForDrawer: clearDrawer ? null : (selectedLogForDrawer ?? this.selectedLogForDrawer),
    );
  }
}

class ExecutionLogsNotifier extends StateNotifier<ExecutionLogsState> {
  ExecutionLogsNotifier()
      : super(
          ExecutionLogsState(
            logs: ExecutionLog.sampleLogs,
            searchQuery: '',
            selectedStatusFilter: 'all',
          ),
        );

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  void openDrawerForLog(ExecutionLog log) {
    state = state.copyWith(selectedLogForDrawer: log);
  }

  void closeDrawer() {
    state = state.copyWith(clearDrawer: true);
  }

  Future<bool> retryExecution(String logId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final updatedLogs = state.logs.map((log) {
      if (log.id == logId) {
        return ExecutionLog(
          id: log.id,
          workflowId: log.workflowId,
          workflowName: log.workflowName,
          triggerType: log.triggerType,
          status: 'completed',
          durationMs: log.durationMs,
          startedAt: DateTime.now(),
          steps: log.steps,
        );
      }
      return log;
    }).toList();

    final updatedDrawerLog = state.selectedLogForDrawer?.id == logId
        ? updatedLogs.firstWhere((l) => l.id == logId)
        : state.selectedLogForDrawer;

    state = state.copyWith(
      logs: updatedLogs,
      selectedLogForDrawer: updatedDrawerLog,
    );
    return true;
  }
}

final executionLogsProvider =
    StateNotifierProvider<ExecutionLogsNotifier, ExecutionLogsState>((ref) {
  return ExecutionLogsNotifier();
});
