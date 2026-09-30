import 'package:flutter/foundation.dart';

/// Domain entity representing a single line item within an invoice.
@immutable
class InvoiceLineItem {
  final String id;
  final String? invoiceId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double amount; // quantity * unit_price

  const InvoiceLineItem({
    required this.id,
    this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  InvoiceLineItem copyWith({
    String? id,
    String? invoiceId,
    String? description,
    double? quantity,
    double? unitPrice,
    double? amount,
  }) {
    return InvoiceLineItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson({String? parentInvoiceId}) {
    return {
      'id': id,
      if (invoiceId != null || parentInvoiceId != null)
        'invoice_id': invoiceId ?? parentInvoiceId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'amount': amount,
    };
  }

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String?,
      description: json['description'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceLineItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceId == other.invoiceId &&
          description == other.description &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice &&
          amount == other.amount;

  @override
  int get hashCode =>
      id.hashCode ^
      invoiceId.hashCode ^
      description.hashCode ^
      quantity.hashCode ^
      unitPrice.hashCode ^
      amount.hashCode;
}
