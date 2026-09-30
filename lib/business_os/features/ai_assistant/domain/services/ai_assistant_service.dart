import 'dart:async';

/// Abstract service contract for AI Executive Assistant interactions.
abstract class AiAssistantService {
  /// Stream text response chunks for a user prompt within an organization scope.
  Stream<String> streamAssistantResponse({
    required String prompt,
    required String organizationId,
  });

  /// Request a non-streaming complete response for a user prompt.
  Future<String> generateAssistantResponse({
    required String prompt,
    required String organizationId,
  });

  /// Dispose active connections or stream resources.
  void dispose();
}
