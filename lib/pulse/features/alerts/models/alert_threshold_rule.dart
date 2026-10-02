import 'in_app_notification.dart';

/// Configurable Metric Threshold Rule for Outbound Notification Gateway
class AlertThresholdRule {
  final String id;
  final String orgId;
  final String metricKey; // e.g. 'system_latency_p95', 'churn_risk_score', 'arr_drop_percentage'
  final String metricLabel;
  final String operator; // '>', '>=', '<', '<=', '='
  final double thresholdValue;
  final Set<String> enabledChannels; // 'slack', 'discord', 'email', 'bell'
  final String? slackWebhookUrl;
  final String? discordWebhookUrl;
  final String? emailRecipient;
  final bool isActive;

  AlertThresholdRule({
    required this.id,
    required this.orgId,
    required this.metricKey,
    required this.metricLabel,
    required this.operator,
    required this.thresholdValue,
    required this.enabledChannels,
    this.slackWebhookUrl,
    this.discordWebhookUrl,
    this.emailRecipient,
    this.isActive = true,
  });

  /// Factory sample rules for testing & initialization
  static List<AlertThresholdRule> sampleRules() {
    return [
      AlertThresholdRule(
        id: 'rule_latency_01',
        orgId: 'org_valixis_01',
        metricKey: 'system_latency_p95',
        metricLabel: 'Gateway Latency (p95)',
        operator: '>',
        thresholdValue: 500.0, // 500ms SLA threshold
        enabledChannels: {'slack', 'discord', 'email', 'bell'},
        slackWebhookUrl: 'https://hooks.slack.com/services/VALIXIS/PULSE/LATENCY',
        discordWebhookUrl: 'https://discord.com/api/webhooks/VALIXIS/PULSE/LATENCY',
        emailRecipient: 'alerts@valixis.io',
      ),
      AlertThresholdRule(
        id: 'rule_churn_02',
        orgId: 'org_valixis_01',
        metricKey: 'churn_risk_score',
        metricLabel: 'Account Churn Risk Score',
        operator: '>=',
        thresholdValue: 70.0, // 70% churn risk threshold
        enabledChannels: {'slack', 'discord', 'bell'},
        slackWebhookUrl: 'https://hooks.slack.com/services/VALIXIS/PULSE/CHURN',
        discordWebhookUrl: 'https://discord.com/api/webhooks/VALIXIS/PULSE/CHURN',
        emailRecipient: 'executives@valixis.io',
      ),
    ];
  }

  /// Evaluates whether a current metric value violates this threshold rule
  bool evaluateViolation(double currentValue) {
    if (!isActive) return false;
    switch (operator) {
      case '>':
        return currentValue > thresholdValue;
      case '>=':
        return currentValue >= thresholdValue;
      case '<':
        return currentValue < thresholdValue;
      case '<=':
        return currentValue <= thresholdValue;
      case '=':
      case '==':
        return currentValue == thresholdValue;
      default:
        return currentValue > thresholdValue;
    }
  }

  /// Formats Slack Block Kit Payload
  Map<String, dynamic> toSlackPayload(double observedValue) {
    return {
      'attachments': [
        {
          'color': '#EF4444',
          'blocks': [
            {
              'type': 'header',
              'text': {
                'type': 'plain_text',
                'text': '🚨 [VALIXIS Pulse] Threshold Violation: $metricLabel',
                'emoji': true,
              },
            },
            {
              'type': 'section',
              'text': {
                'type': 'mrkdwn',
                'text':
                    '*Metric Value Breached:* `$observedValue` (Threshold: `$operator $thresholdValue`)',
              },
            },
            {
              'type': 'section',
              'fields': [
                {'type': 'mrkdwn', 'text': '*Org:* `$orgId`'},
                {'type': 'mrkdwn', 'text': '*Rule ID:* `$id`'},
              ],
            },
            {
              'type': 'actions',
              'elements': [
                {
                  'type': 'button',
                  'text': {'type': 'plain_text', 'text': '⚡ Open Pulse Dashboard'},
                  'style': 'primary',
                  'url': 'https://pulse.valixis.io',
                },
              ],
            },
          ],
        },
      ],
    };
  }

  /// Formats Discord Embed Payload
  Map<String, dynamic> toDiscordEmbedPayload(double observedValue) {
    return {
      'username': 'VALIXIS Pulse Alerting Core',
      'avatar_url': 'https://pulse.valixis.io/assets/pulse-logo.png',
      'embeds': [
        {
          'title': '🚨 Threshold Violation Alert: $metricLabel',
          'description':
              'Operational telemetry metric has breached configured SLA thresholds.',
          'color': 15158332, // Red hex integer #EF4444
          'fields': [
            {
              'name': 'Observed Value',
              'value': '$observedValue',
              'inline': true,
            },
            {
              'name': 'Rule Condition',
              'value': '$operator $thresholdValue',
              'inline': true,
            },
            {
              'name': 'Organization ID',
              'value': orgId,
              'inline': true,
            },
          ],
          'footer': {
            'text': 'VALIXIS Pulse Telemetry Engine • Rule: $id',
          },
          'timestamp': DateTime.now().toIso8601String(),
        },
      ],
    };
  }

  /// Formats Email Payload
  Map<String, dynamic> toEmailPayload(double observedValue) {
    return {
      'to': emailRecipient ?? 'executives@valixis.io',
      'subject': '[ALERT] $metricLabel Breached SLA Threshold',
      'body': '''
<h2>VALIXIS Pulse Operational Alert</h2>
<p><strong>Metric:</strong> $metricLabel</p>
<p><strong>Observed Value:</strong> <span style="color: #EF4444; font-weight: bold;">$observedValue</span> (Condition: $operator $thresholdValue)</p>
<p><strong>Org ID:</strong> $orgId</p>
<p><a href="https://pulse.valixis.io" style="background: #00F2FE; color: #000; padding: 10px 16px; text-decoration: none; border-radius: 6px; font-weight: bold;">Open Executive Dashboard</a></p>
''',
    };
  }

  /// Formats Realtime Bell InAppNotification
  InAppNotification toInAppNotification(double observedValue) {
    return InAppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      orgId: orgId,
      ruleId: id,
      title: 'THREAT ALERT: $metricLabel',
      message:
          'Observed value $observedValue breached SLA rule ($operator $thresholdValue).',
      severity: 'CRITICAL',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'metric_key': metricKey,
      'metric_label': metricLabel,
      'operator': operator,
      'threshold_value': thresholdValue,
      'enabled_channels': enabledChannels.toList(),
      'slack_webhook_url': slackWebhookUrl,
      'discord_webhook_url': discordWebhookUrl,
      'email_recipient': emailRecipient,
      'is_active': isActive,
    };
  }

  factory AlertThresholdRule.fromJson(Map<String, dynamic> json) {
    return AlertThresholdRule(
      id: json['id'] as String? ?? 'rule_00',
      orgId: json['org_id'] as String? ?? 'org_valixis_01',
      metricKey: json['metric_key'] as String? ?? 'system_latency_p95',
      metricLabel: json['metric_label'] as String? ?? 'Telemetry Metric',
      operator: json['operator'] as String? ?? '>',
      thresholdValue: (json['threshold_value'] as num?)?.toDouble() ?? 100.0,
      enabledChannels: Set<String>.from(json['enabled_channels'] as List? ?? ['slack', 'discord', 'email', 'bell']),
      slackWebhookUrl: json['slack_webhook_url'] as String?,
      discordWebhookUrl: json['discord_webhook_url'] as String?,
      emailRecipient: json['email_recipient'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
