// ignore_for_file: use_null_aware_elements

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/task.dart';
import '../../tasks/data/mappers/task_mapper.dart';

/// Data model holding manager dashboard metrics.
class ManagerDashboardMetrics {
  const ManagerDashboardMetrics({
    required this.totalEmployees,
    required this.totalTasks,
    required this.assignedCount,
    required this.inProgressCount,
    required this.submittedCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.recentSubmissions,
    required this.recentTasks,
  });

  final int totalEmployees;
  final int totalTasks;
  final int assignedCount;
  final int inProgressCount;
  final int submittedCount;
  final int approvedCount;
  final int rejectedCount;
  final List<Map<String, dynamic>> recentSubmissions;
  final List<Task> recentTasks;

  factory ManagerDashboardMetrics.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};
    final rawSubmissions = (json['recent_submissions'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final rawTasks = (json['tasks'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return ManagerDashboardMetrics(
      totalEmployees: metrics['total_employees'] as int? ?? 0,
      totalTasks: metrics['total_tasks'] as int? ?? 0,
      assignedCount: metrics['assigned_tasks'] as int? ?? 0,
      inProgressCount: metrics['in_progress_tasks'] as int? ?? 0,
      submittedCount: metrics['submitted_tasks'] as int? ?? 0,
      approvedCount: metrics['approved_tasks'] as int? ?? 0,
      rejectedCount: metrics['rejected_tasks'] as int? ?? 0,
      recentSubmissions: rawSubmissions,
      recentTasks: rawTasks.map((t) => TaskMapper.fromJson(t)).toList(),
    );
  }
}

/// Repository managing Manager operations via Supabase Edge Functions.
class ManagerRepository {
  ManagerRepository(this._client);

  final SupabaseClient _client;

  /// Fetches manager dashboard metrics via `manager-dashboard` Edge Function.
  Future<ManagerDashboardMetrics> getDashboardMetrics() async {
    final response = await _client.functions.invoke('manager-dashboard');

    if (response.status >= 400 || response.data == null) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }
    return ManagerDashboardMetrics.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// Creates a task via `create-task` Edge Function.
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
    final payload = {
      'title': title,
      'description': description ?? '',
      'ai_prompt': aiPrompt ?? '',
      if (objective != null && objective.isNotEmpty)
        'objective': objective,
      if (branchName != null && branchName.isNotEmpty)
        'branch_name': branchName,
      if (expectedOutput != null && expectedOutput.isNotEmpty)
        'expected_output': expectedOutput,
      if (githubRepo != null && githubRepo.isNotEmpty)
        'github_repository': githubRepo,
      'priority': (priority != null && priority.isNotEmpty) ? priority : 'Medium',
      if (deadline != null && deadline.isNotEmpty)
        'deadline': deadline,
    };

    final response = await _client.functions.invoke(
      'create-task',
      body: payload,
    );

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }

    if (response.data?['task'] != null) {
      return TaskMapper.fromJson(response.data['task']);
    }
    return null;
  }

  /// Assigns a task to an employee via `assign-task` Edge Function.
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

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }

    return response.status < 400 && (response.data?['success'] == true);
  }

  /// Approves a submission via `approve-submission` Edge Function.
  Future<bool> approveSubmission({
    required String taskId,
    String? feedback,
  }) async {
    final response = await _client.functions.invoke(
      'approve-submission',
      body: {
        'task_id': taskId,
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      },
    );

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }

    return response.status < 400 && (response.data?['success'] == true);
  }

  /// Rejects a submission via `reject-submission` Edge Function.
  Future<bool> rejectSubmission({
    required String taskId,
    String? feedback,
  }) async {
    final response = await _client.functions.invoke(
      'reject-submission',
      body: {
        'task_id': taskId,
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      },
    );

    if (response.status >= 400) {
      throw FunctionException(
        status: response.status,
        details: response.data,
      );
    }

    return response.status < 400 && (response.data?['success'] == true);
  }
}
