/// Multi-Channel Executive Alert Payload for Slack Block Kit & MS Teams Adaptive Cards
class AlertPayload {
  final String id;
  final String orgId;
  final String incidentId;
  final String title;
  final String description;
  final String severity; // 'CRITICAL', 'WARNING', 'INFO'
  final String metricName;
  final String metricValue;
  final DateTime timestamp;
  final String? slackWebhookUrl;
  final String? teamsWebhookUrl;
  final String? remediationUrl;

  AlertPayload({
    required this.id,
    required this.orgId,
    required this.incidentId,
    required this.title,
    required this.description,
    required this.severity,
    required this.metricName,
    required this.metricValue,
    required this.timestamp,
    this.slackWebhookUrl,
    this.teamsWebhookUrl,
    this.remediationUrl,
  });

  /// Factory sample for testing & UI preview
  factory AlertPayload.sample({
    String severity = 'CRITICAL',
    String? slackUrl,
    String? teamsUrl,
  }) {
    return AlertPayload(
      id: 'alt_${DateTime.now().millisecondsSinceEpoch}',
      orgId: 'org_valixis_01',
      incidentId: 'inc_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: severity == 'CRITICAL'
          ? 'ARR Velocity Drop & SLA Breach'
          : 'High Webhook Error Rate Warning',
      description: severity == 'CRITICAL'
          ? 'ARR growth rate dropped by 18.4% over 6h window due to failed enterprise renewal webhooks.'
          : 'Webhook retry count crossed 15 retries in 15m period.',
      severity: severity,
      metricName: 'ARR Growth / Gateway SLA',
      metricValue: severity == 'CRITICAL' ? '\$1.28M (-18.4%)' : '94.2% Uptime',
      timestamp: DateTime.now(),
      slackWebhookUrl: slackUrl ?? 'https://hooks.slack.com/services/VALIXIS/PULSE/TEST',
      teamsWebhookUrl: teamsUrl ?? 'https://outlook.office.com/webhook/VALIXIS/PULSE/TEST',
      remediationUrl: 'https://pulse.valixis.io/incidents/inc_77492',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orgId': orgId,
      'incidentId': incidentId,
      'title': title,
      'description': description,
      'severity': severity,
      'metricName': metricName,
      'metricValue': metricValue,
      'timestamp': timestamp.toIso8601String(),
      'slackWebhookUrl': slackWebhookUrl,
      'teamsWebhookUrl': teamsWebhookUrl,
      'remediationUrl': remediationUrl,
    };
  }

  factory AlertPayload.fromJson(Map<String, dynamic> json) {
    return AlertPayload(
      id: json['id'] as String? ?? 'alt_unknown',
      orgId: json['orgId'] as String? ?? 'org_valixis_01',
      incidentId: json['incidentId'] as String? ?? 'inc_0000',
      title: json['title'] as String? ?? 'Pulse Alert',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'WARNING',
      metricName: json['metricName'] as String? ?? 'Telemetry Metric',
      metricValue: json['metricValue'] as String? ?? 'N/A',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      slackWebhookUrl: json['slackWebhookUrl'] as String?,
      teamsWebhookUrl: json['teamsWebhookUrl'] as String?,
      remediationUrl: json['remediationUrl'] as String?,
    );
  }

  /// Builds Slack Block Kit JSON representation
  Map<String, dynamic> toSlackBlockKitJson() {
    final emoji = severity == 'CRITICAL' ? '🚨' : (severity == 'WARNING' ? '⚠️' : 'ℹ️');
    final color = severity == 'CRITICAL' ? '#EF4444' : (severity == 'WARNING' ? '#F59E0B' : '#10B981');

    return {
      'attachments': [
        {
          'color': color,
          'blocks': [
            {
              'type': 'header',
              'text': {
                'type': 'plain_text',
                'text': '$emoji [VALIXIS Pulse] Alert: $title',
                'emoji': true,
              },
            },
            {
              'type': 'section',
              'text': {
                'type': 'mrkdwn',
                'text': '*Description:* $description',
              },
            },
            {
              'type': 'section',
              'fields': [
                {'type': 'mrkdwn', 'text': '*Organization:* `$orgId`'},
                {'type': 'mrkdwn', 'text': '*Severity:* *$severity*'},
                {'type': 'mrkdwn', 'text': '*Metric:* $metricName'},
                {'type': 'mrkdwn', 'text': '*Value:* *$metricValue*'},
              ],
            },
            {
              'type': 'actions',
              'elements': [
                {
                  'type': 'button',
                  'text': {
                    'type': 'plain_text',
                    'text': '⚡ Trigger Self-Healing Flow',
                    'emoji': true,
                  },
                  'style': 'primary',
                  'url': remediationUrl ?? 'https://pulse.valixis.io/incidents/$incidentId',
                },
                {
                  'type': 'button',
                  'text': {
                    'type': 'plain_text',
                    'text': '📊 Open Pulse Wallboard',
                    'emoji': true,
                  },
                  'url': 'https://pulse.valixis.io/wallboard',
                },
              ],
            },
          ],
        }
      ],
    };
  }

  /// Builds Microsoft Teams MessageCard / Adaptive Card JSON representation
  Map<String, dynamic> toTeamsAdaptiveCardJson() {
    final themeColor = severity == 'CRITICAL' ? 'EF4444' : (severity == 'WARNING' ? 'F59E0B' : '10B981');

    return {
      '@type': 'MessageCard',
      '@context': 'http://schema.org/extensions',
      'themeColor': themeColor,
      'summary': '[VALIXIS Pulse] $severity: $title',
      'sections': [
        {
          'activityTitle': '🚨 VALIXIS Pulse Incident Alert: $title',
          'activitySubtitle': 'Org ID: $orgId | Severity: $severity',
          'activityImage': 'https://pulse.valixis.io/assets/pulse-logo.png',
          'facts': [
            {'name': 'Incident ID', 'value': incidentId},
            {'name': 'Severity', 'value': severity},
            {'name': 'Metric Affected', 'value': metricName},
            {'name': 'Current Value', 'value': metricValue},
          ],
          'text': description,
        },
      ],
      'potentialAction': [
        {
          '@type': 'OpenUri',
          'name': '⚡ Trigger Remediate Flow',
          'targets': [
            {
              'os': 'default',
              'uri': remediationUrl ?? 'https://pulse.valixis.io/incidents/$incidentId',
            }
          ],
        },
        {
          '@type': 'OpenUri',
          'name': '📊 View Pulse Wallboard',
          'targets': [
            {
              'os': 'default',
              'uri': 'https://pulse.valixis.io/wallboard',
            }
          ],
        },
      ],
    };
  }
}
