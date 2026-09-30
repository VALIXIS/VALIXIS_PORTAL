import '../entities/team_member.dart';

/// Contract for Team and Member Workload management in VALIXIS BUSINESS OS.
abstract class TeamRepository {
  /// Fetches all organization members with aggregated task workloads.
  Future<List<TeamMember>> getMembers(String organizationId);

  /// Invites a new member to join the tenant organization.
  /// Throws an exception if an active member with the email already exists,
  /// or if caller lacks administrative privileges.
  Future<TeamMember> inviteMember({
    required String organizationId,
    required String email,
    required String role,
    String? fullName,
    String? jobTitle,
  });

  /// Fetches active workload task counts grouped by member ID for the given organization.
  Future<Map<String, int>> getActiveWorkloads(String organizationId);
}
