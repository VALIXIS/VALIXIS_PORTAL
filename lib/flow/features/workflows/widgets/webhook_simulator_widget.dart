import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/webhook_template.dart';
import '../providers/webhook_simulator_provider.dart';

class WebhookSimulatorWidget extends ConsumerWidget {
  const WebhookSimulatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(webhookSimulatorProvider);
    final notifier = ref.read(webhookSimulatorProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header & Health Ping Indicator
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: AppColors.electricCyan, size: 24),
                SizedBox(width: 8),
                Text(
                  'Webhook Ingestion Simulator',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _buildHealthPingBadge(state.lastPingTime),
          ],
        ),
        const SizedBox(height: 16),

        // Webhook URL & Secret Key Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inbound Webhook Endpoint URL',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.obsidianSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.obsidianBorder),
                        ),
                        child: Text(
                          state.webhookUrl,
                          style: const TextStyle(color: AppColors.electricCyan, fontFamily: 'monospace', fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: state.webhookUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Webhook URL copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy URL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.obsidianSurface,
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Secret Token Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HMAC Secret Key (X-Valixis-Signature)',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                state.isTokenVisible
                                    ? state.secretToken
                                    : '••••••••••••••••••••••••••••••••',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  state.isTokenVisible ? Icons.visibility_off : Icons.visibility,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: notifier.toggleTokenVisibility,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: notifier.regenerateSecretToken,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Regenerate Token'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coralRed,
                        side: const BorderSide(color: AppColors.coralRed),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Code Snippet Tabs
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Integration Snippets',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Row(
                      children: [
                        _buildSnippetTab(ref, SnippetType.curl, 'cURL'),
                        _buildSnippetTab(ref, SnippetType.fetch, 'JS Fetch'),
                        _buildSnippetTab(ref, SnippetType.python, 'Python'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.obsidianBorder),
                  ),
                  child: SelectableText(
                    notifier.generateSnippet(),
                    style: const TextStyle(
                      color: AppColors.emeraldGreen,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Payload Injector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    const Text(
                      'Payload Injector & Runner',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    DropdownButton<WebhookTemplate>(
                      value: state.selectedTemplate,
                      dropdownColor: AppColors.obsidianSurface,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      items: WebhookTemplate.sampleTemplates.map((tmpl) {
                        return DropdownMenuItem(
                          value: tmpl,
                          child: Text(tmpl.title),
                        );
                      }).toList(),
                      onChanged: (tmpl) {
                        if (tmpl != null) notifier.selectTemplate(tmpl);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // JSON Body Input Box
                TextFormField(
                  initialValue: state.jsonBody,
                  maxLines: 8,
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
                  decoration: InputDecoration(
                    fillColor: AppColors.obsidianSurface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.obsidianBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.electricCyan),
                    ),
                  ),
                  onChanged: notifier.setJsonBody,
                ),

                if (state.jsonError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.jsonError!,
                    style: const TextStyle(color: AppColors.coralRed, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isSending || state.jsonError != null
                          ? null
                          : notifier.sendTestPayload,
                      icon: state.isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send, size: 16),
                      label: Text(state.isSending ? 'Sending Payload...' : 'Send Test Payload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricCyan,
                        foregroundColor: AppColors.obsidianDark,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),

                    if (state.lastStatusCode != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: state.lastStatusCode == 200
                                  ? AppColors.emeraldGreen.withValues(alpha:0.2)
                                  : AppColors.coralRed.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'HTTP ${state.lastStatusCode}',
                              style: TextStyle(
                                color: state.lastStatusCode == 200 ? AppColors.emeraldGreen : AppColors.coralRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.lastLatencyMs} ms',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                if (state.lastResponsePayload != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Response Body Inspector',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.obsidianBorder),
                    ),
                    child: SelectableText(
                      state.lastResponsePayload!,
                      style: const TextStyle(color: AppColors.electricCyan, fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSnippetTab(WidgetRef ref, SnippetType type, String label) {
    final state = ref.watch(webhookSimulatorProvider);
    final notifier = ref.read(webhookSimulatorProvider.notifier);
    final isSelected = state.activeSnippetType == type;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.electricCyan.withValues(alpha:0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.electricCyan : AppColors.textSecondary,
          fontSize: 12,
        ),
        onSelected: (_) => notifier.setSnippetType(type),
      ),
    );
  }

  Widget _buildHealthPingBadge(DateTime? lastPing) {
    if (lastPing == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.obsidianSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.obsidianBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.fiber_manual_record, color: AppColors.textMuted, size: 10),
            SizedBox(width: 6),
            Text('Inactive — No pings yet', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    final diffSeconds = DateTime.now().difference(lastPing).inSeconds;
    final timeStr = diffSeconds < 60 ? '$diffSeconds sec ago' : '${(diffSeconds / 60).round()} min ago';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.emeraldGreen.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha:0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: AppColors.emeraldGreen, size: 10),
          const SizedBox(width: 6),
          Text('Active — Last ping $timeStr',
              style: const TextStyle(color: AppColors.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
