import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/tasks_repository.dart';

/// Production Supabase repository for tasks and Kanban operations.
class SupabaseTasksRepository implements TasksRepository {
  final sp.SupabaseClient _client;

  SupabaseTasksRepository(this._client);

  @override
  Future<List<TaskItem>> getTasks(String organizationId, {String? projectId}) async {
    try {
      var query = _client
          .from('tasks')
          .select('id, organization_id, project_id, customer_id, assigned_to, title, description, priority, status, due_date, created_at, updated_at, projects(id, name), organization_members(id, user_id, role)')
          .eq('organization_id', organizationId);

      if (projectId != null && projectId.isNotEmpty && projectId != 'all') {
        query = query.eq('project_id', projectId);
      }

      final response = await query.order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(response as List);

      // Collect user_ids from organization_members to join profile full_names
      final userIds = <String>{};
      final memberToUserId = <String, String>{};
      for (final r in rows) {
        final member = r['organization_members'] as Map<String, dynamic>?;
        if (member != null && member['user_id'] != null) {
          final uid = member['user_id'] as String;
          final mid = member['id'] as String;
          userIds.add(uid);
          memberToUserId[mid] = uid;
        }
      }

      final profileNames = <String, String>{};
      if (userIds.isNotEmpty) {
        try {
          final profiles = await _client
              .from('profiles')
              .select('id, full_name, email')
              .inFilter('id', userIds.toList());
          for (final p in profiles as List) {
            final uid = p['id'] as String;
            final name = p['full_name'] as String? ?? p['email'] as String? ?? 'Team Member';
            profileNames[uid] = name;
          }
        } catch (e) {
          debugPrint('Note: Error fetching profiles for task assignees: $e');
        }
      }

      return rows.map((row) {
        final project = row['projects'] as Map<String, dynamic>?;
        final member = row['organization_members'] as Map<String, dynamic>?;
        final assignedId = row['assigned_to'] as String?;
        final userId = assignedId != null ? memberToUserId[assignedId] : null;
        final assigneeName = userId != null ? profileNames[userId] : null;

        return TaskItem(
          id: row['id'] as String,
          organizationId: row['organization_id'] as String,
          projectId: row['project_id'] as String?,
          customerId: row['customer_id'] as String?,
          assignedTo: assignedId,
          title: row['title'] as String,
          description: row['description'] as String?,
          priority: row['priority'] as String? ?? 'medium',
          status: row['status'] as String? ?? 'backlog',
          dueDate: row['due_date'] != null ? DateTime.parse(row['due_date'] as String) : null,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String) : null,
          projectName: project?['name'] as String?,
          assigneeName: assigneeName,
          assigneeRole: member?['role'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('SupabaseTasksRepository getTasks error: $e');
      rethrow;
    }
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
    final payload = {
      'organization_id': organizationId,
      'title': title.trim(),
      'project_id': projectId,
      'customer_id': customerId,
      'assigned_to': assignedTo,
      'description': description?.trim().isNotEmpty == true ? description!.trim() : null,
      'priority': priority,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
    };

    final inserted = await _client
        .from('tasks')
        .insert(payload)
        .select('id, organization_id, project_id, customer_id, assigned_to, title, description, priority, status, due_date, created_at, updated_at, projects(id, name)')
        .single();

    final project = inserted['projects'] as Map<String, dynamic>?;

    return TaskItem(
      id: inserted['id'] as String,
      organizationId: inserted['organization_id'] as String,
      projectId: inserted['project_id'] as String?,
      customerId: inserted['customer_id'] as String?,
      assignedTo: inserted['assigned_to'] as String?,
      title: inserted['title'] as String,
      description: inserted['description'] as String?,
      priority: inserted['priority'] as String? ?? priority,
      status: inserted['status'] as String? ?? status,
      dueDate: inserted['due_date'] != null ? DateTime.parse(inserted['due_date'] as String) : null,
      createdAt: DateTime.parse(inserted['created_at'] as String),
      projectName: project?['name'] as String?,
    );
  }

  @override
  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    final updated = await _client
        .from('tasks')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', taskId)
        .select('id, organization_id, project_id, customer_id, assigned_to, title, description, priority, status, due_date, created_at, updated_at, projects(id, name)')
        .single();

    final project = updated['projects'] as Map<String, dynamic>?;

    return TaskItem(
      id: updated['id'] as String,
      organizationId: updated['organization_id'] as String,
      projectId: updated['project_id'] as String?,
      customerId: updated['customer_id'] as String?,
      assignedTo: updated['assigned_to'] as String?,
      title: updated['title'] as String,
      description: updated['description'] as String?,
      priority: updated['priority'] as String? ?? 'medium',
      status: updated['status'] as String? ?? status,
      dueDate: updated['due_date'] != null ? DateTime.parse(updated['due_date'] as String) : null,
      createdAt: DateTime.parse(updated['created_at'] as String),
      projectName: project?['name'] as String?,
    );
  }
}
