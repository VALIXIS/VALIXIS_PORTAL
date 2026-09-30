import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/lead.dart';
import '../models/lead_model.dart';

/// Contract for leads remote data interactions.
abstract class LeadsRemoteDataSource {
  Future<List<LeadModel>> fetchLeads(String organizationId);
  Future<LeadModel> insertLead(LeadModel lead);
  Future<LeadModel> updateLead(LeadModel lead);
  Future<void> updateStage({
    required String leadId,
    required String stageDbValue,
    required String organizationId,
  });
  Future<void> deleteLead({
    required String leadId,
    required String organizationId,
  });
}

/// Supabase Postgres implementation targeting the `leads` table.
class SupabaseLeadsRemoteDataSource implements LeadsRemoteDataSource {
  final SupabaseClient _client;

  SupabaseLeadsRemoteDataSource(this._client);

  @override
  Future<List<LeadModel>> fetchLeads(String organizationId) async {
    try {
      final response = await _client
          .from('leads')
          .select()
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      final list = (response as List).cast<Map<String, dynamic>>();
      return list.map((m) => LeadModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching leads from Supabase: $e');
      rethrow;
    }
  }

  @override
  Future<LeadModel> insertLead(LeadModel lead) async {
    try {
      final response = await _client
          .from('leads')
          .insert(lead.toInsertMap())
          .select()
          .single();

      return LeadModel.fromMap(response);
    } catch (e) {
      debugPrint('Error inserting lead to Supabase: $e');
      rethrow;
    }
  }

  @override
  Future<LeadModel> updateLead(LeadModel lead) async {
    try {
      final response = await _client
          .from('leads')
          .update(lead.toMap())
          .eq('id', lead.id)
          .eq('organization_id', lead.organizationId)
          .select()
          .single();

      return LeadModel.fromMap(response);
    } catch (e) {
      debugPrint('Error updating lead in Supabase: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStage({
    required String leadId,
    required String stageDbValue,
    required String organizationId,
  }) async {
    try {
      await _client
          .from('leads')
          .update({
            'status': stageDbValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', leadId)
          .eq('organization_id', organizationId);
    } catch (e) {
      debugPrint('Error updating lead stage in Supabase: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLead({
    required String leadId,
    required String organizationId,
  }) async {
    try {
      await _client
          .from('leads')
          .delete()
          .eq('id', leadId)
          .eq('organization_id', organizationId);
    } catch (e) {
      debugPrint('Error deleting lead in Supabase: $e');
      rethrow;
    }
  }
}

/// In-memory dev/offline implementation with realistic enterprise initial data.
class DevLeadsRemoteDataSource implements LeadsRemoteDataSource {
  final List<LeadModel> _leads = [];
  bool simulateFailure = false;

  DevLeadsRemoteDataSource({List<LeadModel>? initialLeads}) {
    if (initialLeads != null) {
      _leads.addAll(initialLeads);
    } else {
      _seedDefaultLeads();
    }
  }

  void _seedDefaultLeads() {
    final now = DateTime.now();
    _leads.addAll([
      LeadModel(
        id: 'lead_dev_001',
        organizationId: 'org_dev_001',
        name: 'Elena Rostova',
        companyName: 'Nexus Global Logistics',
        email: 'elena.rostova@nexusglobal.io',
        phone: '+1 (555) 234-8901',
        source: 'Website Inquiry',
        stage: LeadStage.newLead,
        estimatedValue: 45000.0,
        notes: 'Inquired about supply chain workflow automation and analytics.',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      LeadModel(
        id: 'lead_dev_002',
        organizationId: 'org_dev_001',
        name: 'Marcus Vance',
        companyName: 'Hyperion FinTech Labs',
        email: 'marcus.v@hyperionlabs.com',
        phone: '+1 (555) 891-2345',
        source: 'Partner Referral',
        stage: LeadStage.contacted,
        estimatedValue: 120000.0,
        notes: 'Introductory discovery call conducted. Scheduled tech review.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      LeadModel(
        id: 'lead_dev_003',
        organizationId: 'org_dev_001',
        name: 'Devon Patel',
        companyName: 'Solaris Cloud Computing',
        email: 'd.patel@solariscloud.net',
        phone: '+1 (555) 432-9876',
        source: 'Inbound Lead',
        stage: LeadStage.qualified,
        estimatedValue: 32500.0,
        notes: 'Budget confirmed for Q4 deployment. Security audit pending.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      LeadModel(
        id: 'lead_dev_004',
        organizationId: 'org_dev_001',
        name: 'Sarah Jenkins',
        companyName: 'Vanguard Biometrics Inc.',
        email: 'sjenkins@vanguardbio.org',
        phone: '+1 (555) 678-1234',
        source: 'Outbound Campaign',
        stage: LeadStage.proposal,
        estimatedValue: 88000.0,
        notes:
            'Master service agreement and SLA proposal under executive review.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      LeadModel(
        id: 'lead_dev_005',
        organizationId: 'org_dev_001',
        name: 'Liam O\'Connor',
        companyName: 'Aegis Security Solutions',
        email: 'liam@aegissecurity.ie',
        phone: '+353 1 496 0000',
        source: 'Direct Referral',
        stage: LeadStage.won,
        estimatedValue: 65000.0,
        notes: 'Contract signed. Initial onboarding kickoff scheduled.',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  @override
  Future<List<LeadModel>> fetchLeads(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (simulateFailure) {
      throw Exception('Dev simulated fetch error');
    }
    return _leads.where((l) => l.organizationId == organizationId).toList();
  }

  @override
  Future<LeadModel> insertLead(LeadModel lead) async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (simulateFailure) {
      throw Exception('Dev simulated insert error');
    }
    final created = LeadModel(
      id: lead.id.isNotEmpty && !lead.id.startsWith('temp_')
          ? lead.id
          : 'lead_dev_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: lead.organizationId,
      name: lead.name,
      companyName: lead.companyName,
      email: lead.email,
      phone: lead.phone,
      source: lead.source,
      stage: lead.stage,
      estimatedValue: lead.estimatedValue,
      assignedTo: lead.assignedTo,
      notes: lead.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _leads.insert(0, created);
    return created;
  }

  @override
  Future<LeadModel> updateLead(LeadModel lead) async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (simulateFailure) {
      throw Exception('Dev simulated update error');
    }
    final index = _leads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      final updated = LeadModel.fromEntity(
        lead.copyWith(updatedAt: DateTime.now()),
      );
      _leads[index] = updated;
      return updated;
    }
    throw Exception('Lead not found: ${lead.id}');
  }

  @override
  Future<void> updateStage({
    required String leadId,
    required String stageDbValue,
    required String organizationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (simulateFailure) {
      throw Exception('Dev simulated stage update error');
    }
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final current = _leads[index];
      _leads[index] = LeadModel.fromEntity(
        current.copyWith(
          stage: LeadStage.fromDb(stageDbValue),
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }
    throw Exception('Lead not found: $leadId');
  }

  @override
  Future<void> deleteLead({
    required String leadId,
    required String organizationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (simulateFailure) {
      throw Exception('Dev simulated delete error');
    }
    _leads.removeWhere((l) => l.id == leadId);
  }
}
