import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import '../../data/datasources/leads_remote_data_source.dart';
import '../../data/repositories/leads_repository_impl.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';

export '../../domain/entities/lead.dart';
export '../../domain/repositories/leads_repository.dart';

/// Provider for the Leads Repository.
final leadsRepositoryProvider = Provider<LeadsRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      final dataSource = DevLeadsRemoteDataSource();
      return LeadsRepositoryImpl(dataSource);
    }
    final dataSource = SupabaseLeadsRemoteDataSource(client);
    return LeadsRepositoryImpl(dataSource);
  } catch (e) {
    debugPrint('Supabase unavailable for Leads, using Dev fallback: $e');
    final dataSource = DevLeadsRemoteDataSource();
    return LeadsRepositoryImpl(dataSource);
  }
});

/// Metrics data model for executive and pipeline summaries.
@immutable
class LeadMetrics {
  final int totalLeads;
  final double pipelineValue;
  final double winRate;
  final int wonLeads;

  const LeadMetrics({
    required this.totalLeads,
    required this.pipelineValue,
    required this.winRate,
    required this.wonLeads,
  });

  const LeadMetrics.empty()
    : totalLeads = 0,
      pipelineValue = 0.0,
      winRate = 0.0,
      wonLeads = 0;

  String get formattedValue => AppUtils.formatCurrency(pipelineValue);
  String get formattedWinRate =>
      totalLeads == 0 ? '0%' : '${winRate.toStringAsFixed(1)}%';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadMetrics &&
          totalLeads == other.totalLeads &&
          pipelineValue == other.pipelineValue &&
          winRate == other.winRate &&
          wonLeads == other.wonLeads;

  @override
  int get hashCode =>
      totalLeads.hashCode ^
      pipelineValue.hashCode ^
      winRate.hashCode ^
      wonLeads.hashCode;
}

/// Immutable state container for the Leads Kanban feature.
@immutable
class LeadsState {
  final List<Lead> leads;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const LeadsState({
    this.leads = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  LeadsState copyWith({
    List<Lead>? leads,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return LeadsState(
      leads: leads ?? this.leads,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadsState &&
          listEquals(leads, other.leads) &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          successMessage == other.successMessage;

  @override
  int get hashCode =>
      leads.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      successMessage.hashCode;
}

/// Riverpod StateNotifier managing lead collections, search, and optimistic stage transitions.
class LeadsNotifier extends StateNotifier<LeadsState> {
  final LeadsRepository _repository;
  final Ref _ref;

  LeadsNotifier(this._repository, this._ref) : super(const LeadsState()) {
    fetchLeads();
  }

  String get _currentOrgId {
    final org = _ref.read(currentOrganizationProvider);
    if (org != null && org.id.isNotEmpty) {
      return org.id;
    }
    final user = _ref.read(currentUserProvider);
    if (user != null && user.organizationId != null) {
      return user.organizationId!;
    }
    return 'org_dev_001';
  }

  /// Loads all leads for the active organization.
  Future<void> fetchLeads({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final list = await _repository.getLeads(_currentOrgId);
      if (!mounted) return;
      state = state.copyWith(leads: list, isLoading: false, clearError: true);
    } catch (e) {
      debugPrint('Error fetching leads: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load leads. Please check connection.',
      );
    }
  }

  /// Creates a new lead and appends it to local state.
  Future<Lead?> createLead({
    required String name,
    required String companyName,
    String? email,
    String? phone,
    LeadStage stage = LeadStage.newLead,
    double estimatedValue = 0.0,
    String? notes,
  }) async {
    if (!mounted) return null;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newLead = Lead(
        id: '',
        organizationId: _currentOrgId,
        name: name.trim(),
        companyName: companyName.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        stage: stage,
        estimatedValue: estimatedValue,
        notes: notes?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _repository.createLead(newLead);
      if (!mounted) return created;
      final updatedList = [created, ...state.leads];
      state = state.copyWith(
        leads: updatedList,
        isLoading: false,
        successMessage: 'Lead "${created.name}" created successfully.',
      );
      return created;
    } catch (e) {
      debugPrint('Error creating lead: $e');
      if (!mounted) return null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create lead. Please verify inputs.',
      );
      return null;
    }
  }

  /// Updates an existing lead record and syncs with backend.
  Future<Lead?> editLead(Lead updated) async {
    if (!mounted) return null;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final saved = await _repository.updateLead(updated);
      if (!mounted) return saved;
      final updatedList = state.leads
          .map((l) => l.id == saved.id ? saved : l)
          .toList();
      state = state.copyWith(
        leads: updatedList,
        isLoading: false,
        successMessage: 'Lead updated successfully.',
      );
      return saved;
    } catch (e) {
      debugPrint('Error editing lead: $e');
      if (!mounted) return null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update lead.',
      );
      return null;
    }
  }

  /// Optimistically updates a lead's stage and synchronizes with Supabase/Repository.
  /// If the remote update fails, automatically rolls back to the previous stage.
  Future<void> updateStageOptimistic({
    required String leadId,
    required LeadStage targetStage,
  }) async {
    if (!mounted) return;
    final leadIndex = state.leads.indexWhere((l) => l.id == leadId);
    if (leadIndex == -1) return;

    final originalLead = state.leads[leadIndex];
    if (originalLead.stage == targetStage) return;

    // 1. Optimistic local update
    final optimisticLead = originalLead.copyWith(
      stage: targetStage,
      updatedAt: DateTime.now(),
    );
    final updatedList = List<Lead>.from(state.leads);
    updatedList[leadIndex] = optimisticLead;

    state = state.copyWith(
      leads: updatedList,
      clearError: true,
      clearSuccess: true,
    );

    // 2. Asynchronous backend persistence
    try {
      await _repository.updateLeadStage(
        leadId: leadId,
        newStage: targetStage,
        organizationId: originalLead.organizationId,
      );
    } catch (e) {
      debugPrint('Backend lead stage update failed, rolling back: $e');
      if (!mounted) return;

      // 3. Rollback local state
      final rolledBackList = List<Lead>.from(state.leads);
      final currentIdx = rolledBackList.indexWhere((l) => l.id == leadId);
      if (currentIdx != -1) {
        rolledBackList[currentIdx] = originalLead;
      }

      state = state.copyWith(
        leads: rolledBackList,
        errorMessage:
            'Failed to sync stage change for "${originalLead.name}". Reverted to ${originalLead.stage.label}.',
      );
    }
  }

  /// Removes a lead record.
  Future<void> deleteLead(String leadId) async {
    if (!mounted) return;
    final index = state.leads.indexWhere((l) => l.id == leadId);
    if (index == -1) return;
    final lead = state.leads[index];

    final backup = List<Lead>.from(state.leads);
    state = state.copyWith(
      leads: state.leads.where((l) => l.id != leadId).toList(),
      clearError: true,
    );

    try {
      await _repository.deleteLead(
        leadId: leadId,
        organizationId: lead.organizationId,
      );
      if (!mounted) return;
      state = state.copyWith(successMessage: 'Lead deleted.');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        leads: backup,
        errorMessage: 'Failed to delete lead.',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

/// Primary Riverpod provider for Leads state.
final leadsNotifierProvider = StateNotifierProvider<LeadsNotifier, LeadsState>((
  ref,
) {
  final repository = ref.watch(leadsRepositoryProvider);
  // Invalidate and re-fetch when organization context changes (e.g. after onboarding)
  ref.watch(currentOrganizationProvider);
  return LeadsNotifier(repository, ref);
});

/// Active client-side search query.
final leadSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected stage filter (null represents 'All Stages').
final leadStageFilterProvider = StateProvider<LeadStage?>((ref) => null);

/// Derived provider returning leads matching current search and stage filters.
final filteredLeadsProvider = Provider<List<Lead>>((ref) {
  final allLeads = ref.watch(leadsNotifierProvider).leads;
  final query = ref.watch(leadSearchQueryProvider).trim().toLowerCase();
  final stageFilter = ref.watch(leadStageFilterProvider);

  return allLeads.where((lead) {
    // 1. Stage filter check
    if (stageFilter != null && lead.stage != stageFilter) {
      return false;
    }

    // 2. Search query check across name, company, email, phone
    if (query.isNotEmpty) {
      final matchesName = lead.name.toLowerCase().contains(query);
      final matchesCompany = lead.companyName.toLowerCase().contains(query);
      final matchesEmail =
          lead.email != null && lead.email!.toLowerCase().contains(query);
      final matchesPhone =
          lead.phone != null && lead.phone!.toLowerCase().contains(query);

      if (!matchesName && !matchesCompany && !matchesEmail && !matchesPhone) {
        return false;
      }
    }

    return true;
  }).toList();
});

/// Family provider returning filtered leads for a specific stage column.
final leadsForStageProvider = Provider.family<List<Lead>, LeadStage>((
  ref,
  stage,
) {
  final filtered = ref.watch(filteredLeadsProvider);
  return filtered.where((l) => l.stage == stage).toList();
});

/// Real-time derived pipeline metrics calculated from canonical state.
final leadMetricsProvider = Provider<LeadMetrics>((ref) {
  final leads = ref.watch(leadsNotifierProvider).leads;
  final totalLeads = leads.length;

  if (totalLeads == 0) {
    return const LeadMetrics.empty();
  }

  double totalValue = 0.0;
  int wonCount = 0;

  for (final lead in leads) {
    totalValue += lead.estimatedValue;
    if (lead.stage == LeadStage.won) {
      wonCount++;
    }
  }

  final winRate = (wonCount / totalLeads) * 100.0;

  return LeadMetrics(
    totalLeads: totalLeads,
    pipelineValue: totalValue,
    winRate: winRate,
    wonLeads: wonCount,
  );
});
