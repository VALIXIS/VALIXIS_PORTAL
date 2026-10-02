import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/webhook_template.dart';

enum SnippetType { curl, fetch, python }

class WebhookSimulatorState {
  final String webhookSlug;
  final String secretToken;
  final bool isTokenVisible;
  final WebhookTemplate selectedTemplate;
  final String jsonBody;
  final String? jsonError;
  final bool isSending;
  final int? lastStatusCode;
  final int? lastLatencyMs;
  final String? lastResponsePayload;
  final DateTime? lastPingTime;
  final SnippetType activeSnippetType;

  const WebhookSimulatorState({
    required this.webhookSlug,
    required this.secretToken,
    required this.isTokenVisible,
    required this.selectedTemplate,
    required this.jsonBody,
    this.jsonError,
    required this.isSending,
    this.lastStatusCode,
    this.lastLatencyMs,
    this.lastResponsePayload,
    this.lastPingTime,
    required this.activeSnippetType,
  });

  String get webhookUrl =>
      'https://valixis-flow.supabase.co/functions/v1/flow-webhook/$webhookSlug';

  WebhookSimulatorState copyWith({
    String? webhookSlug,
    String? secretToken,
    bool? isTokenVisible,
    WebhookTemplate? selectedTemplate,
    String? jsonBody,
    String? jsonError,
    bool? isSending,
    int? lastStatusCode,
    int? lastLatencyMs,
    String? lastResponsePayload,
    DateTime? lastPingTime,
    SnippetType? activeSnippetType,
  }) {
    return WebhookSimulatorState(
      webhookSlug: webhookSlug ?? this.webhookSlug,
      secretToken: secretToken ?? this.secretToken,
      isTokenVisible: isTokenVisible ?? this.isTokenVisible,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      jsonBody: jsonBody ?? this.jsonBody,
      jsonError: jsonError,
      isSending: isSending ?? this.isSending,
      lastStatusCode: lastStatusCode ?? this.lastStatusCode,
      lastLatencyMs: lastLatencyMs ?? this.lastLatencyMs,
      lastResponsePayload: lastResponsePayload ?? this.lastResponsePayload,
      lastPingTime: lastPingTime ?? this.lastPingTime,
      activeSnippetType: activeSnippetType ?? this.activeSnippetType,
    );
  }
}

class WebhookSimulatorNotifier extends StateNotifier<WebhookSimulatorState> {
  WebhookSimulatorNotifier()
      : super(
          WebhookSimulatorState(
            webhookSlug: 'inbound-leads-99',
            secretToken: 'whsec_valixis_77a982f1b4c300e1',
            isTokenVisible: false,
            selectedTemplate: WebhookTemplate.sampleTemplates.first,
            jsonBody: WebhookTemplate.sampleTemplates.first.prettyJson,
            isSending: false,
            activeSnippetType: SnippetType.curl,
          ),
        );

  void toggleTokenVisibility() {
    state = state.copyWith(isTokenVisible: !state.isTokenVisible);
  }

  void regenerateSecretToken() {
    final randomHex = Hmac(sha256, utf8.encode(DateTime.now().toIso8601String()))
        .convert(utf8.encode('valixis_secret_${DateTime.now().millisecondsSinceEpoch}'))
        .toString()
        .substring(0, 16);
    state = state.copyWith(secretToken: 'whsec_valixis_$randomHex');
  }

  void selectTemplate(WebhookTemplate template) {
    state = state.copyWith(
      selectedTemplate: template,
      jsonBody: template.prettyJson,
      jsonError: null,
    );
  }

  void setJsonBody(String body) {
    String? error;
    try {
      json.decode(body);
    } catch (e) {
      error = 'Invalid JSON syntax: ${e.toString()}';
    }
    state = state.copyWith(jsonBody: body, jsonError: error);
  }

  void setSnippetType(SnippetType type) {
    state = state.copyWith(activeSnippetType: type);
  }

  String generateSnippet() {
    final url = state.webhookUrl;
    final token = state.secretToken;
    final body = state.jsonBody.replaceAll('\n', ' ');

    switch (state.activeSnippetType) {
      case SnippetType.curl:
        return 'curl -X POST "$url" \\\n'
            '  -H "Content-Type: application/json" \\\n'
            '  -H "X-Valixis-Signature: $token" \\\n'
            '  -d \'$body\'';
      case SnippetType.fetch:
        return 'fetch("$url", {\n'
            '  method: "POST",\n'
            '  headers: {\n'
            '    "Content-Type": "application/json",\n'
            '    "X-Valixis-Signature": "$token"\n'
            '  },\n'
            '  body: JSON.stringify($body)\n'
            '});';
      case SnippetType.python:
        return 'import requests\n\n'
            'url = "$url"\n'
            'headers = {\n'
            '    "Content-Type": "application/json",\n'
            '    "X-Valixis-Signature": "$token"\n'
            '}\n'
            'payload = $body\n'
            'response = requests.post(url, headers=headers, json=payload)';
    }
  }

  Future<void> sendTestPayload() async {
    if (state.jsonError != null) return;

    state = state.copyWith(isSending: true);
    final stopwatch = Stopwatch()..start();

    await Future<void>.delayed(const Duration(milliseconds: 110));
    stopwatch.stop();

    final executionId = 'exec_${DateTime.now().millisecondsSinceEpoch}';
    final responsePayload = const JsonEncoder.withIndent('  ').convert({
      'status': 'accepted',
      'execution_id': executionId,
      'received_at': DateTime.now().toIso8601String(),
      'ingestion_latency_ms': stopwatch.elapsedMilliseconds,
      'idempotency_key': 'idx_sha256_${executionId.substring(5)}',
    });

    state = state.copyWith(
      isSending: false,
      lastStatusCode: 200,
      lastLatencyMs: stopwatch.elapsedMilliseconds,
      lastResponsePayload: responsePayload,
      lastPingTime: DateTime.now(),
    );
  }
}

final webhookSimulatorProvider =
    StateNotifierProvider<WebhookSimulatorNotifier, WebhookSimulatorState>((ref) {
  return WebhookSimulatorNotifier();
});
