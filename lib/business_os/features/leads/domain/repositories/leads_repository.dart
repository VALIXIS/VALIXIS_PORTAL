import '../entities/lead.dart';

/// Abstract contract for Leads CRM persistence and synchronization.
abstract class LeadsRepository {
  /// Fetches all active leads for the specified organization.
  Future<List<Lead>> getLeads(String organizationId);

  /// Persists a newly created lead.
  Future<Lead> createLead(Lead lead);

  /// Updates all mutable fields of an existing lead.
  Future<Lead> updateLead(Lead lead);

  /// Performs a targeted stage/status update for an individual lead.
  Future<void> updateLeadStage({
    required String leadId,
    required LeadStage newStage,
    required String organizationId,
  });

  /// Deletes or archives a lead record.
  Future<void> deleteLead({
    required String leadId,
    required String organizationId,
  });
}
