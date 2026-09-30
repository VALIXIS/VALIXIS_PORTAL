import 'package:flutter/foundation.dart';

/// Workload categorization based on active assigned tasks.
enum WorkloadLevel {
  optimal, // 0 - 3 active tasks (Normal/Safe capacity)
  moderate, // 4 - 6 active tasks (Balanced/Moderate workload)
  overloaded, // 7+ active tasks (High strain/Over capacity)
}

/// Strongly typed Team Member domain entity for VALIXIS BUSINESS OS.
@immutable
class TeamMember {
  final String id;
  final String userId;
  final String organizationId;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // 'owner' | 'admin' | 'employee'
  final String? jobTitle;
  final bool isActive;
  final int activeTaskCount;
  final int totalTaskCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeamMember({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.jobTitle,
    this.isActive = true,
    this.activeTaskCount = 0,
    this.totalTaskCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Whether member has admin or owner privileges.
  bool get isAdmin {
    final r = role.toLowerCase().trim();
    return r == 'owner' || r == 'admin';
  }

  /// Whether member is the primary organization owner.
  bool get isOwner => role.toLowerCase().trim() == 'owner';

  /// Standardized display name for member role.
  String get roleDisplayName {
    final r = role.toLowerCase().trim();
    if (r == 'owner') return 'Owner';
    if (r == 'admin') return 'Admin';
    return 'Employee';
  }

  /// Derived initials for avatar fallback (e.g., 'Subhash Doe' -> 'SD', 'Devon' -> 'DP' or 'D').
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'U';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts.first.isNotEmpty ? parts.first[0] : '';
      final last = parts.last.isNotEmpty ? parts.last[0] : '';
      return (first + last).toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.substring(0, 1).toUpperCase();
  }

  /// Normalized workload ratio clamped between 0.0 and 1.0 (baseline standard 10 tasks max).
  double get workloadPercentage => (activeTaskCount / 10).clamp(0.0, 1.0);

  /// Workload classification based on enterprise threshold rules.
  WorkloadLevel get workloadLevel {
    if (activeTaskCount >= 7) return WorkloadLevel.overloaded;
    if (activeTaskCount >= 4) return WorkloadLevel.moderate;
    return WorkloadLevel.optimal;
  }

  /// Human-friendly workload label.
  String get workloadLabel {
    switch (workloadLevel) {
      case WorkloadLevel.overloaded:
        return 'Overloaded';
      case WorkloadLevel.moderate:
        return 'Moderate';
      case WorkloadLevel.optimal:
        return 'Optimal';
    }
  }

  TeamMember copyWith({
    String? id,
    String? userId,
    String? organizationId,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    String? jobTitle,
    bool? isActive,
    int? activeTaskCount,
    int? totalTaskCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      jobTitle: jobTitle ?? this.jobTitle,
      isActive: isActive ?? this.isActive,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
      totalTaskCount: totalTaskCount ?? this.totalTaskCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      organizationId:
          json['organization_id'] as String? ??
          json['organizationId'] as String? ??
          '',
      name:
          json['name'] as String? ??
          json['full_name'] as String? ??
          json['email'] as String? ??
          'Unknown Member',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'employee',
      jobTitle:
          json['job_title'] as String? ?? json['jobTitle'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      activeTaskCount:
          json['active_task_count'] as int? ??
          json['activeTaskCount'] as int? ??
          0,
      totalTaskCount:
          json['total_task_count'] as int? ??
          json['totalTaskCount'] as int? ??
          0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'job_title': jobTitle,
      'is_active': isActive,
      'active_task_count': activeTaskCount,
      'total_task_count': totalTaskCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamMember &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          organizationId == other.organizationId &&
          role == other.role &&
          email == other.email &&
          activeTaskCount == other.activeTaskCount;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      organizationId.hashCode ^
      role.hashCode ^
      email.hashCode ^
      activeTaskCount.hashCode;
}
