import 'dart:async';
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/team_repository.dart';

/// In-memory development repository for local offline workflows and automated testing.
class DevTeamRepository implements TeamRepository {
  final List<TeamMember> _members;

  DevTeamRepository({List<TeamMember>? initialMembers})
    : _members = initialMembers ?? _defaultMembers();

  static List<TeamMember> _defaultMembers() => const [];

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
