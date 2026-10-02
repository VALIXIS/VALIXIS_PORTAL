import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../models/alert_threshold_rule.dart';
import '../services/multi_channel_alerting_engine.dart';

/// Configuration Modal for Admins to Toggle Channels & Define Threshold Rules
class AlertThresholdConfigModal extends StatefulWidget {
  final MultiChannelAlertingEngine engine;

  const AlertThresholdConfigModal({
    super.key,
    required this.engine,
  });

  static Future<void> show(BuildContext context, MultiChannelAlertingEngine engine) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertThresholdConfigModal(engine: engine),
    );
  }

  @override
  State<AlertThresholdConfigModal> createState() => _AlertThresholdConfigModalState();
}

class _AlertThresholdConfigModalState extends State<AlertThresholdConfigModal> {
  final TextEditingController _metricKeyController = TextEditingController(text: 'system_latency_p95');
  final TextEditingController _metricLabelController = TextEditingController(text: 'Custom Latency Rule');
  final TextEditingController _thresholdController = TextEditingController(text: '500');
  String _selectedOperator = '>';

  final Set<String> _selectedChannels = {'slack', 'discord', 'email', 'bell'};

  bool _isTesting = false;
  List<AlertDispatchReport>? _testReports;

  @override
  void dispose() {
    _metricKeyController.dispose();
    _metricLabelController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _handleTestDispatch() async {
    setState(() {
      _isTesting = true;
      _testReports = null;
    });

    final val = double.tryParse(_thresholdController.text) ?? 500.0;
    // Simulate a breach value (e.g. threshold + 50)
    final breachValue = val + 50.0;

    final reports = await widget.engine.processMetricValue(
      _metricKeyController.text.trim(),
      breachValue,
    );

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testReports = reports;
      });
    }
  }

  void _addNewRule() {
    final thresholdVal = double.tryParse(_thresholdController.text) ?? 100.0;
    final newRule = AlertThresholdRule(
      id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
      orgId: 'org_valixis_01',
      metricKey: _metricKeyController.text.trim(),
      metricLabel: _metricLabelController.text.trim(),
      operator: _selectedOperator,
      thresholdValue: thresholdVal,
      enabledChannels: Set<String>.from(_selectedChannels),
      slackWebhookUrl: 'https://hooks.slack.com/services/VALIXIS/PULSE/TEST',
      discordWebhookUrl: 'https://discord.com/api/webhooks/VALIXIS/PULSE/TEST',
      emailRecipient: 'alerts@valixis.io',
    );

    widget.engine.addRule(newRule);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Alert Threshold Rule Saved Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 700,
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
                    child: const Icon(Icons.settings_suggest, color: PulseColors.electricCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MULTI-CHANNEL ALERTING ENGINE GATEWAY',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PulseColors.electricCyan,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          'Configure Outbound Webhooks & Metric Violation Threshold Rules',
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

            // BODY CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ACTIVE RULES LIST
                    const Text(
                      'ACTIVE THRESHOLD RULES',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListenableBuilder(
                      listenable: widget.engine,
                      builder: (context, _) {
                        final rules = widget.engine.rules;
                        return Column(
                          children: rules.map((rule) => _buildRuleItem(rule)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // CREATE NEW RULE SECTION
                    const Text(
                      'DEFINE THRESHOLD RULE',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PulseColors.cardObsidian,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PulseColors.cardGlassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _metricLabelController,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: const InputDecoration(
                                    labelText: 'Rule Label',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                value: _selectedOperator,
                                dropdownColor: PulseColors.cardObsidian,
                                items: ['>', '>=', '<', '<=', '='].map((op) {
                                  return DropdownMenuItem(
                                    value: op,
                                    child: Text(op, style: const TextStyle(color: PulseColors.electricCyan)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedOperator = val);
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _thresholdController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: const InputDecoration(
                                    labelText: 'Threshold',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // CHANNEL TOGGLES
                          const Text(
                            'ENABLED OUTBOUND CHANNELS',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PulseColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildChannelChip('slack', 'Slack Block Kit', Icons.chat_bubble_outline),
                              _buildChannelChip('discord', 'Discord Embeds', Icons.discord),
                              _buildChannelChip('email', 'Email Gateway', Icons.email_outlined),
                              _buildChannelChip('bell', 'In-App Bell', Icons.notifications_active),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _addNewRule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PulseColors.electricCyan,
                                foregroundColor: Colors.black,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Save Rule', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TEST PAYLOAD DISPATCH FEEDBACK
                    if (_testReports != null && _testReports!.isNotEmpty) ...[
                      const Text(
                        'TEST DISPATCH RESULTS',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PulseColors.emeraldGrowth,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._testReports!.map((rep) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PulseColors.emeraldGrowth.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PulseColors.emeraldGrowth),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Violation Detected for Rule ID: ${rep.ruleId}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Channel Statuses: ${rep.channelStatuses}',
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  color: PulseColors.emeraldGrowth,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isTesting ? null : _handleTestDispatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PulseColors.coralRedAlert,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isTesting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.bug_report, size: 18),
                      label: Text(_isTesting ? 'Testing...' : 'Simulate Threshold Violation Test'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('Close Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(AlertThresholdRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PulseColors.cardObsidian,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rule.isActive ? PulseColors.cardGlassBorder : Colors.white12),
      ),
      child: Row(
        children: [
          Switch(
            value: rule.isActive,
            activeColor: PulseColors.electricCyan,
            onChanged: (_) => widget.engine.toggleRuleActive(rule.id),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.metricLabel,
                  style: TextStyle(
                    color: rule.isActive ? Colors.white : Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Condition: ${rule.operator} ${rule.thresholdValue} | Channels: ${rule.enabledChannels.join(", ")}',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    color: PulseColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelChip(String channelKey, String label, IconData icon) {
    final isSelected = _selectedChannels.contains(channelKey);
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isSelected ? PulseColors.electricCyan : Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11)),
        ],
      ),
      selectedColor: PulseColors.electricCyan.withOpacity(0.2),
      backgroundColor: PulseColors.surfaceObsidian,
      onSelected: (sel) {
        setState(() {
          if (sel) {
            _selectedChannels.add(channelKey);
          } else {
            _selectedChannels.remove(channelKey);
          }
        });
      },
    );
  }
}
