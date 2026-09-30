import '../../domain/entities/lead.dart';

/// Data transfer object and JSON serializer for [Lead].
class LeadModel extends Lead {
  const LeadModel({
    required super.id,
    required super.organizationId,
    required super.name,
    required super.companyName,
    super.email,
    super.phone,
    super.source = 'manual',
    super.stage = LeadStage.newLead,
    super.estimatedValue = 0.0,
    super.assignedTo,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory deserializer converting Supabase database rows into [LeadModel].
  factory LeadModel.fromMap(Map<String, dynamic> map) {
    return LeadModel(
      id: map['id']?.toString() ?? '',
      organizationId: map['organization_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      companyName:
          map['company_name']?.toString() ??
          map['company']?.toString() ??
          'Unnamed Account',
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      source: map['source']?.toString() ?? 'manual',
      stage: LeadStage.fromDb(map['status']?.toString()),
      estimatedValue:
          (map['estimated_value'] as num?)?.toDouble() ??
          (map['value'] as num?)?.toDouble() ??
          0.0,
      assignedTo: map['assigned_to']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts a domain [Lead] into [LeadModel].
  factory LeadModel.fromEntity(Lead lead) {
    return LeadModel(
      id: lead.id,
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
      createdAt: lead.createdAt,
      updatedAt: lead.updatedAt,
    );
  }

  /// Serializes into database columns matching the backend `leads` table schema.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'source': source,
      'status': stage.dbValue,
      'estimated_value': estimatedValue,
      'assigned_to': assignedTo,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map for database inserts (omitting server-generated defaults if empty).
  Map<String, dynamic> toInsertMap() {
    final map = <String, dynamic>{
      'organization_id': organizationId,
      'name': name,
      'company_name': companyName,
      'status': stage.dbValue,
      'estimated_value': estimatedValue,
      'source': source,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (id.isNotEmpty && !id.startsWith('temp_')) {
      map['id'] = id;
    }
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (phone != null && phone!.trim().isNotEmpty) {
      map['phone'] = phone!.trim();
    }
    if (assignedTo != null && assignedTo!.isNotEmpty) {
      map['assigned_to'] = assignedTo;
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}
