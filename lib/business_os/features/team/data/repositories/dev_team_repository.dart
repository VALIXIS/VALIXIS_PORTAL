import 'dart:async';
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/team_repository.dart';

/// In-memory development repository for local offline workflows and automated testing.
class DevTeamRepository implements TeamRepository {
  final List<TeamMember> _members;

  DevTeamRepository({List<TeamMember>? initialMembers})
    : _members = initialMembers ?? _defaultMembers();

  static List<TeamMember> _defaultMembers() {
    final now = DateTime.now();
    return [
      TeamMember(
        id: 'mem_dev_001',
        userId: 'usr_dev_001',
        organizationId: 'org_dev_001',
        name: 'Subhash',
        email: 'subhash@valixis.io',
        role: 'owner',
        jobTitle: 'Principal Architect & Co-Founder',
        isActive: true,
        activeTaskCount: 3,
        totalTaskCount: 14,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      TeamMember(
        id: 'mem_dev_002',
        userId: 'usr_dev_002',
        organizationId: 'org_dev_001',
        name: 'Jyothsna',
        email: 'jyothsna@valixis.io',
        role: 'admin',
        jobTitle: 'Lead Backend & Data Architect',
        isActive: true,
        activeTaskCount: 5,
        totalTaskCount: 22,
        createdAt: now.subtract(const Duration(days: 85)),
      ),
      TeamMember(
        id: 'mem_dev_003',
        userId: 'usr_dev_003',
        organizationId: 'org_dev_001',
        name: 'Devon Patel',
        email: 'devon.p@valixis.io',
        role: 'employee',
        jobTitle: 'Senior Frontend Engineer',
        isActive: true,
        activeTaskCount: 8, // Overloaded threshold (>= 7)
        totalTaskCount: 19,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      TeamMember(
        id: 'mem_dev_004',
        userId: 'usr_dev_004',
        organizationId: 'org_dev_001',
        name: 'Elena Rostova',
        email: 'elena.r@valixis.io',
        role: 'employee',
        jobTitle: 'Client Operations Specialist',
        isActive: true,
        activeTaskCount: 2, // Optimal threshold (< 4)
        totalTaskCount: 11,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      TeamMember(
        id: 'mem_dev_005',
        userId: 'usr_dev_005',
        organizationId: 'org_dev_001',
        name: 'Marcus Vance',
        email: 'marcus.v@valixis.io',
        role: 'employee',
        jobTitle: 'Quality Assurance & CI Lead',
        isActive: true,
        activeTaskCount: 0, // Optimal threshold (< 4)
        totalTaskCount: 7,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  @override
  Future<List<TeamMember>> getMembers(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 30));
    return List.unmodifiable(_members);
  }

  @override
  Future<Map<String, int>> getActiveWorkloads(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 20));
    final map = <String, int>{};
    for (final member in _members) {
      map[member.id] = member.activeTaskCount;
    }
    return map;
  }

  @override
  Future<TeamMember> inviteMember({
    required String organizationId,
    required String email,
    required String role,
    String? fullName,
    String? jobTitle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw ArgumentError('Email address cannot be empty.');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      throw const FormatException('Invalid email address format.');
    }

    // Check duplicate email
    final exists = _members.any((m) => m.email.toLowerCase() == cleanEmail);
    if (exists) {
      throw Exception('A team member with email "$email" already exists.');
    }

    final cleanRole = role.toLowerCase().trim();
    final normalizedRole = (cleanRole == 'admin' || cleanRole == 'owner')
        ? 'admin'
        : 'employee';

    final displayName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : cleanEmail.split('@').first;

    final newMember = TeamMember(
      id: 'mem_dev_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_dev_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: organizationId,
      name: displayName,
      email: cleanEmail,
      role: normalizedRole,
      jobTitle: jobTitle?.trim().isNotEmpty == true
          ? jobTitle!.trim()
          : 'Team Member',
      isActive: true,
      activeTaskCount: 0,
      totalTaskCount: 0,
      createdAt: DateTime.now(),
    );

    _members.add(newMember);
    return newMember;
  }
}
