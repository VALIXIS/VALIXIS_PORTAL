import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/lead_score.dart';
import '../../domain/services/lead_scoring_service.dart';

/// Concrete Supabase Edge Function implementation of [LeadScoringService].
class SupabaseLeadScoringService implements LeadScoringService {
  final SupabaseClient _client;

  SupabaseLeadScoringService(this._client);

  @override
  Future<LeadScore> scoreLead({
    required String leadId,
    required String note,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'ai-lead-scorer',
        body: {'leadId': leadId, 'note': note},
      );

      if (response.status != 200) {
        final errorData = response.data;
        final message = errorData is Map && errorData.containsKey('error')
            ? errorData['error'].toString()
            : 'AI scoring failed with status ${response.status}';
        throw Exception(message);
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        if (data is Map) {
          return LeadScore.fromJson(Map<String, dynamic>.from(data));
        }
        throw const FormatException(
          'Invalid response format from AI Lead Scorer',
        );
      }

      return LeadScore.fromJson(data);
    } catch (e) {
      debugPrint('Error invoking ai-lead-scorer edge function: $e');
      rethrow;
    }
  }
}

/// In-memory and offline development implementation with realistic scoring heuristics.
class DevLeadScoringService implements LeadScoringService {
  bool simulateFailure = false;

  @override
  Future<LeadScore> scoreLead({
    required String leadId,
    required String note,
  }) async {
    // Simulate network latency of server-side inference
    await Future.delayed(const Duration(milliseconds: 250));

    if (simulateFailure) {
      throw Exception('Simulated AI scoring network timeout');
    }

    final lower = note.toLowerCase();

    // High intent indicators: confirmed budget, contracts, executive sign-off
    if (lower.contains('contract') ||
        lower.contains('signed') ||
        lower.contains('budget confirmed') ||
        lower.contains('procurement') ||
        lower.contains('enterprise') ||
        lower.contains('sla')) {
      return const LeadScore(
        score: 91,
        intent: LeadIntent.high,
        action:
            'Contact the decision-maker today to confirm final procurement timeline.',
      );
    }

    // Medium intent indicators: discovery, tech review, proposal under review
    if (lower.contains('proposal') ||
        lower.contains('review') ||
        lower.contains('discovery') ||
        lower.contains('scheduled') ||
        lower.contains('demo')) {
      return const LeadScore(
        score: 68,
        intent: LeadIntent.med,
        action:
            'Send proposal follow-up with technical specifications and ROI data.',
      );
    }

    // Default / Low intent indicators: general inquiries or ambiguous notes
    return const LeadScore(
      score: 34,
      intent: LeadIntent.low,
      action:
          'Enroll in automated nurture campaign and follow up in two weeks.',
    );
  }
}
