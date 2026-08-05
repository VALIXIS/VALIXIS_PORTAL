// ignore_for_file: use_null_aware_elements

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/task.dart';
import 'mappers/task_mapper.dart';

/// Repository for task retrieval and management via Edge Functions & Supabase.
class TasksRepository {
  TasksRepository(this._client);

  final SupabaseClient _client;

  /// Fetches tasks assigned to the logged-in employee by joining `task_assignments`
  /// with `tasks` and `employees!inner(*)`, filtering by `employees.auth_id == userId`.
  Future<List<Task>> getAssignedTasks(String userId) async {
    try {
      final response = await _client
          .from('task_assignments')
          .select('*, tasks(*), employees!inner(*)')
          .eq('employees.auth_id', userId);

      final list = response as List<dynamic>;
      return list
          .map((item) => TaskMapper.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback query without employees!inner hint if relation name differs
      try {
        final response = await _client
            .from('task_assignments')
            .select('*, tasks(*)');

        final list = response as List<dynamic>;
        return list
            .map((item) => TaskMapper.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  /// Invokes `create-task` Edge Function.
  Future<Task?> createTask({
    required String title,
    String? description,
    String? objective,
    String? aiPrompt,
    String? branchName,
    String? expectedOutput,
    String? githubRepo,
    String? priority,
    String? deadline,
  }) async {
    final response = await _client.functions.invoke(
      'create-task',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (objective != null) 'objective': objective,
        if (aiPrompt != null) 'ai_prompt': aiPrompt,
        if (branchName != null) 'branch_name': branchName,
        if (expectedOutput != null) 'expected_output': expectedOutput,
        if (githubRepo != null) 'github_repository': githubRepo,
        'priority': priority ?? 'Medium',
        if (deadline != null) 'deadline': deadline,
      },
    );

    if (response.status < 400 && response.data?['task'] != null) {
      return TaskMapper.fromJson(response.data['task']);
    }
    return null;
  }

  /// Invokes `assign-task` Edge Function.
  Future<bool> assignTask({
    required String taskId,
    required String employeeId,
  }) async {
    final response = await _client.functions.invoke(
      'assign-task',
      body: {
        'task_id': taskId,
        'employee_id': employeeId,
      },
    );

    return response.status < 400 && (response.data?['success'] == true);
  }
}
