/// Realtime In-App Notification Model for the Dashboard Bell Icon
class InAppNotification {
  final String id;
  final String orgId;
  final String? ruleId;
  final String title;
  final String message;
  final String severity; // 'CRITICAL', 'WARNING', 'INFO'
  bool isRead;
  final DateTime createdAt;

  InAppNotification({
    required this.id,
    required this.orgId,
    this.ruleId,
    required this.title,
    required this.message,
    required this.severity,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'rule_id': ruleId,
      'title': title,
      'message': message,
      'severity': severity,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'] as String? ?? 'notif_000',
      orgId: json['org_id'] as String? ?? 'org_valixis_01',
      ruleId: json['rule_id'] as String?,
      title: json['title'] as String? ?? 'System Alert',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'WARNING',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
