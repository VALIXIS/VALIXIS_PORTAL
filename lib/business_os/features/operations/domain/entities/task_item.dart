import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Task entity matching public.tasks schema in VALIXIS BUSINESS OS.
@immutable
class TaskItem {
  final String id;
  final String organizationId;
  final String? projectId;
  final String? customerId;
  final String? assignedTo; // References organization_members.id
  final String title;
  final String? description;
  final String priority; // 'low' | 'medium' | 'high' | 'critical'
  final String status; // 'backlog' | 'in_progress' | 'under_review' | 'done'
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined display attributes
  final String? projectName;
  final String? assigneeName;
  final String? assigneeRole;
  final String? customerName;

  const TaskItem({
    required this.id,
    required this.organizationId,
    this.projectId,
    this.customerId,
    this.assignedTo,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.status = 'backlog',
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.projectName,
    this.assigneeName,
    this.assigneeRole,
    this.customerName,
  });

  bool get isBacklog => status.toLowerCase() == 'backlog';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isUnderReview => status.toLowerCase() == 'under_review';
  bool get isDone => status.toLowerCase() == 'done';

  String get statusDisplayName {
    switch (status.toLowerCase().trim()) {
      case 'in_progress':
        return 'In Progress';
      case 'under_review':
        return 'Under Review';
      case 'done':
        return 'Done';
      case 'backlog':
      default:
        return 'Backlog';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase().trim()) {
      case 'in_progress':
        return AppColors.primary;
      case 'under_review':
        return AppColors.warning;
      case 'done':
        return AppColors.success;
      case 'backlog':
      default:
        return AppColors.textMuted;
    }
  }

  bool get isCritical => priority.toLowerCase() == 'critical';
  bool get isHigh => priority.toLowerCase() == 'high';
  bool get isMedium => priority.toLowerCase() == 'medium';
  bool get isLow => priority.toLowerCase() == 'low';

  String get priorityDisplayName {
    switch (priority.toLowerCase().trim()) {
      case 'critical':
        return 'Critical';
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      case 'medium':
      default:
        return 'Medium';
    }
  }

  Color get priorityColor {
    switch (priority.toLowerCase().trim()) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'low':
        return AppColors.textMuted;
      case 'medium':
      default:
        return AppColors.primary;
    }
  }

  String get assigneeDisplay {
    if (assigneeName != null && assigneeName!.trim().isNotEmpty) {
      return assigneeName!.trim();
    }
    return 'Unassigned';
  }

  String get assigneeInitials {
    final name = assigneeDisplay;
    if (name == 'Unassigned') return 'UA';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts.first.isNotEmpty ? parts.first[0] : '';
      final last = parts.last.isNotEmpty ? parts.last[0] : '';
      return (first + last).toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  TaskItem copyWith({
    String? id,
    String? organizationId,
    String? projectId,
    String? customerId,
    String? assignedTo,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectName,
    String? assigneeName,
    String? assigneeRole,
    String? customerName,
  }) {
    return TaskItem(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      projectId: projectId ?? this.projectId,
      customerId: customerId ?? this.customerId,
      assignedTo: assignedTo ?? this.assignedTo,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectName: projectName ?? this.projectName,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeRole: assigneeRole ?? this.assigneeRole,
      customerName: customerName ?? this.customerName,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String? ?? json['organizationId'] as String? ?? '',
      projectId: json['project_id'] as String? ?? json['projectId'] as String?,
      customerId: json['customer_id'] as String? ?? json['customerId'] as String?,
      assignedTo: json['assigned_to'] as String? ?? json['assignedTo'] as String?,
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'backlog',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      projectName: json['project_name'] as String?,
      assigneeName: json['assignee_name'] as String?,
      assigneeRole: json['assignee_role'] as String?,
      customerName: json['customer_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'project_id': projectId,
      'customer_id': customerId,
      'assigned_to': assignedTo,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'project_name': projectName,
      'assignee_name': assigneeName,
      'assignee_role': assigneeRole,
      'customer_name': customerName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          projectId == other.projectId &&
          assignedTo == other.assignedTo &&
          title == other.title &&
          priority == other.priority &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      organizationId.hashCode ^
      projectId.hashCode ^
      assignedTo.hashCode ^
      title.hashCode ^
      priority.hashCode ^
      status.hashCode;
}
