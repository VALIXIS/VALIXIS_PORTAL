class Employee {
  const Employee({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.department,
    this.avatarUrl,
    this.phone,
  });

  final String id;
  final String fullName;
  final String email;
  final String? role;
  final String? department;
  final String? avatarUrl;
  final String? phone;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String? ?? '',
      fullName: json['name'] as String? ??
          json['full_name'] as String? ??
          'Employee',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': fullName,
        'email': email,
        if (role != null) 'role': role,
        if (department != null) 'department': department,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (phone != null) 'phone': phone,
      };
}
