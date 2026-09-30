import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../data/services/supabase_lead_scoring_service.dart';
import '../../domain/entities/lead_score.dart';
import '../../domain/services/lead_scoring_service.dart';

export '../../domain/entities/lead_score.dart';
export '../../domain/services/lead_scoring_service.dart';

/// Immutable states representing lead AI qualification lifecycle.
@immutable
sealed class LeadScoreState {
  const LeadScoreState();
}

/// Initial resting state before an AI evaluation has been requested.
class LeadScoreIdle extends LeadScoreState {
  const LeadScoreIdle();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LeadScoreIdle;

  @override
  int get hashCode => 0;
}

/// Active asynchronous state while Gemini is analyzing the lead.
class LeadScoreScoring extends LeadScoreState {
  const LeadScoreScoring();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LeadScoreScoring;

  @override
  int get hashCode => 1;
}

/// Successfully evaluated state with validated [LeadScore].
class LeadScoreSuccess extends LeadScoreState {
  final LeadScore score;
  const LeadScoreSuccess(this.score);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadScoreSuccess && score == other.score;

  @override
  int get hashCode => score.hashCode;
}

/// Failure state with an actionable error description and retry capability.
class LeadScoreError extends LeadScoreState {
  final String message;
  const LeadScoreError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadScoreError && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// StateNotifier handling per-lead AI scoring without blocking other leads.
class LeadScoreNotifier extends StateNotifier<LeadScoreState> {
  final LeadScoringService _service;
  final String _leadId;

  LeadScoreNotifier(this._service, this._leadId) : super(const LeadScoreIdle());

  /// Triggers server-side Gemini lead quality evaluation.
  Future<void> score({required String? note}) async {
    if (note == null || note.trim().isEmpty) {
      state = const LeadScoreError('Add lead notes before scoring with AI.');
      return;
    }

    state = const LeadScoreScoring();
    try {
      final result = await _service.scoreLead(
        leadId: _leadId,
        note: note.trim(),
      );
      if (!mounted) return;
      state = LeadScoreSuccess(result);
    } catch (e) {
      if (!mounted) return;
      state = LeadScoreError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Resets state back to idle.
  void reset() {
    if (!mounted) return;
    state = const LeadScoreIdle();
  }
}

/// Provider for the [LeadScoringService] abstraction.
final leadScoringServiceProvider = Provider<LeadScoringService>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    return SupabaseLeadScoringService(client);
  } catch (e) {
    debugPrint(
      'Supabase unavailable for AI Lead Scorer, using Dev fallback: $e',
    );
    return DevLeadScoringService();
  }
});

/// Granular per-lead Riverpod family provider preventing global UI re-renders.
final leadScoreProvider =
    StateNotifierProvider.family<LeadScoreNotifier, LeadScoreState, String>((
      ref,
      leadId,
    ) {
      final service = ref.watch(leadScoringServiceProvider);
      return LeadScoreNotifier(service, leadId);
    });
