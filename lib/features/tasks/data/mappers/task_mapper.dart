import '../../../../shared/models/task.dart';

/// Data mapper converting raw Supabase JSON responses to [Task] domain models.
abstract final class TaskMapper {
  static Task fromJson(Map<String, dynamic> json) {
    final taskData = (json['tasks'] is Map<String, dynamic>)
        ? json['tasks'] as Map<String, dynamic>
        : json;

    final taskId = json['task_id']?.toString() ??
        taskData['id']?.toString() ??
        json['id']?.toString() ??
        '';

    return Task(
      id: taskId,
      title: taskData['title']?.toString() ?? 'Untitled Task',
      description: taskData['description']?.toString(),
      objective: taskData['objective']?.toString(),
      aiPrompt:
          taskData['ai_prompt']?.toString() ?? taskData['prompt']?.toString(),
      branchName:
          taskData['branch_name']?.toString() ?? taskData['branch']?.toString(),
      expectedOutput: taskData['expected_output']?.toString(),
      githubRepo: taskData['github_repository']?.toString() ??
          taskData['github_repo']?.toString() ??
          taskData['repo_url']?.toString(),
      prUrl: json['pr_url']?.toString() ??
          taskData['pr_url']?.toString() ??
          json['pull_request_url']?.toString(),
      priority: TaskPriority.fromString(taskData['priority']?.toString()),
      status: TaskStatus.fromString(
          json['status']?.toString() ?? taskData['status']?.toString()),
      deadline: taskData['deadline'] != null
          ? DateTime.tryParse(taskData['deadline'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      assignedTo: json['assigned_to']?.toString() ??
          json['employee_name']?.toString() ??
          json['employee_id']?.toString() ??
          json['user_id']?.toString() ??
          '',
      createdAt: taskData['created_at'] != null
          ? DateTime.tryParse(taskData['created_at'].toString())
          : null,
    );
  }
}
