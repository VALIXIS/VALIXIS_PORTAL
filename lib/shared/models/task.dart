import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum TaskPriority {
  low('Low', Color(0xFF64748B), 'Low'),
  medium('Medium', AppColors.brandBlue, 'Medium'),
  high('High', AppColors.brandPurple, 'High'),
  critical('Critical', AppColors.error, 'Critical');

  const TaskPriority(this.label, this.color, this.value);
  final String label;
  final Color color;
  final String value;

  static TaskPriority fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'critical' => TaskPriority.critical,
      'urgent' => TaskPriority.critical,
      'high' => TaskPriority.high,
      'medium' => TaskPriority.medium,
      _ => TaskPriority.low,
    };
  }
}

enum TaskStatus {
  assigned('Assigned', AppColors.brandPurple),
  inProgress('In Progress', AppColors.warning),
  submitted('Submitted', AppColors.brandCyan),
  approved('Approved', AppColors.success),
  rejected('Rejected', AppColors.error);

  const TaskStatus(this.label, this.color);
  final String label;
  final Color color;

  static TaskStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'in_progress' || 'in progress' => TaskStatus.inProgress,
      'submitted' || 'under_review' => TaskStatus.submitted,
      'approved' || 'completed' => TaskStatus.approved,
      'rejected' => TaskStatus.rejected,
      _ => TaskStatus.assigned,
    };
  }

  bool get isPending =>
      this == TaskStatus.assigned ||
      this == TaskStatus.inProgress ||
      this == TaskStatus.submitted;

  bool get isCompleted => this == TaskStatus.approved;
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.objective,
    this.aiPrompt,
    this.branchName,
    this.expectedOutput,
    this.githubRepo,
    this.prUrl,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.assignedTo,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? objective;
  final String? aiPrompt;
  final String? branchName;
  final String? expectedOutput;
  final String? githubRepo;
  final String? prUrl;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime deadline;
  final String assignedTo;
  final DateTime? createdAt;

  factory Task.fromJson(Map<String, dynamic> json) {
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
      githubRepo: taskData['github_repository'] as String? ??
          taskData['github_repo'] as String? ??
          taskData['repo_url'] as String?,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (objective != null) 'objective': objective,
        if (aiPrompt != null) 'ai_prompt': aiPrompt,
        if (branchName != null) 'branch_name': branchName,
        if (expectedOutput != null) 'expected_output': expectedOutput,
        if (githubRepo != null) 'github_repository': githubRepo,
        if (prUrl != null) 'pr_url': prUrl,
        'priority': priority.value,
        'status': status.name,
        'deadline': deadline.toIso8601String(),
        'assigned_to': assignedTo,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
