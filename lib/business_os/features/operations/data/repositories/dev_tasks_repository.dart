import 'dart:async';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/tasks_repository.dart';

/// In-memory development repository for tasks.
class DevTasksRepository implements TasksRepository {
  final List<TaskItem> _tasks;

  DevTasksRepository({List<TaskItem>? initialTasks})
      : _tasks = initialTasks ?? _defaultTasks();

  static List<TaskItem> _defaultTasks() => const [];

  @override
  Future<List<TaskItem>> getTasks(String organizationId, {String? projectId}) async {
    await Future.delayed(const Duration(milliseconds: 30));
    if (projectId != null && projectId.isNotEmpty && projectId != 'all') {
      return _tasks.where((t) => t.projectId == projectId).toList();
    }
    return List.unmodifiable(_tasks);
  }

  @override
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }

    final newTask = TaskItem(
      id: 'task_dev_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: organizationId,
      projectId: projectId,
      customerId: customerId,
      assignedTo: assignedTo,
      title: cleanTitle,
      description: description?.trim().isNotEmpty == true ? description!.trim() : null,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      projectName: projectId != null ? 'Project' : null,
      assigneeName: assignedTo != null ? 'Team Member' : null,
    );

    _tasks.insert(0, newTask);
    return newTask;
  }

  @override
  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 40));
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw Exception('Task not found: $taskId');
    }

    final updated = _tasks[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _tasks[index] = updated;
    return updated;
  }
}
