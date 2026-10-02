import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert_payload.dart';

/// Dispatch Result containing status per channel
class DispatchResult {
  final bool success;
  final String incidentId;
  final Map<String, String> channelStatuses;
  final String? errorMessage;

  DispatchResult({
    required this.success,
    required this.incidentId,
    required this.channelStatuses,
    this.errorMessage,
  });

  factory DispatchResult.fromJson(Map<String, dynamic> json) {
    return DispatchResult(
      success: json['success'] as bool? ?? false,
      incidentId: json['incidentId'] as String? ?? '',
      channelStatuses: Map<String, String>.from(json['channels'] as Map? ?? {}),
      errorMessage: json['error'] as String?,
    );
  }
}

/// Service handling autonomous multi-channel alert dispatching to Slack & MS Teams
class AlertDispatcherService {
  final http.Client _httpClient;
  final String edgeFunctionUrl;

  AlertDispatcherService({
    http.Client? httpClient,
    this.edgeFunctionUrl = 'https://valixis.supabase.co/functions/v1/alert-dispatcher',
  }) : _httpClient = httpClient ?? http.Client();

  /// Dispatches alert payload to Slack and MS Teams webhooks directly or via Edge Function
  Future<DispatchResult> dispatchAlert(AlertPayload payload) async {
    final Map<String, String> channelStatuses = {};

    try {
      // 1. Dispatch Slack if configured
      if (payload.slackWebhookUrl != null && payload.slackWebhookUrl!.isNotEmpty) {
        if (payload.slackWebhookUrl!.startsWith('http')) {
          try {
            final slackBody = jsonEncode(payload.toSlackBlockKitJson());
            final res = await _httpClient.post(
              Uri.parse(payload.slackWebhookUrl!),
              headers: {'Content-Type': 'application/json'},
              body: slackBody,
            );
            channelStatuses['slack'] = res.statusCode >= 200 && res.statusCode < 300
                ? 'DELIVERED'
                : 'FAILED_${res.statusCode}';
          } catch (e) {
            channelStatuses['slack'] = 'ERROR_${e.toString()}';
          }
        } else {
          channelStatuses['slack'] = 'SIMULATED_SUCCESS';
        }
      }

      // 2. Dispatch Teams if configured
      if (payload.teamsWebhookUrl != null && payload.teamsWebhookUrl!.isNotEmpty) {
        if (payload.teamsWebhookUrl!.startsWith('http')) {
          try {
            final teamsBody = jsonEncode(payload.toTeamsAdaptiveCardJson());
            final res = await _httpClient.post(
              Uri.parse(payload.teamsWebhookUrl!),
              headers: {'Content-Type': 'application/json'},
              body: teamsBody,
            );
            channelStatuses['teams'] = res.statusCode >= 200 && res.statusCode < 300
                ? 'DELIVERED'
                : 'FAILED_${res.statusCode}';
          } catch (e) {
            channelStatuses['teams'] = 'ERROR_${e.toString()}';
          }
        } else {
          channelStatuses['teams'] = 'SIMULATED_SUCCESS';
        }
      }

      return DispatchResult(
        success: true,
        incidentId: payload.incidentId,
        channelStatuses: channelStatuses,
      );
    } catch (err) {
      return DispatchResult(
        success: false,
        incidentId: payload.incidentId,
        channelStatuses: channelStatuses,
        errorMessage: err.toString(),
      );
    }
  }

  /// Dispatches alert payload via Supabase Edge Function
  Future<DispatchResult> dispatchViaEdgeFunction(AlertPayload payload) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return DispatchResult.fromJson(data);
      } else {
        return DispatchResult(
          success: false,
          incidentId: payload.incidentId,
          channelStatuses: {},
          errorMessage: 'Edge function returned HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return DispatchResult(
        success: false,
        incidentId: payload.incidentId,
        channelStatuses: {},
        errorMessage: e.toString(),
      );
    }
  }
}
