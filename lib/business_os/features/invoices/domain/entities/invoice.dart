import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import 'invoice_line_item.dart';

/// Domain entity representing a full invoice with line items and customer association.
@immutable
class Invoice {
  final String id;
  final String organizationId;
  final String customerId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final String status; // 'draft', 'sent', 'paid', 'partially_paid', 'overdue', 'cancelled'
  final String currency; // 'USD', 'INR', 'EUR', etc.
  final double subtotal;
  final double taxRate; // 0, 5, 12, 18, 28
  final double taxAmount;
  final double totalAmount;
  final String? notes;
  final String? pdfUrl;
  final String? customerName;
  final String? customerCompany;
  final List<InvoiceLineItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.organizationId,
    required this.customerId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    this.status = 'draft',
    this.currency = 'USD',
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.notes,
    this.pdfUrl,
    this.customerName,
    this.customerCompany,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDraft => status == 'draft';
  bool get isSent => status == 'sent';
  bool get isPaid => status == 'paid';
  bool get isOverdue =>
      status == 'overdue' ||
      (!isPaid && !isDraft && dueDate.isBefore(DateTime.now()));
  bool get isCancelled => status == 'cancelled';

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'paid':
        return 'Paid';
      case 'partially_paid':
        return 'Partially Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'sent':
        return AppColors.primary;
      case 'draft':
        return AppColors.textSecondary;
      case 'overdue':
        return AppColors.error;
      case 'partially_paid':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }

  String get customerDisplay {
    if (customerCompany != null && customerCompany!.trim().isNotEmpty) {
      return customerCompany!;
    }
    if (customerName != null && customerName!.trim().isNotEmpty) {
      return customerName!;
    }
    return 'Customer ($customerId)';
  }

  Invoice copyWith({
    String? id,
    String? organizationId,
    String? customerId,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    String? status,
    String? currency,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? notes,
    String? pdfUrl,
    String? customerName,
    String? customerCompany,
    List<InvoiceLineItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      customerName: customerName ?? this.customerName,
      customerCompany: customerCompany ?? this.customerCompany,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'customer_id': customerId,
      'invoice_number': invoiceNumber,
      'issue_date': '${issueDate.year}-${issueDate.month.toString().padLeft(2, '0')}-${issueDate.day.toString().padLeft(2, '0')}',
      'due_date': '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
      'status': status,
      'subtotal': subtotal,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': notes,
      'pdf_url': pdfUrl,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json, {List<InvoiceLineItem> items = const []}) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final customersJoin = json['customers'] as Map<String, dynamic>?;

    return Invoice(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      customerId: json['customer_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      issueDate: parseDate(json['issue_date']),
      dueDate: parseDate(json['due_date']),
      status: json['status'] as String? ?? 'draft',
      currency: json['currency'] as String? ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      customerName: customersJoin?['name'] as String? ?? json['customer_name'] as String?,
      customerCompany: customersJoin?['company_name'] as String? ?? json['customer_company'] as String?,
      items: items,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          customerId == other.customerId &&
          invoiceNumber == other.invoiceNumber &&
          status == other.status &&
          currency == other.currency &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      id.hashCode ^
      organizationId.hashCode ^
      customerId.hashCode ^
      invoiceNumber.hashCode ^
      status.hashCode ^
      currency.hashCode ^
      totalAmount.hashCode;
}
