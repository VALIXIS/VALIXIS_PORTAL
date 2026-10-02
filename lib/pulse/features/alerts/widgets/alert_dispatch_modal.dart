import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/alert_payload.dart';
import '../services/alert_dispatcher_service.dart';

/// Modal dialog allowing executives to preview and dispatch multi-channel Slack/Teams alerts
class AlertDispatchModal extends StatefulWidget {
  final AlertPayload? initialPayload;
  final AlertDispatcherService? dispatcherService;

  const AlertDispatchModal({
    super.key,
    this.initialPayload,
    this.dispatcherService,
  });

  static Future<DispatchResult?> show(
    BuildContext context, {
    AlertPayload? payload,
    AlertDispatcherService? service,
  }) {
    return showDialog<DispatchResult>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDispatchModal(
        initialPayload: payload,
        dispatcherService: service,
      ),
    );
  }

  @override
  State<AlertDispatchModal> createState() => _AlertDispatchModalState();
}

class _AlertDispatchModalState extends State<AlertDispatchModal> with SingleTickerProviderStateMixin {
  late AlertPayload _payload;
  late AlertDispatcherService _dispatcher;
  late TabController _tabController;

  final TextEditingController _slackUrlController = TextEditingController();
  final TextEditingController _teamsUrlController = TextEditingController();

  bool _isDispatching = false;
  DispatchResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _payload = widget.initialPayload ?? AlertPayload.sample();
    _dispatcher = widget.dispatcherService ?? AlertDispatcherService();
    _tabController = TabController(length: 2, vsync: this);

    _slackUrlController.text = _payload.slackWebhookUrl ?? '';
    _teamsUrlController.text = _payload.teamsWebhookUrl ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slackUrlController.dispose();
    _teamsUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleDispatch() async {
    setState(() {
      _isDispatching = true;
      _lastResult = null;
    });

    final updatedPayload = AlertPayload(
      id: _payload.id,
      orgId: _payload.orgId,
      incidentId: _payload.incidentId,
      title: _payload.title,
      description: _payload.description,
      severity: _payload.severity,
      metricName: _payload.metricName,
      metricValue: _payload.metricValue,
      timestamp: _payload.timestamp,
      slackWebhookUrl: _slackUrlController.text.trim().isEmpty ? null : _slackUrlController.text.trim(),
      teamsWebhookUrl: _teamsUrlController.text.trim().isEmpty ? null : _teamsUrlController.text.trim(),
      remediationUrl: _payload.remediationUrl,
    );

    final result = await _dispatcher.dispatchAlert(updatedPayload);

    if (mounted) {
      setState(() {
        _isDispatching = false;
        _lastResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _payload.severity == 'CRITICAL'
        ? const Color(0xFFEF4444)
        : (_payload.severity == 'WARNING' ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF0D111A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF131825),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _payload.severity == 'CRITICAL'
                          ? Icons.warning_amber_rounded
                          : Icons.notifications_active_rounded,
                      color: themeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MULTI-CHANNEL ALERT DISPATCHER',
                          style: TextStyle(
                            color: Color(0xFF00F2FE),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          _payload.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(_lastResult),
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
                    // INCIDENT SUMMARY BADGES
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07090E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildBadge('INCIDENT ID: ${_payload.incidentId}', Colors.white70),
                              _buildBadge('SEVERITY: ${_payload.severity}', themeColor),
                              _buildBadge('ORG: ${_payload.orgId}', Colors.cyanAccent),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _payload.description,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // WEBHOOK INPUT FIELDS
                    const Text(
                      'WEBHOOK ENDPOINTS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _slackUrlController,
                      label: 'Slack Webhook URL',
                      icon: Icons.chat_bubble_outline_rounded,
                      accentColor: const Color(0xFFE01E5A),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _teamsUrlController,
                      label: 'MS Teams Webhook URL',
                      icon: Icons.groups_rounded,
                      accentColor: const Color(0xFF6264A7),
                    ),
                    const SizedBox(height: 20),

                    // PAYLOAD PREVIEW TABS
                    const Text(
                      'LIVE PAYLOAD FORMATTER PREVIEW',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFF00F2FE),
                      labelColor: const Color(0xFF00F2FE),
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Slack Block Kit JSON'),
                        Tab(text: 'MS Teams Adaptive Card'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 160,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCodePreview(_payload.toSlackBlockKitJson()),
                          _buildCodePreview(_payload.toTeamsAdaptiveCardJson()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DISPATCH RESULTS BANNER
                    if (_lastResult != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _lastResult!.success
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _lastResult!.success ? const Color(0xFF10B981) : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _lastResult!.success
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: _lastResult!.success ? const Color(0xFF10B981) : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _lastResult!.success
                                    ? 'Alert Dispatched Successfully! Statuses: ${_lastResult!.channelStatuses}'
                                    : 'Dispatch Failed: ${_lastResult!.errorMessage}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                color: Color(0xFF131825),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(_lastResult),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isDispatching ? null : _handleDispatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: _isDispatching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isDispatching ? 'Dispatching...' : 'Dispatch Alert Now',
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

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accentColor,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        prefixIcon: Icon(icon, color: accentColor, size: 18),
        filled: true,
        fillColor: const Color(0xFF07090E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
      ),
    );
  }

  Widget _buildCodePreview(Map<String, dynamic> jsonMap) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(jsonMap);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF07090E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        child: Text(
          prettyJson,
          style: const TextStyle(
            color: Color(0xFF00E676),
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
