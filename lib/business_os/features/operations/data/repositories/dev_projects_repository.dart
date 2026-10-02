import 'dart:async';
import '../../domain/entities/project.dart';
import '../../domain/repositories/projects_repository.dart';

/// In-memory development repository for projects.
class DevProjectsRepository implements ProjectsRepository {
  final List<Project> _projects;

  DevProjectsRepository({List<Project>? initialProjects})
      : _projects = initialProjects ?? _defaultProjects();

  static List<Project> _defaultProjects() => const [];

  @override
  Future<List<Project>> getProjects(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 30));
    return List.unmodifiable(_projects);
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
    await Future.delayed(const Duration(milliseconds: 50));
    final newProject = Project(
      id: 'proj_dev_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: organizationId,
      customerId: customerId,
      name: name,
      description: description,
      status: status,
      startDate: startDate,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      customerName: 'Client Account',
      customerCompanyName: 'Linked Customer',
      totalTasks: 0,
      completedTasks: 0,
    );
    _projects.add(newProject);
    return newProject;
  }
}
