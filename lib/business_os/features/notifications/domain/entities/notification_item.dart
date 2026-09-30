import 'package:flutter/foundation.dart';

/// Represents an authoritative Notification entity in VALIXIS BUSINESS OS.
@immutable
class NotificationItem {
  final String id;
  final String organizationId;
  final String userId;
  final String title;
  final String message;
  final String type; // 'info', 'lead_assigned', 'task_assigned', 'invoice_paid', etc.
  final bool isRead;
  final String? link;
  final String? entityType;
  final String? entityId;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'info',
    this.isRead = false,
    this.link,
    this.entityType,
    this.entityId,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      organizationId: json['organization_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      isRead: (json['is_read'] as bool?) ?? (json['read'] as bool?) ?? false,
      link: json['link']?.toString(),
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'read': isRead,
      'link': link,
      'entity_type': entityType,
      'entity_id': entityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationItem copyWith({
    String? id,
    String? organizationId,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? link,
    String? entityType,
    String? entityId,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isRead == other.isRead;

  @override
  int get hashCode => id.hashCode ^ isRead.hashCode;
}
