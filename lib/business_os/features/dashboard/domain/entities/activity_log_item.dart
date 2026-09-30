import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Domain entity representing an audit activity log entry from public.activity_logs.
@immutable
class ActivityLogItem {
  final String id;
  final String organizationId;
  final String? userId;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const ActivityLogItem({
    required this.id,
    required this.organizationId,
    this.userId,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.metadata = const {},
    required this.createdAt,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String?,
      action: json['action'] as String? ?? 'activity',
      entityType: json['entity_type'] as String? ?? 'system',
      entityId: json['entity_id'] as String? ?? '',
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : (json['metadata'] is Map
              ? Map<String, dynamic>.from(json['metadata'] as Map)
              : const {}),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Human-readable title derived from action, entityType, and metadata.
  String get displayTitle {
    if (metadata.containsKey('title') && metadata['title'] is String) {
      return metadata['title'] as String;
    }
    if (metadata.containsKey('message') && metadata['message'] is String) {
      return metadata['message'] as String;
    }

    final entityName = metadata['name'] ??
        metadata['lead_name'] ??
        metadata['invoice_number'] ??
        metadata['task_title'] ??
        metadata['customer_name'] ??
        '';

    switch (action.toLowerCase()) {
      case 'created_organization':
        return 'Organization created: ${metadata['name'] ?? ''}';
      case 'converted_lead_to_customer':
        return 'Lead converted to customer: $entityName';
      case 'lead_created':
        return 'New lead created: $entityName';
      case 'lead_stage_updated':
        final stage = metadata['stage'] ?? metadata['new_stage'] ?? '';
        return 'Lead "$entityName" moved to $stage';
      case 'invoice_created':
        return 'Invoice ${metadata['invoice_number'] ?? entityId} issued';
      case 'payment_recorded':
        final amount = metadata['amount'];
        return 'Payment received${amount != null ? ' ($amount)' : ''} for ${metadata['invoice_number'] ?? 'invoice'}';
      case 'task_created':
        return 'Task created: $entityName';
      case 'task_completed':
        return 'Task completed: $entityName';
      case 'member_invited':
        return 'New member invited: ${metadata['email'] ?? ''}';
      default:
        final cleanAction = action.replaceAll('_', ' ');
        return entityName.toString().isNotEmpty
            ? '$cleanAction: $entityName'
            : cleanAction;
    }
  }

  /// Icon associated with this activity entry.
  IconData get icon {
    switch (entityType.toLowerCase()) {
      case 'invoice':
      case 'payment':
        return Icons.receipt_long_rounded;
      case 'lead':
        return Icons.filter_alt_rounded;
      case 'customer':
        return Icons.person_outline_rounded;
      case 'task':
        return Icons.task_alt_rounded;
      case 'project':
        return Icons.folder_outlined;
      case 'organization':
      case 'team':
        return Icons.people_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  /// Accent color associated with this activity entry.
  Color get accentColor {
    switch (entityType.toLowerCase()) {
      case 'payment':
        return AppColors.success;
      case 'invoice':
        return AppColors.primary;
      case 'lead':
        return AppColors.secondary;
      case 'customer':
        return AppColors.accent;
      case 'task':
        return AppColors.warning;
      case 'project':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  /// Relative or formatted human-readable time string.
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }
}
