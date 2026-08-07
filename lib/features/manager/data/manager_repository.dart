import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/task.dart';
import '../../tasks/data/mappers/task_mapper.dart';

/// Data model holding manager dashboard metrics with enriched employee assignments.
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
    required this.allEmployees,
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
  final List<Map<String, dynamic>> allEmployees;

  factory ManagerDashboardMetrics.fromJson(
    Map<String, dynamic> json, {
    List<Map<String, dynamic>>? liveAssignments,
    List<Map<String, dynamic>>? liveEmployees,
  }) {
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};
    final rawSubmissions = (json['recent_submissions'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final rawTasks = (json['tasks'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final rawEmployees = liveEmployees ??
        (json['employees'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    final rawAssignments = liveAssignments ??
        (json['assignments'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];

    final employeeNameMap = <String, String>{};
    final employeeAvatarMap = <String, String>{};
    for (final emp in rawEmployees) {
      final idStr = emp['id']?.toString() ?? '';
      final authId = emp['auth_id']?.toString() ?? '';
      final name = emp['name'] as String? ?? emp['full_name'] as String? ?? emp['email'] as String? ?? 'Employee';
      final avatar = emp['avatar_url'] as String? ?? '';
      if (idStr.isNotEmpty) {
        employeeNameMap[idStr] = name;
        employeeAvatarMap[idStr] = avatar;
      }
      if (authId.isNotEmpty) {
        employeeNameMap[authId] = name;
        employeeAvatarMap[authId] = avatar;
      }
    }

    final taskAssignmentMap = <String, Map<String, dynamic>>{};
    for (final a in rawAssignments) {
      final tId = a['task_id']?.toString();
      if (tId != null) {
        taskAssignmentMap[tId] = a;
      }
    }

    final enrichedTasks = rawTasks.map((tJson) {
      final taskId = tJson['id']?.toString() ?? '';
      final assignment = taskAssignmentMap[taskId];
      final empId = assignment?['employee_id']?.toString() ??
          tJson['assigned_to']?.toString() ??
          tJson['employee_id']?.toString() ??
          '';

      final empName = employeeNameMap[empId] ?? (empId.isNotEmpty ? empId : '');
      final latestStatus = assignment?['status']?.toString() ?? tJson['status']?.toString();

      final mergedJson = Map<String, dynamic>.from(tJson);
      if (empName.isNotEmpty) {
        mergedJson['assigned_to'] = empName;
        mergedJson['employee_id'] = empId;
      } else {
        mergedJson['assigned_to'] = '';
        mergedJson['employee_id'] = '';
      }
      if (latestStatus != null) {
        mergedJson['status'] = latestStatus;
      }

      return TaskMapper.fromJson(mergedJson);
    }).toList();

    return ManagerDashboardMetrics(
      totalEmployees: rawEmployees.isNotEmpty ? rawEmployees.length : (metrics['total_employees'] as int? ?? 0),
      totalTasks: enrichedTasks.isNotEmpty ? enrichedTasks.length : (metrics['total_tasks'] as int? ?? 0),
      assignedCount: metrics['assigned_tasks'] as int? ?? 0,
      inProgressCount: metrics['in_progress_tasks'] as int? ?? 0,
      submittedCount: metrics['submitted_tasks'] as int? ?? 0,
      approvedCount: metrics['approved_tasks'] as int? ?? 0,
      rejectedCount: metrics['rejected_tasks'] as int? ?? 0,
      recentSubmissions: rawSubmissions,
      recentTasks: enrichedTasks,
      allEmployees: rawEmployees,
    );
  }
}

/// Repository managing Manager operations via Supabase Edge Functions & Database queries.
class ManagerRepository {
  ManagerRepository(this._client);

  final SupabaseClient _client;

  /// Fetches manager dashboard metrics and merges live task assignment relationships.
  Future<ManagerDashboardMetrics> getDashboardMetrics() async {
    final response = await _client.functions.invoke('manager-dashboard');

    if (response.status >= 400 || response.data == null) {
      throw FunctionException(status: response.status, details: response.data);
    }

    return ManagerDashboardMetrics.fromJson(
      response.data as Map<String, dynamic>,
    );
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
      if (objective != null && objective.isNotEmpty) 'objective': objective,
      if (branchName != null && branchName.isNotEmpty) 'branch_name': branchName,
      if (expectedOutput != null && expectedOutput.isNotEmpty) 'expected_output': expectedOutput,
      if (githubRepo != null && githubRepo.isNotEmpty) 'github_repository': githubRepo,
      'priority': (priority != null && priority.isNotEmpty) ? priority : 'Medium',
      if (deadline != null && deadline.isNotEmpty) 'deadline': deadline,
    };

    final response = await _client.functions.invoke('create-task', body: payload);
    if (response.status >= 400) {
      throw FunctionException(status: response.status, details: response.data);
    }

    if (response.data?['task'] != null) {
      return TaskMapper.fromJson(response.data['task']);
    }
    return null;
  }

  /// Assigns or reassigns a task to an employee.
  Future<bool> assignTask({required String taskId, required String employeeId}) async {
    final response = await _client.functions.invoke(
      'assign-task',
      body: {'task_id': taskId, 'employee_id': employeeId},
    );
    return response.status < 400;
  }

  /// Unassigns a task by removing its assignment relationship.
  Future<bool> unassignTask(String taskId) async {
    try {
      final numericId = int.tryParse(taskId);
      if (numericId != null) {
        await _client.from('task_assignments').delete().or('task_id.eq.$taskId,task_id.eq.$numericId');
      } else {
        await _client.from('task_assignments').delete().eq('task_id', taskId);
      }
      return true;
    } catch (e) {
      debugPrint('Unassign task error: $e');
      return false;
    }
  }

  /// Deletes a task and all related assignments and submissions using admin Edge Function and client fallback.
  Future<bool> deleteTask(String taskId) async {
    try {
      final response = await _client.functions.invoke(
        'delete-task',
        body: {'task_id': taskId},
      );
      if (response.status < 400) return true;
    } catch (e) {
      debugPrint('Delete task Edge Function notice: $e');
    }

    try {
      final numericId = int.tryParse(taskId);
      if (numericId != null) {
        await _client.from('submissions').delete().or('task_id.eq.$taskId,task_id.eq.$numericId');
        await _client.from('task_assignments').delete().or('task_id.eq.$taskId,task_id.eq.$numericId');
        await _client.from('tasks').delete().eq('id', numericId);
      } else {
        await _client.from('submissions').delete().eq('task_id', taskId);
        await _client.from('task_assignments').delete().eq('task_id', taskId);
        await _client.from('tasks').delete().eq('id', taskId);
      }
      return true;
    } catch (e) {
      debugPrint('Delete task client fallback error: $e');
      return false;
    }
  }

  /// Approves a submission via `approve-submission` Edge Function.
  Future<bool> approveSubmission({required String taskId, String? feedback}) async {
    final response = await _client.functions.invoke('approve-submission', body: {'task_id': taskId, if (feedback != null && feedback.isNotEmpty) 'feedback': feedback});
    return response.status < 400;
  }

  /// Rejects a submission via `reject-submission` Edge Function.
  Future<bool> rejectSubmission({required String taskId, String? feedback}) async {
    final response = await _client.functions.invoke('reject-submission', body: {'task_id': taskId, if (feedback != null && feedback.isNotEmpty) 'feedback': feedback});
    return response.status < 400;
  }
}
