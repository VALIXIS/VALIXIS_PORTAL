import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';

/// The 5 enterprise sales pipeline stages in VALIXIS CRM.
enum LeadStage {
  newLead('new', 'New', Icons.fiber_new_rounded, AppColors.info),
  contacted(
    'contacted',
    'Contacted',
    Icons.chat_bubble_outline_rounded,
    AppColors.secondary,
  ),
  qualified(
    'qualified',
    'Qualified',
    Icons.verified_outlined,
    AppColors.accent,
  ),
  proposal(
    'proposal_sent',
    'Proposal',
    Icons.description_outlined,
    AppColors.warning,
  ),
  won('won', 'Won', Icons.check_circle_outline_rounded, AppColors.success);

  final String dbValue;
  final String label;
  final IconData icon;
  final Color color;

  const LeadStage(this.dbValue, this.label, this.icon, this.color);

  /// Safe deserializer handling both strict database strings and legacy UI labels.
  static LeadStage fromDb(String? value) {
    if (value == null) return LeadStage.newLead;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'proposal' || normalized == 'proposal_sent') {
      return LeadStage.proposal;
    }
    for (final stage in LeadStage.values) {
      if (stage.dbValue == normalized ||
          stage.name.toLowerCase() == normalized ||
          stage.label.toLowerCase() == normalized) {
        return stage;
      }
    }
    return LeadStage.newLead;
  }
}

/// Strongly typed Lead domain entity for VALIXIS BUSINESS OS.
@immutable
class Lead {
  final String id;
  final String organizationId;
  final String name;
  final String companyName;
  final String? email;
  final String? phone;
  final String source;
  final LeadStage stage;
  final double estimatedValue;
  final String? assignedTo;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lead({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.companyName,
    this.email,
    this.phone,
    this.source = 'manual',
    this.stage = LeadStage.newLead,
    this.estimatedValue = 0.0,
    this.assignedTo,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted monetary string based on estimated deal value.
  String get valueFormatted => AppUtils.formatCurrency(estimatedValue);

  /// Quick initial/avatar character.
  String get initial {
    if (companyName.trim().isNotEmpty) {
      return companyName.trim().substring(0, 1).toUpperCase();
    }
    if (name.trim().isNotEmpty) {
      return name.trim().substring(0, 1).toUpperCase();
    }
    return 'L';
  }

  Lead copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? companyName,
    String? email,
    String? phone,
    String? source,
    LeadStage? stage,
    double? estimatedValue,
    String? assignedTo,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lead(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      source: source ?? this.source,
      stage: stage ?? this.stage,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lead &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          name == other.name &&
          companyName == other.companyName &&
          email == other.email &&
          phone == other.phone &&
          source == other.source &&
          stage == other.stage &&
          estimatedValue == other.estimatedValue &&
          assignedTo == other.assignedTo &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      organizationId.hashCode ^
      name.hashCode ^
      companyName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      source.hashCode ^
      stage.hashCode ^
      estimatedValue.hashCode ^
      assignedTo.hashCode ^
      notes.hashCode;

  @override
  String toString() =>
      'Lead(id: $id, name: $name, company: $companyName, stage: ${stage.label}, value: $estimatedValue)';
}
