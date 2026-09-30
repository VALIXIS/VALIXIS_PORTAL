import 'dart:async';
import '../../domain/entities/project.dart';
import '../../domain/repositories/projects_repository.dart';

/// In-memory development repository for projects.
class DevProjectsRepository implements ProjectsRepository {
  final List<Project> _projects;

  DevProjectsRepository({List<Project>? initialProjects})
      : _projects = initialProjects ?? _defaultProjects();

  static List<Project> _defaultProjects() {
    final now = DateTime.now();
    return [
      Project(
        id: 'proj_dev_001',
        organizationId: 'org_dev_001',
        customerId: 'cust_dev_001',
        name: 'Core Platform Scale & RLS',
        description: 'Multi-tenant database isolation, explicit RLS, and security hardening.',
        status: 'in_progress',
        startDate: now.subtract(const Duration(days: 30)),
        dueDate: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 30)),
        customerName: 'Elena Vance',
        customerCompanyName: 'Acme Cloud Technologies',
        totalTasks: 4,
        completedTasks: 2, // 50%
      ),
      Project(
        id: 'proj_dev_002',
        organizationId: 'org_dev_001',
        customerId: 'cust_dev_002',
        name: 'AI Scoring Engine Pipeline',
        description: 'Server-side Gemini 1.5 Pro prompt orchestration & score persistence.',
        status: 'in_progress',
        startDate: now.subtract(const Duration(days: 20)),
        dueDate: now.add(const Duration(days: 25)),
        createdAt: now.subtract(const Duration(days: 20)),
        customerName: 'Marcus Sterling',
        customerCompanyName: 'Nexus Financial',
        totalTasks: 5,
        completedTasks: 4, // 80%
      ),
      Project(
        id: 'proj_dev_003',
        organizationId: 'org_dev_001',
        customerId: 'cust_dev_003',
        name: 'Enterprise Customer Portal',
        description: 'Self-service client billing, invoice payment and task tracking dashboard.',
        status: 'planning',
        startDate: now.add(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 10)),
        customerName: 'Sophia Loren',
        customerCompanyName: 'Global Logistics Ltd',
        totalTasks: 3,
        completedTasks: 0, // 0%
      ),
      Project(
        id: 'proj_dev_004',
        organizationId: 'org_dev_001',
        customerId: 'cust_dev_004',
        name: 'ISO 27001 Security Audit',
        description: 'Enterprise penetration testing, cryptographic verification and access review.',
        status: 'completed',
        startDate: now.subtract(const Duration(days: 60)),
        dueDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 60)),
        customerName: 'David Kim',
        customerCompanyName: 'Apex Capital',
        totalTasks: 3,
        completedTasks: 3, // 100%
      ),
    ];
  }

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
