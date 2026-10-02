import 'package:flutter/material.dart';

enum UserRole {
  executive('executive', 'Executive', 'Full Administrative & Financial Forecast Access'),
  manager('manager', 'Operational Manager', 'Operational Dashboard & Incident Remediation Access'),
  auditor('auditor', 'Compliance Auditor', 'Read-Only Audit Mode with Visual Compliance Watermark');

  final String code;
  final String label;
  final String description;

  const UserRole(this.code, this.label, this.description);

  static UserRole fromString(String roleStr) {
    return UserRole.values.firstWhere(
      (r) => r.code.toLowerCase() == roleStr.toLowerCase(),
      orElse: () => UserRole.auditor,
    );
  }

  bool get isExecutive => this == UserRole.executive;
  bool get isManager => this == UserRole.manager;
  bool get isAuditor => this == UserRole.auditor;

  bool get canAccessArrForecasts => isExecutive;
  bool get canRotateApiKeys => isExecutive;
  bool get canTriggerSelfHealing => isExecutive || isManager;
  bool get canConfigureAlertRules => isExecutive || isManager;
  bool get isReadOnly => isAuditor;
  bool get hasAuditorWatermark => isAuditor;

  Color get roleColor {
    switch (this) {
      case UserRole.executive:
        return const Color(0xFF00E5FF); // Electric Cyan
      case UserRole.manager:
        return const Color(0xFF00E676); // Emerald Green
      case UserRole.auditor:
        return const Color(0xFFFFB74D); // Amber Compliance Gold
    }
  }

  IconData get roleIcon {
    switch (this) {
      case UserRole.executive:
        return Icons.admin_panel_settings_rounded;
      case UserRole.manager:
        return Icons.manage_accounts_rounded;
      case UserRole.auditor:
        return Icons.verified_user_rounded;
    }
  }
}

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String organizationId;
  final UserRole role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.organizationId,
    required this.role,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? organizationId,
    UserRole? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'organization_id': organizationId,
        'role': role.code,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? 'usr_demo_01',
        email: json['email'] as String? ?? 'executive@valixis.com',
        name: json['name'] as String? ?? 'Executive User',
        organizationId: json['organization_id'] as String? ?? 'org_valixis_prod',
        role: UserRole.fromString(json['role'] as String? ?? 'executive'),
      );
}

class RbacException implements Exception {
  final String message;
  final String errorCode;

  RbacException(this.message, {this.errorCode = 'UNAUTHORIZED'});

  @override
  String toString() => 'RbacException[$errorCode]: $message';
}
