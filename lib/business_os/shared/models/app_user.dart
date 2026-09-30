/// Represents an authenticated user in VALIXIS BUSINESS OS.
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? avatarUrl;
  final String? organizationId;
  final String organizationName;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.organizationId,
    required this.organizationName,
  });

  bool get hasOrganization =>
      organizationId != null &&
      organizationId!.isNotEmpty &&
      organizationName.isNotEmpty;

  /// Whether user has administrative or ownership permissions.
  bool get isAdmin {
    final r = role.toLowerCase().trim();
    return r == 'owner' ||
        r == 'admin' ||
        r.contains('admin') ||
        r.contains('executive') ||
        r.contains('owner');
  }

  /// Whether user is a regular employee/member.
  bool get isEmployee => !isAdmin;

  /// Factory for initial development fallback (Admin)
  factory AppUser.devAdmin({bool withOrganization = true}) {
    return AppUser(
      id: 'usr_dev_001',
      email: 'admin@valixis.io',
      displayName: 'Subhash / Jyothsna',
      role: 'Principal Executive',
      organizationId: withOrganization ? 'org_dev_001' : null,
      organizationName: withOrganization ? 'VALIXIS Global Enterprise' : '',
    );
  }

  /// Factory for testing standard employee permissions
  factory AppUser.devEmployee({bool withOrganization = true}) {
    return AppUser(
      id: 'usr_dev_002',
      email: 'employee@valixis.io',
      displayName: 'Devon Patel',
      role: 'employee',
      organizationId: withOrganization ? 'org_dev_001' : null,
      organizationName: withOrganization ? 'VALIXIS Global Enterprise' : '',
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? avatarUrl,
    String? organizationId,
    String? organizationName,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          organizationId == other.organizationId;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ organizationId.hashCode;
}
