import 'package:flutter/foundation.dart';
import 'customer.dart';

/// Represents a linked task in the Customer 360 profile.
@immutable
class CustomerTask {
  final String id;
  final String title;
  final String? description;
  final String priority; // 'low', 'medium', 'high', 'critical'
  final String status; // 'backlog', 'in_progress', 'under_review', 'done'
  final DateTime? dueDate;
  final String? assignee;

  const CustomerTask({
    required this.id,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.status = 'backlog',
    this.dueDate,
    this.assignee,
  });

  bool get isDone => status == 'done';

  CustomerTask copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    String? assignee,
  }) {
    return CustomerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignee: assignee ?? this.assignee,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          priority == other.priority &&
          status == other.status &&
          dueDate == other.dueDate &&
          assignee == other.assignee;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      priority.hashCode ^
      status.hashCode ^
      dueDate.hashCode ^
      assignee.hashCode;
}

/// Represents a linked invoice in the Customer 360 profile.
@immutable
class CustomerInvoice {
  final String id;
  final String invoiceNumber;
  final double amount;
  final String
  status; // 'draft', 'sent', 'paid', 'partially_paid', 'overdue', 'cancelled'
  final DateTime issueDate;
  final DateTime dueDate;

  const CustomerInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.status,
    required this.issueDate,
    required this.dueDate,
  });

  bool get isPaid => status == 'paid';
  bool get isOverdue =>
      status == 'overdue' ||
      (status != 'paid' && dueDate.isBefore(DateTime.now()));

  CustomerInvoice copyWith({
    String? id,
    String? invoiceNumber,
    double? amount,
    String? status,
    DateTime? issueDate,
    DateTime? dueDate,
  }) {
    return CustomerInvoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerInvoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceNumber == other.invoiceNumber &&
          amount == other.amount &&
          status == other.status &&
          issueDate == other.issueDate &&
          dueDate == other.dueDate;

  @override
  int get hashCode =>
      id.hashCode ^
      invoiceNumber.hashCode ^
      amount.hashCode ^
      status.hashCode ^
      issueDate.hashCode ^
      dueDate.hashCode;
}

/// Aggregated 360 view of a customer including financial and operational relationships.
@immutable
class Customer360 {
  final Customer customer;
  final double totalRevenue;
  final List<CustomerTask> tasks;
  final List<CustomerInvoice> invoices;

  const Customer360({
    required this.customer,
    required this.totalRevenue,
    required this.tasks,
    required this.invoices,
  });

  int get openTasksCount => tasks.where((t) => !t.isDone).length;
  int get totalInvoicesCount => invoices.length;
  int get paidInvoicesCount => invoices.where((i) => i.isPaid).length;

  Customer360 copyWith({
    Customer? customer,
    double? totalRevenue,
    List<CustomerTask>? tasks,
    List<CustomerInvoice>? invoices,
  }) {
    return Customer360(
      customer: customer ?? this.customer,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      tasks: tasks ?? this.tasks,
      invoices: invoices ?? this.invoices,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer360 &&
          runtimeType == other.runtimeType &&
          customer == other.customer &&
          totalRevenue == other.totalRevenue &&
          listEquals(tasks, other.tasks) &&
          listEquals(invoices, other.invoices);

  @override
  int get hashCode =>
      customer.hashCode ^
      totalRevenue.hashCode ^
      tasks.hashCode ^
      invoices.hashCode;
}
