import '../entities/task_item.dart';

/// Contract for Tasks operations in VALIXIS BUSINESS OS.
abstract class TasksRepository {
  /// Fetches tasks for the given organization, optionally filtered by project.
  Future<List<TaskItem>> getTasks(String organizationId, {String? projectId});

  /// Creates a new task in the organization.
  Future<TaskItem> createTask({
    required String organizationId,
    required String title,
    String? projectId,
    String? customerId,
    String? assignedTo,
    String? description,
    String priority = 'medium',
    String status = 'backlog',
    DateTime? dueDate,
  });

  /// Transitions a task to a new status ('backlog', 'in_progress', 'under_review', 'done').
  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
  });
}
