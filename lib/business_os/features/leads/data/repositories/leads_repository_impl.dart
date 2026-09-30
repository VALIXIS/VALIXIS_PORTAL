import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';
import '../datasources/leads_remote_data_source.dart';
import '../models/lead_model.dart';

/// Concrete Clean Architecture implementation of [LeadsRepository].
class LeadsRepositoryImpl implements LeadsRepository {
  final LeadsRemoteDataSource _remoteDataSource;

  LeadsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Lead>> getLeads(String organizationId) async {
    final models = await _remoteDataSource.fetchLeads(organizationId);
    return models;
  }

  @override
  Future<Lead> createLead(Lead lead) async {
    final model = LeadModel.fromEntity(lead);
    final saved = await _remoteDataSource.insertLead(model);
    return saved;
  }

  @override
  Future<Lead> updateLead(Lead lead) async {
    final model = LeadModel.fromEntity(lead);
    final updated = await _remoteDataSource.updateLead(model);
    return updated;
  }

  @override
  Future<void> updateLeadStage({
    required String leadId,
    required LeadStage newStage,
    required String organizationId,
  }) async {
    await _remoteDataSource.updateStage(
      leadId: leadId,
      stageDbValue: newStage.dbValue,
      organizationId: organizationId,
    );
  }

  @override
  Future<void> deleteLead({
    required String leadId,
    required String organizationId,
  }) async {
    await _remoteDataSource.deleteLead(
      leadId: leadId,
      organizationId: organizationId,
    );
  }
}
