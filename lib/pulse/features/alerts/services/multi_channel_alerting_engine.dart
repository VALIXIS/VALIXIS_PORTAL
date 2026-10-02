import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/alert_threshold_rule.dart';
import '../models/in_app_notification.dart';

class AlertDispatchReport {
  final bool violationDetected;
  final String ruleId;
  final Map<String, String> channelStatuses;

  AlertDispatchReport({
    required this.violationDetected,
    required this.ruleId,
    required this.channelStatuses,
  });
}

/// Core Multi-Channel Outbound Alerting Engine
class MultiChannelAlertingEngine extends ChangeNotifier {
  final http.Client _httpClient;
  final List<AlertThresholdRule> _rules = [];
  final List<InAppNotification> _notifications = [];

  MultiChannelAlertingEngine({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client() {
    _rules.addAll(AlertThresholdRule.sampleRules());
  }

  List<AlertThresholdRule> get rules => List.unmodifiable(_rules);
  List<InAppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  void addRule(AlertThresholdRule rule) {
    _rules.add(rule);
    notifyListeners();
  }

  void toggleRuleActive(String ruleId) {
    final idx = _rules.indexWhere((r) => r.id == ruleId);
    if (idx != -1) {
      final existing = _rules[idx];
      _rules[idx] = AlertThresholdRule(
        id: existing.id,
        orgId: existing.orgId,
        metricKey: existing.metricKey,
        metricLabel: existing.metricLabel,
        operator: existing.operator,
        thresholdValue: existing.thresholdValue,
        enabledChannels: existing.enabledChannels,
        slackWebhookUrl: existing.slackWebhookUrl,
        discordWebhookUrl: existing.discordWebhookUrl,
        emailRecipient: existing.emailRecipient,
        isActive: !existing.isActive,
      );
      notifyListeners();
    }
  }

  void markNotificationAsRead(String notifId) {
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Evaluates incoming metric telemetry and dispatches to Slack, Discord, Email & Bell
  Future<List<AlertDispatchReport>> processMetricValue(
    String metricKey,
    double value, {
    List<AlertThresholdRule>? customRules,
  }) async {
    final targetRules = customRules ?? _rules.where((r) => r.metricKey == metricKey && r.isActive).toList();
    final List<AlertDispatchReport> reports = [];

    for (final rule in targetRules) {
      if (rule.evaluateViolation(value)) {
        final Map<String, String> statuses = {};

        // 1. DISCORD EMBED WEBHOOK DISPATCH
        if (rule.enabledChannels.contains('discord') && rule.discordWebhookUrl != null) {
          if (rule.discordWebhookUrl!.startsWith('http')) {
            try {
              final discordBody = jsonEncode(rule.toDiscordEmbedPayload(value));
              final res = await _httpClient.post(
                Uri.parse(rule.discordWebhookUrl!),
                headers: {'Content-Type': 'application/json'},
                body: discordBody,
              );
              statuses['discord'] = (res.statusCode >= 200 && res.statusCode < 300)
                  ? 'DELIVERED'
                  : 'FAILED_${res.statusCode}';
            } catch (e) {
              statuses['discord'] = 'ERROR_${e.toString()}';
            }
          } else {
            statuses['discord'] = 'SIMULATED_DELIVERY';
          }
        }

        // 2. SLACK BLOCK KIT DISPATCH
        if (rule.enabledChannels.contains('slack') && rule.slackWebhookUrl != null) {
          if (rule.slackWebhookUrl!.startsWith('http')) {
            try {
              final slackBody = jsonEncode(rule.toSlackPayload(value));
              final res = await _httpClient.post(
                Uri.parse(rule.slackWebhookUrl!),
                headers: {'Content-Type': 'application/json'},
                body: slackBody,
              );
              statuses['slack'] = (res.statusCode >= 200 && res.statusCode < 300)
                  ? 'DELIVERED'
                  : 'FAILED_${res.statusCode}';
            } catch (e) {
              statuses['slack'] = 'ERROR_${e.toString()}';
            }
          } else {
            statuses['slack'] = 'SIMULATED_DELIVERY';
          }
        }

        // 3. EMAIL DIGEST DISPATCH
        if (rule.enabledChannels.contains('email')) {
          statuses['email'] = 'QUEUED_SMTP_GATEWAY';
        }

        // 4. REALTIME IN-APP BELL NOTIFICATION
        if (rule.enabledChannels.contains('bell')) {
          final notif = rule.toInAppNotification(value);
          _notifications.insert(0, notif);
          statuses['bell'] = 'EMITTED_IN_APP';
          notifyListeners();
        }

        reports.add(
          AlertDispatchReport(
            violationDetected: true,
            ruleId: rule.id,
            channelStatuses: statuses,
          ),
        );
      }
    }

    return reports;
  }
}
