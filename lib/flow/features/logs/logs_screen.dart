import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'providers/execution_logs_provider.dart';
import 'widgets/log_detail_drawer.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(executionLogsProvider);
    final notifier = ref.read(executionLogsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VALIXIS Flow — Forensic Audit Execution Logs'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search & Status Filters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by Execution ID or Workflow Name...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          fillColor: AppColors.obsidianSurface,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.obsidianBorder),
                          ),
                        ),
                        onChanged: notifier.setSearchQuery,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildFilterChip(ref, 'all', 'All Statuses'),
                    _buildFilterChip(ref, 'completed', 'Success'),
                    _buildFilterChip(ref, 'failed', 'Failed'),
                    _buildFilterChip(ref, 'running', 'Running'),
                  ],
                ),
                const SizedBox(height: 20),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.obsidianBorder),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('Execution ID', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 3, child: Text('Workflow Name', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text('Trigger', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text('Status', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text('Latency (ms)', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text('Timestamp', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Logs Table List
                Expanded(
                  child: state.filteredLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 16),
                              Text(
                                'No Execution Runs Found',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Trigger a workflow or fire an inbound webhook to view live execution traces.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                    itemCount: state.filteredLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final log = state.filteredLogs[index];
                      return InkWell(
                        onTap: () => notifier.openDrawerForLog(log),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.obsidianCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.obsidianBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Text(
                                      log.shortId,
                                      style: const TextStyle(color: AppColors.electricCyan, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: log.id));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Execution ID copied!')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(log.workflowName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(log.triggerType, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildStatusPill(log.status),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${log.durationMs} ms', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${log.startedAt.hour.toString().padLeft(2, '0')}:${log.startedAt.minute.toString().padLeft(2, '0')}:${log.startedAt.second.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Slide-Over Drawer Modal Overlay
          if (state.selectedLogForDrawer != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: LogDetailDrawer(
                log: state.selectedLogForDrawer!,
                onClose: notifier.closeDrawer,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String statusKey, String label) {
    final state = ref.watch(executionLogsProvider);
    final notifier = ref.read(executionLogsProvider.notifier);
    final isSelected = state.selectedStatusFilter == statusKey;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.electricCyan.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.electricCyan : AppColors.textSecondary,
          fontSize: 12,
        ),
        onSelected: (_) => notifier.setStatusFilter(statusKey),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'completed':
        bg = AppColors.emeraldGreen.withValues(alpha: 0.15);
        fg = AppColors.emeraldGreen;
        break;
      case 'failed':
        bg = AppColors.coralRed.withValues(alpha: 0.15);
        fg = AppColors.coralRed;
        break;
      case 'running':
        bg = AppColors.electricCyan.withValues(alpha: 0.15);
        fg = AppColors.electricCyan;
        break;
      case 'retrying':
      default:
        bg = AppColors.statusRetrying.withValues(alpha: 0.15);
        fg = AppColors.statusRetrying;
        break;
    }

    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }
}
