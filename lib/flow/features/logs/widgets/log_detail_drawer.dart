import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/execution_log_model.dart';
import '../providers/execution_logs_provider.dart';

class LogDetailDrawer extends ConsumerWidget {
  final ExecutionLog log;
  final VoidCallback onClose;

  const LogDetailDrawer({
    super.key,
    required this.log,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(executionLogsProvider.notifier);

    return Container(
      width: 540,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.obsidianSurface,
        border: Border(left: BorderSide(color: AppColors.obsidianBorder, width: 1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.electricCyan, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Audit Log: ${log.shortId}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Error Banner & Manual DLQ Retry Override if Failed or Retrying
          if ((log.status == 'failed' || log.status == 'retrying') && log.errorCode != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.coralRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.coralRed, size: 18),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Execution Failure & DLQ Trace',
                                style: TextStyle(color: AppColors.coralRed, fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ok = await notifier.retryExecution(log.id);
                          if (context.mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Manual DLQ override triggered! Execution state set to completed.'),
                                backgroundColor: AppColors.emeraldGreen,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Retry Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricCyan,
                          foregroundColor: AppColors.obsidianDark,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    log.errorCode!,
                    style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Step Timeline List
          Expanded(
            child: ListView.separated(
              itemCount: log.steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final step = log.steps[index];
                return Card(
                  color: AppColors.obsidianCard,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: step.status == 'success'
                                        ? AppColors.emeraldGreen.withValues(alpha: 0.2)
                                        : AppColors.coralRed.withValues(alpha: 0.2),
                                    child: Text(
                                      '${step.stepNumber}',
                                      style: TextStyle(
                                        color: step.status == 'success' ? AppColors.emeraldGreen : AppColors.coralRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      step.stepName,
                                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${step.durationMs} ms',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Input Payload Section
                        _buildCodeSnippetHeader('Input Payload', step.prettyInput, context),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.obsidianSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.obsidianBorder),
                          ),
                          child: SelectableText(
                            step.prettyInput,
                            style: const TextStyle(color: AppColors.emeraldGreen, fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Output Payload Section
                        _buildCodeSnippetHeader('Output JSON', step.prettyOutput, context),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.obsidianSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.obsidianBorder),
                          ),
                          child: SelectableText(
                            step.prettyOutput,
                            style: const TextStyle(color: AppColors.electricCyan, fontFamily: 'monospace', fontSize: 11),
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
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic)
        .slideX(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildCodeSnippetHeader(String title, String rawText, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: rawText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title copied to clipboard!')),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.copy, size: 12, color: AppColors.electricCyan),
              SizedBox(width: 4),
              Text('Copy', style: TextStyle(color: AppColors.electricCyan, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
