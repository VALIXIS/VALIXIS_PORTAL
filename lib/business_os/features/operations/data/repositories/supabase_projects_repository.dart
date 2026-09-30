import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../domain/entities/project.dart';
import '../../domain/repositories/projects_repository.dart';

/// Production Supabase repository for project workspaces.
class SupabaseProjectsRepository implements ProjectsRepository {
  final sp.SupabaseClient _client;

  SupabaseProjectsRepository(this._client);

  @override
  Future<List<Project>> getProjects(String organizationId) async {
    try {
      // 1. Fetch projects with joined customer info
      final projectsResponse = await _client
          .from('projects')
          .select('id, organization_id, customer_id, name, description, status, start_date, due_date, created_at, updated_at, customers(id, name, company_name)')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      final projectRows = List<Map<String, dynamic>>.from(projectsResponse as List);
      if (projectRows.isEmpty) {
        return [];
      }

      // 2. Fetch tasks to compute completion percentage dynamically
      final totalCounts = <String, int>{};
      final doneCounts = <String, int>{};

      try {
        final tasksResponse = await _client
            .from('tasks')
            .select('project_id, status')
            .eq('organization_id', organizationId);

        for (final t in tasksResponse as List) {
          final pid = t['project_id'] as String?;
          if (pid != null) {
            totalCounts[pid] = (totalCounts[pid] ?? 0) + 1;
            if (t['status'] == 'done') {
              doneCounts[pid] = (doneCounts[pid] ?? 0) + 1;
            }
          }
        }
      } catch (e) {
        debugPrint('Note: Error aggregating task progress for projects: $e');
      }

      return projectRows.map((row) {
        final customer = row['customers'] as Map<String, dynamic>?;
        final pid = row['id'] as String;

        return Project(
          id: pid,
          organizationId: row['organization_id'] as String,
          customerId: row['customer_id'] as String,
          name: row['name'] as String,
          description: row['description'] as String?,
          status: row['status'] as String? ?? 'planning',
          startDate: row['start_date'] != null ? DateTime.parse(row['start_date'] as String) : null,
          dueDate: row['due_date'] != null ? DateTime.parse(row['due_date'] as String) : null,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String) : null,
          customerName: customer?['name'] as String?,
          customerCompanyName: customer?['company_name'] as String?,
          totalTasks: totalCounts[pid] ?? 0,
          completedTasks: doneCounts[pid] ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('SupabaseProjectsRepository getProjects error: $e');
      rethrow;
    }
  }

  @override
  Future<Project> createProject({
    required String organizationId,
    required String customerId,
    required String name,
    String? description,
    String status = 'planning',
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    final payload = {
      'organization_id': organizationId,
      'customer_id': customerId,
      'name': name.trim(),
      'description': description?.trim().isNotEmpty == true ? description!.trim() : null,
      'status': status,
      'start_date': startDate?.toIso8601String().split('T').first,
      'due_date': dueDate?.toIso8601String().split('T').first,
    };

    final inserted = await _client
        .from('projects')
        .insert(payload)
        .select('id, organization_id, customer_id, name, description, status, start_date, due_date, created_at, updated_at, customers(id, name, company_name)')
        .single();

    final customer = inserted['customers'] as Map<String, dynamic>?;

    return Project(
      id: inserted['id'] as String,
      organizationId: inserted['organization_id'] as String,
      customerId: inserted['customer_id'] as String,
      name: inserted['name'] as String,
      description: inserted['description'] as String?,
      status: inserted['status'] as String? ?? status,
      startDate: inserted['start_date'] != null ? DateTime.parse(inserted['start_date'] as String) : null,
      dueDate: inserted['due_date'] != null ? DateTime.parse(inserted['due_date'] as String) : null,
      createdAt: DateTime.parse(inserted['created_at'] as String),
      customerName: customer?['name'] as String?,
      customerCompanyName: customer?['company_name'] as String?,
      totalTasks: 0,
      completedTasks: 0,
    );
  }
}
