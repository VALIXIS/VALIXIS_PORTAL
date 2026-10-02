class AuditVaultEntry {
  final String id;
  final String organizationId;
  final String userId;
  final String role;
  final String action;
  final String resource;
  final bool accessGranted;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const AuditVaultEntry({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.role,
    required this.action,
    required this.resource,
    required this.accessGranted,
    required this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'organization_id': organizationId,
        'user_id': userId,
        'role': role,
        'action': action,
        'resource': resource,
        'access_granted': accessGranted,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
      };

  factory AuditVaultEntry.fromJson(Map<String, dynamic> json) => AuditVaultEntry(
        id: json['id'] as String? ?? '',
        organizationId: json['organization_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        role: json['role'] as String? ?? 'auditor',
        action: json['action'] as String? ?? 'UNKNOWN_ACTION',
        resource: json['resource'] as String? ?? '',
        accessGranted: json['access_granted'] as bool? ?? true,
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
}
