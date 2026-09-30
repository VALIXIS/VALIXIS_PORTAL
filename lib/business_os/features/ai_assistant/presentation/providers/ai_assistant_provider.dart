// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../data/services/dev_ai_assistant_service.dart';
import '../../data/services/supabase_ai_assistant_service.dart';
import '../../domain/entities/assistant_message.dart';
import '../../domain/services/ai_assistant_service.dart';

enum AiAssistantStatus { idle, sending, streaming, completed, error }

/// Immutable state for the AI Assistant slide-over panel and stream manager.
@immutable
class AiAssistantState {
  final AiAssistantStatus status;
  final List<AssistantMessage> messages;
  final bool isPanelOpen;
  final String? errorMessage;

  const AiAssistantState({
    this.status = AiAssistantStatus.idle,
    this.messages = const [],
    this.isPanelOpen = false,
    this.errorMessage,
  });

  bool get isStreaming =>
      status == AiAssistantStatus.sending || status == AiAssistantStatus.streaming;

  AiAssistantState copyWith({
    AiAssistantStatus? status,
    List<AssistantMessage>? messages,
    bool? isPanelOpen,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiAssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isPanelOpen: isPanelOpen ?? this.isPanelOpen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider exposing active AiAssistantService.
final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      final service = DevAiAssistantService();
      ref.onDispose(() => service.dispose());
      return service;
    }
    final service = SupabaseAiAssistantService(client);
    ref.onDispose(() => service.dispose());
    return service;
  } catch (e) {
    debugPrint('Supabase unavailable for AI assistant, using DevAiAssistantService: $e');
    final service = DevAiAssistantService();
    ref.onDispose(() => service.dispose());
    return service;
  }
});

/// Riverpod StateNotifier for AI Assistant logic.
class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  final AiAssistantService _service;
  StreamSubscription<String>? _streamSubscription;

  AiAssistantNotifier({
    required AiAssistantService service,
  })  : _service = service,
        super(const AiAssistantState());

  /// Send prompt and stream live assistant response.
  Future<void> sendMessage(String text, {required String? organizationId}) async {
    final prompt = text.trim();
    if (prompt.isEmpty) return;

    final orgId = organizationId ?? 'org_dev_001';

    // 1. Append User Message
    final userMsg = AssistantMessage.user(prompt);

    // 2. Append Empty Streaming Assistant Message
    final streamMsgId = 'msg_ai_${DateTime.now().microsecondsSinceEpoch}';
    final streamMsg = AssistantMessage.assistantStream(streamMsgId);

    final updatedList = [...state.messages, userMsg, streamMsg];

    state = state.copyWith(
      status: AiAssistantStatus.sending,
      messages: updatedList,
      clearError: true,
    );

    // 3. Cancel any previous stream
    _streamSubscription?.cancel();

    try {
      final responseStream = _service.streamAssistantResponse(
        prompt: prompt,
        organizationId: orgId,
      );

      state = state.copyWith(status: AiAssistantStatus.streaming);

      _streamSubscription = responseStream.listen(
        (chunkToken) {
          final index = state.messages.indexWhere((m) => m.id == streamMsgId);
          if (index != -1) {
            final currentMsg = state.messages[index];
            final newContent = currentMsg.content + chunkToken;
            final updatedMsg = currentMsg.copyWith(content: newContent);

            final list = List<AssistantMessage>.from(state.messages);
            list[index] = updatedMsg;

            state = state.copyWith(
              status: AiAssistantStatus.streaming,
              messages: list,
            );
          }
        },
        onDone: () {
          final index = state.messages.indexWhere((m) => m.id == streamMsgId);
          if (index != -1) {
            final currentMsg = state.messages[index];
            final updatedMsg = currentMsg.copyWith(isStreaming: false);

            final list = List<AssistantMessage>.from(state.messages);
            list[index] = updatedMsg;

            state = state.copyWith(
              status: AiAssistantStatus.completed,
              messages: list,
            );
          }
        },
        onError: (err) {
          debugPrint('Error streaming AI response: $err');
          final index = state.messages.indexWhere((m) => m.id == streamMsgId);
          if (index != -1) {
            final currentMsg = state.messages[index];
            final updatedMsg = currentMsg.copyWith(
              isStreaming: false,
              hasError: true,
              errorMessage: 'Failed to complete AI response. Please try again.',
            );

            final list = List<AssistantMessage>.from(state.messages);
            list[index] = updatedMsg;

            state = state.copyWith(
              status: AiAssistantStatus.error,
              messages: list,
              errorMessage: 'AI streaming interrupted',
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Exception initiating AI response stream: $e');
      state = state.copyWith(
        status: AiAssistantStatus.error,
        errorMessage: 'Unable to reach AI Assistant service.',
      );
    }
  }

  /// Cancel active streaming safely.
  void cancelStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (state.isStreaming) {
      final list = state.messages.map((m) {
        if (m.isStreaming) {
          return m.copyWith(isStreaming: false);
        }
        return m;
      }).toList();

      state = state.copyWith(
        status: AiAssistantStatus.completed,
        messages: list,
      );
    }
  }

  /// Toggle or set panel open state.
  void togglePanel() {
    state = state.copyWith(isPanelOpen: !state.isPanelOpen);
  }

  void openPanel() {
    state = state.copyWith(isPanelOpen: true);
  }

  void closePanel() {
    state = state.copyWith(isPanelOpen: false);
  }

  /// Clear messages history.
  void clearConversation() {
    cancelStreaming();
    state = state.copyWith(
      status: AiAssistantStatus.idle,
      messages: [],
      clearError: true,
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

/// Primary Riverpod StateNotifierProvider for AI Assistant.
final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  final service = ref.watch(aiAssistantServiceProvider);
  return AiAssistantNotifier(service: service);
});

/// Selectors
final isAiPanelOpenProvider = Provider<bool>((ref) {
  return ref.watch(aiAssistantProvider.select((s) => s.isPanelOpen));
});
