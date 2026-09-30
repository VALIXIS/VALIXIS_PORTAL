import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/team_repository.dart';

/// Production Supabase repository for Team Member and Workload management.
class SupabaseTeamRepository implements TeamRepository {
  final sp.SupabaseClient _client;

  SupabaseTeamRepository(this._client);

  @override
  Future<List<TeamMember>> getMembers(String organizationId) async {
    try {
      // 1. Fetch organization members
      final membersResponse = await _client
          .from('organization_members')
          .select(
            'id, organization_id, user_id, role, job_title, is_active, created_at',
          )
          .eq('organization_id', organizationId)
          .order('created_at', ascending: true);

      final memberRows = List<Map<String, dynamic>>.from(
        membersResponse as List,
      );
      if (memberRows.isEmpty) {
        return [];
      }

      final userIds = memberRows
          .map((m) => m['user_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      // 2. Fetch profiles for these users
      final profileMap = <String, Map<String, dynamic>>{};
      if (userIds.isNotEmpty) {
        try {
          final profilesResponse = await _client
              .from('profiles')
              .select('id, full_name, email, avatar_url')
              .inFilter('id', userIds);
          for (final p in profilesResponse as List) {
            profileMap[p['id'] as String] = p as Map<String, dynamic>;
          }
        } catch (e) {
          debugPrint('Note: Error fetching member profiles: $e');
        }
      }

      // 3. Fetch active tasks counts (assigned_to -> count where status != 'done')
      final activeTaskCounts = await getActiveWorkloads(organizationId);

      // 4. Fetch total tasks count per member
      final totalTaskCounts = <String, int>{};
      try {
        final allTasks = await _client
            .from('tasks')
            .select('assigned_to')
            .eq('organization_id', organizationId);
        for (final t in allTasks as List) {
          final assigned = t['assigned_to'] as String?;
          if (assigned != null) {
            totalTaskCounts[assigned] = (totalTaskCounts[assigned] ?? 0) + 1;
          }
        }
      } catch (e) {
        debugPrint('Note: Error fetching total task counts: $e');
      }

      // 5. Build TeamMember domain entities
      return memberRows.map((row) {
        final memberId = row['id'] as String;
        final userId = row['user_id'] as String? ?? '';
        final profile = profileMap[userId];

        final fullName =
            profile?['full_name'] as String? ??
            profile?['email'] as String? ??
            'Team Member';
        final email = profile?['email'] as String? ?? '';
        final avatarUrl = profile?['avatar_url'] as String?;

        return TeamMember(
          id: memberId,
          userId: userId,
          organizationId: organizationId,
          name: fullName,
          email: email,
          avatarUrl: avatarUrl,
          role: row['role'] as String? ?? 'employee',
          jobTitle: row['job_title'] as String?,
          isActive: row['is_active'] as bool? ?? true,
          activeTaskCount: activeTaskCounts[memberId] ?? 0,
          totalTaskCount: totalTaskCounts[memberId] ?? 0,
          createdAt: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      debugPrint('SupabaseTeamRepository getMembers error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getActiveWorkloads(String organizationId) async {
    final activeCounts = <String, int>{};
    try {
      final tasksResponse = await _client
          .from('tasks')
          .select('assigned_to')
          .eq('organization_id', organizationId)
          .neq('status', 'done');

      for (final t in tasksResponse as List) {
        final assigned = t['assigned_to'] as String?;
        if (assigned != null) {
          activeCounts[assigned] = (activeCounts[assigned] ?? 0) + 1;
        }
      }
    } catch (e) {
      debugPrint('Note: Error fetching active tasks workload: $e');
    }
    return activeCounts;
  }

  @override
  Future<TeamMember> inviteMember({
    required String organizationId,
    required String email,
    required String role,
    String? fullName,
    String? jobTitle,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw ArgumentError('Email address cannot be empty.');
    }

    final cleanRole = role.toLowerCase().trim();
    final normalizedRole = (cleanRole == 'admin' || cleanRole == 'owner')
        ? 'admin'
        : 'employee';

    // 1. Check if user with email already exists in profiles
    String? existingUserId;
    try {
      final profile = await _client
          .from('profiles')
          .select('id, full_name, email')
          .eq('email', cleanEmail)
          .maybeSingle();

      if (profile != null) {
        existingUserId = profile['id'] as String;

        // Check if already in this org
        final existingMember = await _client
            .from('organization_members')
            .select('id')
            .eq('organization_id', organizationId)
            .eq('user_id', existingUserId)
            .maybeSingle();

        if (existingMember != null) {
          throw Exception(
            'A team member with email "$cleanEmail" is already in this organization.',
          );
        }
      }
    } catch (e) {
      if (e is Exception &&
          e.toString().contains('already in this organization')) {
        rethrow;
      }
      debugPrint('Note: Profile lookup warning: $e');
    }

    // 2. Insert member record
    // If no existing user, we generate a placeholder UUID for the invited member
    final userId =
        existingUserId ??
        _client.auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000000';

    final insertPayload = {
      'organization_id': organizationId,
      'user_id': userId,
      'role': normalizedRole,
      'job_title': jobTitle?.trim().isNotEmpty == true
          ? jobTitle!.trim()
          : 'Team Member',
      'is_active': true,
    };

    final inserted = await _client
        .from('organization_members')
        .insert(insertPayload)
        .select()
        .single();

    final name = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : cleanEmail.split('@').first;

    return TeamMember(
      id: inserted['id'] as String,
      userId: userId,
      organizationId: organizationId,
      name: name,
      email: cleanEmail,
      role: normalizedRole,
      jobTitle: inserted['job_title'] as String?,
      isActive: true,
      activeTaskCount: 0,
      totalTaskCount: 0,
      createdAt: DateTime.parse(inserted['created_at'] as String),
    );
  }
}
