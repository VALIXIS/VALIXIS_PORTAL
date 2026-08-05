// ignore_for_file: use_null_aware_elements

import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for managing submission operations via Supabase Edge Functions.
class SubmissionRepository {
  SubmissionRepository(this._client);

  final SupabaseClient _client;

  /// Invokes `submit-pull-request` Edge Function.
  Future<void> submitPullRequest({
    required String taskId,
    required String prUrl,
  }) async {
    final response = await _client.functions.invoke(
      'submit-pull-request',
      body: {
        'task_id': taskId,
        'pr_url': prUrl,
      },
    );

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }
  }

  /// Invokes `approve-submission` Edge Function.
  Future<void> approveSubmission({
    required String taskId,
    String? feedback,
  }) async {
    final response = await _client.functions.invoke(
      'approve-submission',
      body: {
        'task_id': taskId,
        if (feedback != null) 'feedback': feedback,
      },
    );

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }
  }

  /// Invokes `reject-submission` Edge Function.
  Future<void> rejectSubmission({
    required String taskId,
    String? feedback,
  }) async {
    final response = await _client.functions.invoke(
      'reject-submission',
      body: {
        'task_id': taskId,
        if (feedback != null) 'feedback': feedback,
      },
    );

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }
  }
}
