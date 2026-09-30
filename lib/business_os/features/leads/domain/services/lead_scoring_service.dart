import '../entities/lead_score.dart';

/// Contract for AI-powered lead qualification scoring service.
abstract interface class LeadScoringService {
  /// Invokes server-side Gemini intelligence to evaluate a lead's purchase intent and quality score.
  Future<LeadScore> scoreLead({required String leadId, required String note});
}
