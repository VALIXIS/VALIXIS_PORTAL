import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_360.dart';

/// Data transfer model mapping Supabase database schema to [Customer].
class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.organizationId,
    required super.name,
    required super.companyName,
    required super.email,
    super.phone,
    super.status,
    super.convertedFromLeadId,
    super.billingAddress,
    super.taxId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String? ?? '',
      organizationId: json['organization_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'active',
      convertedFromLeadId: json['converted_from_lead_id'] as String?,
      billingAddress: json['billing_address'] as String?,
      taxId: json['tax_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'status': status,
      'converted_from_lead_id': convertedFromLeadId,
      'billing_address': billingAddress,
      'tax_id': taxId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CustomerTaskModel extends CustomerTask {
  const CustomerTaskModel({
    required super.id,
    required super.title,
    super.description,
    super.priority,
    super.status,
    super.dueDate,
    super.assignee,
  });

  factory CustomerTaskModel.fromJson(Map<String, dynamic> json) {
    return CustomerTaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'backlog',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      assignee: json['assignee'] as String?,
    );
  }
}

class CustomerInvoiceModel extends CustomerInvoice {
  const CustomerInvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.amount,
    required super.status,
    required super.issueDate,
    required super.dueDate,
  });

  factory CustomerInvoiceModel.fromJson(Map<String, dynamic> json) {
    return CustomerInvoiceModel(
      id: json['id'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String? ?? 'INV-0000',
      amount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'draft',
      issueDate: json['issue_date'] != null
          ? DateTime.tryParse(json['issue_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
