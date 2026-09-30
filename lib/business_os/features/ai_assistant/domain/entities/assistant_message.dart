import 'package:flutter/foundation.dart';

enum AssistantRole { user, assistant, system }

/// Represents a conversational message within the VALIXIS AI Business Assistant.
@immutable
class AssistantMessage {
  final String id;
  final AssistantRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final bool hasError;
  final String? errorMessage;

  const AssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.hasError = false,
    this.errorMessage,
  });

  factory AssistantMessage.user(String text) {
    return AssistantMessage(
      id: 'msg_usr_${DateTime.now().microsecondsSinceEpoch}',
      role: AssistantRole.user,
      content: text,
      timestamp: DateTime.now(),
    );
  }

  factory AssistantMessage.assistantStream(String id) {
    return AssistantMessage(
      id: id,
      role: AssistantRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );
  }

  AssistantMessage copyWith({
    String? id,
    AssistantRole? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
    bool? hasError,
    String? errorMessage,
  }) {
    return AssistantMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          isStreaming == other.isStreaming &&
          hasError == other.hasError;

  @override
  int get hashCode =>
      id.hashCode ^ content.hashCode ^ isStreaming.hashCode ^ hasError.hashCode;
}
