import 'package:flutter/foundation.dart';

/// Project domain entity for VALIXIS BUSINESS OS.
@immutable
class Project {
  final String id;
  final String organizationId;
  final String? customerId;
  final String name;
  final String? description;
  final String status; // 'planning' | 'in_progress' | 'on_hold' | 'completed'
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined display attributes
  final String? customerName;
  final String? customerCompanyName;
  final int totalTasks;
  final int completedTasks;

  const Project({
    required this.id,
    required this.organizationId,
    this.customerId,
    required this.name,
    this.description,
    this.status = 'planning',
    this.startDate,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerCompanyName,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  /// Real-time task completion percentage safely clamped between 0 and 100.
  double get completionPercentage {
    if (totalTasks <= 0) return 0.0;
    final ratio = (completedTasks / totalTasks) * 100.0;
    return ratio.clamp(0.0, 100.0);
  }

  /// Normalized completion fraction for linear progress indicators (0.0 to 1.0).
  double get completionFraction => (completionPercentage / 100.0).clamp(0.0, 1.0);

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isPlanning => status.toLowerCase() == 'planning';
  bool get isOnHold => status.toLowerCase() == 'on_hold';

  String get statusDisplayName {
    switch (status.toLowerCase().trim()) {
      case 'in_progress':
        return 'In Progress';
      case 'on_hold':
        return 'On Hold';
      case 'completed':
        return 'Completed';
      case 'planning':
      default:
        return 'Planning';
    }
  }

  /// Best display label for linked customer (company or primary contact).
  String get customerDisplayTag {
    if (customerCompanyName != null && customerCompanyName!.trim().isNotEmpty) {
      return customerCompanyName!.trim();
    }
    if (customerName != null && customerName!.trim().isNotEmpty) {
      return customerName!.trim();
    }
    return 'Internal Client';
  }

  Project copyWith({
    String? id,
    String? organizationId,
    String? customerId,
    String? name,
    String? description,
    String? status,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerCompanyName,
    int? totalTasks,
    int? completedTasks,
  }) {
    return Project(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerCompanyName: customerCompanyName ?? this.customerCompanyName,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String? ?? json['organizationId'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? json['customerId'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Project',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'planning',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      customerName: json['customer_name'] as String?,
      customerCompanyName: json['customer_company_name'] as String?,
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'customer_id': customerId,
      'name': name,
      'description': description,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'customer_name': customerName,
      'customer_company_name': customerCompanyName,
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          customerId == other.customerId &&
          name == other.name &&
          status == other.status &&
          totalTasks == other.totalTasks &&
          completedTasks == other.completedTasks;

  @override
  int get hashCode =>
      id.hashCode ^
      organizationId.hashCode ^
      customerId.hashCode ^
      name.hashCode ^
      status.hashCode ^
      totalTasks.hashCode ^
      completedTasks.hashCode;
}
