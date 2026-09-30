import '../entities/project.dart';

/// Contract for Projects operations in VALIXIS BUSINESS OS.
abstract class ProjectsRepository {
  /// Fetches all active projects for the given organization, including
  /// linked customer metadata and aggregated task completion counts.
  Future<List<Project>> getProjects(String organizationId);

  /// Creates a new project in the organization.
  Future<Project> createProject({
    required String organizationId,
    required String customerId,
    required String name,
    String? description,
    String status = 'planning',
    DateTime? startDate,
    DateTime? dueDate,
  });
}
