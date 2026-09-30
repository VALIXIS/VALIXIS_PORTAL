import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import '../../data/repositories/dev_team_repository.dart';
import '../../data/repositories/supabase_team_repository.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/team_repository.dart';

export '../../domain/entities/team_member.dart';
export '../../domain/repositories/team_repository.dart';

/// Provider for TeamRepository (Supabase with Dev fallback).
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      return DevTeamRepository();
    }
    return SupabaseTeamRepository(client);
  } catch (e) {
    debugPrint(
      'Supabase unavailable for TeamRepository, using Dev fallback: $e',
    );
    return DevTeamRepository();
  }
});

/// Immutable state for Team Management screen and workload directory.
@immutable
class TeamState {
  final List<TeamMember> members;
  final bool isLoading;
  final bool isSubmittingInvite;
  final String? error;
  final String? inviteError;
  final String? inviteSuccessMessage;
  final String searchQuery;
  final String roleFilter; // 'all' | 'admin' | 'employee'

  const TeamState({
    required this.members,
    this.isLoading = false,
    this.isSubmittingInvite = false,
    this.error,
    this.inviteError,
    this.inviteSuccessMessage,
    this.searchQuery = '',
    this.roleFilter = 'all',
  });

  const TeamState.initial()
    : members = const [],
      isLoading = true,
      isSubmittingInvite = false,
      error = null,
      inviteError = null,
      inviteSuccessMessage = null,
      searchQuery = '',
      roleFilter = 'all';

  int get totalCount => members.length;

  int get adminCount => members.where((m) => m.isAdmin).length;

  int get employeeCount => members.where((m) => !m.isAdmin).length;

  int get totalActiveTasks =>
      members.fold<int>(0, (sum, m) => sum + m.activeTaskCount);

  int get overloadedCount =>
      members.where((m) => m.workloadLevel == WorkloadLevel.overloaded).length;

  int get moderateCount =>
      members.where((m) => m.workloadLevel == WorkloadLevel.moderate).length;

  int get optimalCount =>
      members.where((m) => m.workloadLevel == WorkloadLevel.optimal).length;

  /// Derived list of members filtered by search query and role selection.
  List<TeamMember> get filteredMembers {
    return members.where((m) {
      // Role filter
      if (roleFilter == 'admin' && !m.isAdmin) return false;
      if (roleFilter == 'employee' && m.isAdmin) return false;

      // Search filter
      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.toLowerCase().trim();
      return m.name.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          (m.jobTitle != null && m.jobTitle!.toLowerCase().contains(q)) ||
          m.role.toLowerCase().contains(q);
    }).toList();
  }

  TeamState copyWith({
    List<TeamMember>? members,
    bool? isLoading,
    bool? isSubmittingInvite,
    String? error,
    String? inviteError,
    String? inviteSuccessMessage,
    String? searchQuery,
    String? roleFilter,
    bool clearInviteError = false,
    bool clearInviteSuccess = false,
    bool clearError = false,
  }) {
    return TeamState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      isSubmittingInvite: isSubmittingInvite ?? this.isSubmittingInvite,
      error: clearError ? null : (error ?? this.error),
      inviteError: clearInviteError ? null : (inviteError ?? this.inviteError),
      inviteSuccessMessage: clearInviteSuccess
          ? null
          : (inviteSuccessMessage ?? this.inviteSuccessMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
    );
  }
}

/// State notifier managing team members, filtering, and invitations.
class TeamMembersNotifier extends StateNotifier<TeamState> {
  final TeamRepository _repository;
  final Ref _ref;

  TeamMembersNotifier(this._repository, this._ref)
    : super(const TeamState.initial()) {
    loadMembers();
  }

  String get _currentOrgId {
    final org = _ref.read(currentOrganizationProvider);
    if (org != null && org.id.isNotEmpty) {
      return org.id;
    }
    final user = _ref.read(currentUserProvider);
    if (user != null &&
        user.organizationId != null &&
        user.organizationId!.isNotEmpty) {
      return user.organizationId!;
    }
    return 'org_dev_001';
  }

  bool get _isCurrentUserAdmin {
    final user = _ref.read(currentUserProvider);
    return user?.isAdmin ?? true;
  }

  Future<void> loadMembers({bool refresh = false}) async {
    if (!mounted) return;
    if (refresh || state.members.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final members = await _repository.getMembers(_currentOrgId);
      if (!mounted) return;
      state = state.copyWith(
        members: members,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      debugPrint('Error loading team members: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load team members: ${e.toString()}',
      );
    }
  }

  void setSearchQuery(String query) {
    if (!mounted) return;
    state = state.copyWith(searchQuery: query);
  }

  void setRoleFilter(String role) {
    if (!mounted) return;
    state = state.copyWith(roleFilter: role);
  }

  void clearInviteStatus() {
    if (!mounted) return;
    state = state.copyWith(clearInviteError: true, clearInviteSuccess: true);
  }

  Future<bool> inviteMember({
    required String email,
    required String role,
    String? fullName,
    String? jobTitle,
  }) async {
    // 1. Role Guard Check
    if (!_isCurrentUserAdmin) {
      if (mounted) {
        state = state.copyWith(
          inviteError:
              'Permission denied: Only Administrators and Owners can invite new members.',
        );
      }
      return false;
    }

    if (!mounted) return false;
    state = state.copyWith(
      isSubmittingInvite: true,
      clearInviteError: true,
      clearInviteSuccess: true,
    );

    try {
      final newMember = await _repository.inviteMember(
        organizationId: _currentOrgId,
        email: email,
        role: role,
        fullName: fullName,
        jobTitle: jobTitle,
      );

      if (!mounted) return true;
      final updatedList = List<TeamMember>.from(state.members)..add(newMember);
      state = state.copyWith(
        members: updatedList,
        isSubmittingInvite: false,
        inviteSuccessMessage: 'Invitation successfully sent to $email.',
        clearInviteError: true,
      );
      return true;
    } catch (e) {
      debugPrint('Error inviting member: $e');
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring('Exception: '.length);
      }
      if (mounted) {
        state = state.copyWith(isSubmittingInvite: false, inviteError: msg);
      }
      return false;
    }
  }
}

/// Primary Riverpod StateNotifierProvider for Team Management.
final teamMembersProvider =
    StateNotifierProvider<TeamMembersNotifier, TeamState>((ref) {
      final repo = ref.watch(teamRepositoryProvider);
      return TeamMembersNotifier(repo, ref);
    });

/// Provider checking whether current user has Admin privileges.
final isCurrentUserAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});
