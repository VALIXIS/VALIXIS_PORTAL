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
    List<Map<String, dynamic>>? liveSubmissions,
    List<Map<String, dynamic>>? liveEmployees,
  }) {
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};
    final rawSubmissions = liveSubmissions ??
        (json['recent_submissions'] as List<dynamic>?)
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
    for (final emp in rawEmployees) {
      final idStr = emp['id']?.toString().trim() ?? '';
      final authId = emp['auth_id']?.toString().trim() ?? '';
      final rawName = (emp['name'] as String? ?? emp['full_name'] as String? ?? '').trim();
      final email = (emp['email'] as String? ?? '').trim();
      final nameToShow = rawName.isNotEmpty ? rawName : (email.isNotEmpty ? email : 'Employee');
      final displayName = email.isNotEmpty && !nameToShow.contains('(') ? '$nameToShow ($email)' : nameToShow;
      if (idStr.isNotEmpty) {
        employeeNameMap[idStr] = displayName;
        employeeNameMap[idStr.toLowerCase()] = displayName;
      }
      if (authId.isNotEmpty) {
        employeeNameMap[authId] = displayName;
        employeeNameMap[authId.toLowerCase()] = displayName;
      }
    }

    final taskTitleMap = <String, String>{};
    for (final t in rawTasks) {
      final tId = t['id']?.toString();
      final title = t['title'] as String? ?? '';
      if (tId != null && tId.isNotEmpty) {
        taskTitleMap[tId] = title;
      }
    }

    final taskAssignmentMap = <String, Map<String, dynamic>>{};
    final assignmentByIdMap = <String, Map<String, dynamic>>{};
    for (final a in rawAssignments) {
      final tId = a['task_id']?.toString();
      final aId = a['id']?.toString();
      if (tId != null) {
        taskAssignmentMap[tId] = a;
      }
      if (aId != null && aId.isNotEmpty) {
        assignmentByIdMap[aId] = a;
      }
    }

    final submissionByAssignmentMap = <String, Map<String, dynamic>>{};
    for (final s in rawSubmissions) {
      final aId = s['assignment_id']?.toString();
      if (aId != null && aId.isNotEmpty) {
        submissionByAssignmentMap[aId] = s;
      }
    }

    final enrichedTasks = rawTasks.map((tJson) {
      final taskId = tJson['id']?.toString() ?? '';
      final assignment = taskAssignmentMap[taskId];
      final empId = assignment != null ? assignment['employee_id']?.toString().trim() ?? '' : '';

      final resolvedName = empId.isNotEmpty
          ? (employeeNameMap[empId] ?? employeeNameMap[empId.toLowerCase()])
          : null;
      final empName = resolvedName ?? (empId.isNotEmpty ? 'Assigned Employee' : '');
      final latestStatus = assignment != null ? assignment['status']?.toString() : 'unassigned';

      final mergedJson = Map<String, dynamic>.from(tJson);
      if (assignment != null && empName.isNotEmpty) {
        mergedJson['assigned_to'] = empName;
        mergedJson['employee_id'] = empId;
      } else {
        mergedJson['assigned_to'] = 'Unassigned';
        mergedJson['employee_id'] = '';
      }
      mergedJson['status'] = latestStatus ?? 'unassigned';

      // Check if a submission exists for this task's assignment
      if (assignment != null && assignment['id'] != null) {
        final sub = submissionByAssignmentMap[assignment['id'].toString()];
        if (sub != null && sub['pr_url'] != null) {
          mergedJson['pr_url'] = sub['pr_url'];
        }
      }

      return TaskMapper.fromJson(mergedJson);
    }).toList();

    final enrichedSubmissions = rawSubmissions.map((sub) {
      final mSub = Map<String, dynamic>.from(sub);
      final assignmentId = sub['assignment_id']?.toString() ?? sub['assignmentId']?.toString() ?? '';
      final assignment = assignmentByIdMap[assignmentId];

      final taskId = sub['task_id']?.toString() ?? assignment?['task_id']?.toString() ?? '';
      final empId = sub['employee_id']?.toString() ?? assignment?['employee_id']?.toString() ?? '';
      final empName = employeeNameMap[empId] ?? employeeNameMap[empId.toLowerCase()] ?? '';
      final taskTitle = taskTitleMap[taskId] ?? (taskId.isNotEmpty ? 'Task #$taskId' : '');
      final status = sub['review_status']?.toString() ?? sub['status']?.toString() ?? assignment?['status']?.toString() ?? 'pending';
      final feedback = sub['manager_feedback']?.toString() ?? sub['feedback']?.toString() ?? '';

      mSub['assignment_id'] = assignmentId;
      mSub['task_id'] = taskId;
      mSub['task_title'] = taskTitle;
      mSub['employee_id'] = empId;
      mSub['employee_name'] = empName;
      mSub['status'] = status;
      mSub['review_status'] = status;
      mSub['feedback'] = feedback;
      mSub['manager_feedback'] = feedback;
      return mSub;
    }).toList();

    final pendingReviewsCount = rawSubmissions.where((s) {
      final status = (s['review_status']?.toString() ?? s['status']?.toString() ?? '').toLowerCase().trim();
      return status == 'pending';
    }).length;

    return ManagerDashboardMetrics(
      totalEmployees: rawEmployees.isNotEmpty ? rawEmployees.length : (metrics['total_employees'] as int? ?? 0),
      totalTasks: enrichedTasks.isNotEmpty ? enrichedTasks.length : (metrics['total_tasks'] as int? ?? 0),
      assignedCount: metrics['assigned_tasks'] as int? ?? 0,
      inProgressCount: metrics['in_progress_tasks'] as int? ?? 0,
      submittedCount: pendingReviewsCount,
      approvedCount: metrics['approved_tasks'] as int? ?? 0,
      rejectedCount: metrics['rejected_tasks'] as int? ?? 0,
      recentSubmissions: enrichedSubmissions,
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

    final data = response.data as Map<String, dynamic>;

    List<Map<String, dynamic>>? liveAssignments;
    List<Map<String, dynamic>>? liveEmployees;
    List<Map<String, dynamic>>? liveSubmissions;

    await Future.wait([
      _client.from('task_assignments').select('*').then((assignRes) {
        liveAssignments = (assignRes as List<dynamic>).cast<Map<String, dynamic>>();
      }).catchError((_) {}),
      _client.from('employees').select('id, auth_id, name, email, role, department').then((empRes) {
        liveEmployees = (empRes as List<dynamic>).cast<Map<String, dynamic>>();
      }).catchError((_) {}),
      _client.from('submissions').select('*').then((subRes) {
        liveSubmissions = (subRes as List<dynamic>).cast<Map<String, dynamic>>();
      }).catchError((_) {}),
    ]);

    return ManagerDashboardMetrics.fromJson(
      data,
      liveAssignments: liveAssignments,
      liveEmployees: liveEmployees,
      liveSubmissions: liveSubmissions,
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

  /// Updates an existing task specification in the `tasks` table.
  Future<bool> updateTask({
    required String taskId,
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
      if (expectedOutput != null && expectedOutput.isNotEmpty)
        'expected_output': expectedOutput,
      if (branchName != null && branchName.isNotEmpty) 'branch_name': branchName,
      if (githubRepo != null && githubRepo.isNotEmpty)
        'github_repository': githubRepo,
      'priority': (priority != null && priority.isNotEmpty) ? priority : 'Medium',
      if (deadline != null && deadline.isNotEmpty) 'deadline': deadline,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _client.from('tasks').update(payload).eq('id', taskId);
    return true;
  }

  /// Assigns or reassigns a task to an employee.
  /// Throws an [Exception] with the backend error message on failure.
  Future<bool> assignTask({required String taskId, required String employeeId}) async {
    final response = await _client.functions.invoke(
      'assign-task',
      body: {'task_id': taskId, 'employee_id': employeeId},
    );

    if (response.status >= 400) {
      // Extract the backend error message for a meaningful UI error
      String message = 'Failed to assign task.';
      try {
        final data = response.data as Map<String, dynamic>?;
        final rawError = data?['error']?.toString() ??
            data?['message']?.toString() ??
            data?['details']?.toString();
        if (rawError != null && rawError.isNotEmpty) {
          message = rawError;
        }
      } catch (_) {}
      throw Exception(message);
    }
    return true;
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

  /// Deletes a task and all related assignments & submissions via atomic CASCADE deletion.
  Future<bool> deleteTask(String taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
      return true;
    } catch (e) {
      debugPrint('Direct task delete notice, trying Edge Function: $e');
      try {
        final response = await _client.functions.invoke(
          'delete-task',
          body: {'task_id': taskId},
        );
        return response.status < 400;
      } catch (_) {
        return false;
      }
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
