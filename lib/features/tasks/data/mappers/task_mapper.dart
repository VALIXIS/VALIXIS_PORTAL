import '../../../../shared/models/task.dart';

/// Data mapper converting raw Supabase JSON responses to [Task] domain models.
abstract final class TaskMapper {
  static Task fromJson(Map<String, dynamic> json) {
    final taskData = (json['tasks'] is Map<String, dynamic>)
        ? json['tasks'] as Map<String, dynamic>
        : json;

    final taskId = json['task_id'] as String? ??
        taskData['id'] as String? ??
        json['id'] as String? ??
        '';

    return Task(
      id: taskId,
      title: taskData['title'] as String? ?? 'Untitled Task',
      description: taskData['description'] as String?,
      objective: taskData['objective'] as String?,
      aiPrompt:
          taskData['ai_prompt'] as String? ?? taskData['prompt'] as String?,
      branchName:
          taskData['branch_name'] as String? ?? taskData['branch'] as String?,
      expectedOutput: taskData['expected_output'] as String?,
      githubRepo:
          taskData['github_repo'] as String? ?? taskData['repo_url'] as String?,
      prUrl: json['pr_url'] as String? ??
          taskData['pr_url'] as String? ??
          json['pull_request_url'] as String?,
      priority: TaskPriority.fromString(taskData['priority'] as String?),
      status: TaskStatus.fromString(
          json['status'] as String? ?? taskData['status'] as String?),
      deadline: taskData['deadline'] != null
          ? DateTime.tryParse(taskData['deadline'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      assignedTo: json['employee_id'] as String? ??
          json['user_id'] as String? ??
          json['assigned_to'] as String? ??
          '',
      createdAt: taskData['created_at'] != null
          ? DateTime.tryParse(taskData['created_at'].toString())
          : null,
    );
  }
}
