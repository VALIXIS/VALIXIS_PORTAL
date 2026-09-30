import 'package:flutter/foundation.dart';

/// Strongly typed Customer domain entity for VALIXIS BUSINESS OS.
@immutable
class Customer {
  final String id;
  final String organizationId;
  final String name; // Primary Contact Name
  final String companyName;
  final String email;
  final String? phone;
  final String status; // 'active' | 'inactive'
  final String? convertedFromLeadId;
  final String? billingAddress;
  final String? taxId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.companyName,
    required this.email,
    this.phone,
    this.status = 'active',
    this.convertedFromLeadId,
    this.billingAddress,
    this.taxId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  /// Quick avatar / branding initial character.
  String get initial {
    if (companyName.trim().isNotEmpty) {
      return companyName.trim().substring(0, 1).toUpperCase();
    }
    if (name.trim().isNotEmpty) {
      return name.trim().substring(0, 1).toUpperCase();
    }
    return 'C';
  }

  Customer copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? companyName,
    String? email,
    String? phone,
    String? status,
    String? convertedFromLeadId,
    String? billingAddress,
    String? taxId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      convertedFromLeadId: convertedFromLeadId ?? this.convertedFromLeadId,
      billingAddress: billingAddress ?? this.billingAddress,
      taxId: taxId ?? this.taxId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          name == other.name &&
          companyName == other.companyName &&
          email == other.email &&
          phone == other.phone &&
          status == other.status &&
          convertedFromLeadId == other.convertedFromLeadId &&
          billingAddress == other.billingAddress &&
          taxId == other.taxId;

  @override
  int get hashCode =>
      id.hashCode ^
      organizationId.hashCode ^
      name.hashCode ^
      companyName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      status.hashCode ^
      convertedFromLeadId.hashCode ^
      billingAddress.hashCode ^
      taxId.hashCode;

  @override
  String toString() =>
      'Customer(id: $id, company: $companyName, contact: $name, email: $email, status: $status)';
}
