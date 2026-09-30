import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/ai_assistant_service.dart';

/// Supabase Edge Function implementation of AiAssistantService with SSE HTTP Streaming.
class SupabaseAiAssistantService implements AiAssistantService {
  final SupabaseClient _client;
  http.Client? _activeHttpClient;

  SupabaseAiAssistantService(this._client);

  @override
  Stream<String> streamAssistantResponse({
    required String prompt,
    required String organizationId,
  }) {
    final controller = StreamController<String>();

    Future<void>(() async {
      try {
        final session = _client.auth.currentSession;
        final accessToken = session?.accessToken ?? '';
        final supabaseUrl = dotenv.get(
          'SUPABASE_URL',
          fallback: 'https://qbvlzhjnqrwsoyvpomyt.supabase.co',
        );
        final anonKey = dotenv.get('SUPABASE_ANON_KEY', fallback: '');

        final url = Uri.parse('$supabaseUrl/functions/v1/ai-assistant');
        final httpClient = http.Client();
        _activeHttpClient = httpClient;

        final request = http.Request('POST', url);
        request.headers['Authorization'] = 'Bearer $accessToken';
        request.headers['apikey'] = anonKey;
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'text/event-stream';
        request.body = jsonEncode({
          'mode': 'business_assistant',
          'message': prompt,
          'organization_id': organizationId,
          'stream': true,
        });

        final response = await httpClient.send(request);

        if (response.statusCode != 200) {
          final bodyText = await response.stream.bytesToString();
          if (!controller.isClosed) {
            controller.addError(Exception('AI service HTTP ${response.statusCode}: $bodyText'));
            controller.close();
          }
          return;
        }

        final lineStream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in lineStream) {
          if (controller.isClosed) break;
          final trimmed = line.trim();
          if (trimmed.startsWith('data:')) {
            final jsonStr = trimmed.substring(5).trim();
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;
            try {
              final parsed = jsonDecode(jsonStr);
              if (parsed is Map) {
                final type = parsed['type']?.toString();
                if (type == 'text' && parsed.containsKey('content')) {
                  final text = parsed['content'].toString();
                  if (text.isNotEmpty && !controller.isClosed) {
                    controller.add(text);
                  }
                } else if (type == 'done') {
                  break;
                } else if (type == 'error') {
                  final err = parsed['error']?.toString() ?? 'Stream error';
                  if (!controller.isClosed) {
                    controller.addError(Exception(err));
                  }
                  break;
                }
              }
            } catch (_) {
              // Ignore SSE chunk parse glitches
            }
          }
        }

        if (!controller.isClosed) {
          controller.close();
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
        }
      }
    });

    controller.onCancel = () {
      _activeHttpClient?.close();
      _activeHttpClient = null;
    };

    return controller.stream;
  }

  @override
  Future<String> generateAssistantResponse({
    required String prompt,
    required String organizationId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'ai-assistant',
        body: {
          'mode': 'business_assistant',
          'message': prompt,
          'organization_id': organizationId,
          'stream': false,
        },
      );

      if (response.status != 200) {
        throw Exception('AI Assistant error status ${response.status}');
      }

      final data = response.data;
      if (data is Map && data['result'] != null) {
        return data['result'].toString();
      }
      return data.toString();
    } catch (e) {
      debugPrint('Error invoking ai-assistant edge function: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _activeHttpClient?.close();
    _activeHttpClient = null;
  }
}
