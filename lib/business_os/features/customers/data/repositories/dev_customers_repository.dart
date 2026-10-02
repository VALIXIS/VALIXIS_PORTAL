import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_360.dart';
import '../../domain/repositories/customers_repository.dart';

/// In-memory development repository for Customer operations.
/// Seeded with realistic B2B enterprise customers, tasks, and invoices.
class DevCustomersRepository implements CustomersRepository {
  bool simulateFailure = false;
  bool simulateTasksFailure = false;
  bool simulateInvoicesFailure = false;

  final Duration delay;
  final List<Customer> _customers;
  final Map<String, List<CustomerTask>> _tasksByCustomerId = {};
  final Map<String, List<CustomerInvoice>> _invoicesByCustomerId = {};

  DevCustomersRepository({
    List<Customer>? initialCustomers,
    this.delay = Duration.zero,
  }) : _customers = initialCustomers ?? _createInitialDevCustomers() {
    _seedRelationships();
  }

  static List<Customer> _createInitialDevCustomers() {
    return const [];
  }

  void _seedRelationships() {
    // Clean empty state - relationships populated as real records are added.
  }

  @override
  Future<List<Customer>> getCustomers({String? searchQuery}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (simulateFailure) {
      throw Exception('Dev simulated customer network error');
    }

    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return List.unmodifiable(_customers);
    }

    final query = searchQuery.toLowerCase().trim();
    return _customers.where((c) {
      return c.companyName.toLowerCase().contains(query) ||
          c.name.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          (c.phone != null && c.phone!.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Future<Customer360> getCustomer360(String customerId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (simulateFailure) {
      throw Exception('Dev simulated Customer 360 error');
    }

    final customer = _customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => throw Exception('Customer not found with ID $customerId'),
    );

    if (simulateTasksFailure) {
      throw Exception('Dev simulated tasks loading error');
    }
    if (simulateInvoicesFailure) {
      throw Exception('Dev simulated invoices loading error');
    }

    final tasks = _tasksByCustomerId[customerId] ?? [];
    final invoices = _invoicesByCustomerId[customerId] ?? [];

    final totalRevenue = invoices.fold<double>(
      0.0,
      (sum, inv) => sum + inv.amount,
    );

    return Customer360(
      customer: customer,
      totalRevenue: totalRevenue,
      tasks: tasks,
      invoices: invoices,
    );
  }

  @override
  Future<Customer> createCustomer({
    required String name,
    required String companyName,
    required String email,
    String? phone,
    String? billingAddress,
    String? taxId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (simulateFailure) {
      throw Exception('Dev simulated customer creation error');
    }

    final now = DateTime.now();
    final newCustomer = Customer(
      id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
      organizationId: 'org_dev_01',
      name: name.trim(),
      companyName: companyName.trim(),
      email: email.trim(),
      phone: phone?.trim(),
      status: 'active',
      billingAddress: billingAddress?.trim(),
      taxId: taxId?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    _customers.insert(0, newCustomer);
    _tasksByCustomerId[newCustomer.id] = [];
    _invoicesByCustomerId[newCustomer.id] = [];
    return newCustomer;
  }

  @override
  Future<bool> isLeadConverted(String leadId) async {
    return _customers.any((c) => c.convertedFromLeadId == leadId);
  }

  @override
  Future<Customer> convertLeadToCustomer(String leadId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (simulateFailure) {
      throw Exception('Dev simulated lead conversion error');
    }

    // Check duplicate conversion
    if (_customers.any((c) => c.convertedFromLeadId == leadId)) {
      throw Exception(
        'Lead $leadId has already been converted to a customer (23505)',
      );
    }

    final now = DateTime.now();
    final convertedCustomer = Customer(
      id: 'cust-conv-${DateTime.now().millisecondsSinceEpoch}',
      organizationId: 'org_dev_01',
      name: 'Converted Lead Contact',
      companyName: 'Converted Enterprise Client',
      email: 'lead-$leadId@converted.com',
      status: 'active',
      convertedFromLeadId: leadId,
      createdAt: now,
      updatedAt: now,
    );

    _customers.insert(0, convertedCustomer);
    _tasksByCustomerId[convertedCustomer.id] = [
      CustomerTask(
        id: 'task-conv-${now.millisecondsSinceEpoch}',
        title: 'Initial onboarding kickoff call for converted lead',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 2)),
        assignee: 'Account Executive',
      ),
    ];
    _invoicesByCustomerId[convertedCustomer.id] = [];
    return convertedCustomer;
  }

  /// Helper to convert with explicit lead attributes (for one-click conversion with lead data)
  Future<Customer> convertLeadWithDetails({
    required String leadId,
    required String name,
    required String companyName,
    required String email,
    String? phone,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (simulateFailure) {
      throw Exception('Dev simulated lead conversion error');
    }

    if (_customers.any((c) => c.convertedFromLeadId == leadId)) {
      throw Exception(
        'Lead $leadId has already been converted to a customer (23505)',
      );
    }

    final now = DateTime.now();
    final convertedCustomer = Customer(
      id: 'cust-conv-${DateTime.now().millisecondsSinceEpoch}',
      organizationId: 'org_dev_01',
      name: name.trim().isNotEmpty ? name.trim() : 'Primary Contact',
      companyName: companyName.trim().isNotEmpty
          ? companyName.trim()
          : 'Acquired Client Account',
      email: email.trim().isNotEmpty ? email.trim() : 'contact@customer.com',
      phone: phone?.trim(),
      status: 'active',
      convertedFromLeadId: leadId,
      createdAt: now,
      updatedAt: now,
    );

    _customers.insert(0, convertedCustomer);
    _tasksByCustomerId[convertedCustomer.id] = [
      CustomerTask(
        id: 'task-conv-${now.millisecondsSinceEpoch}',
        title: 'Initial onboarding kickoff call',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 2)),
        assignee: 'Account Executive',
      ),
    ];
    _invoicesByCustomerId[convertedCustomer.id] = [];
    return convertedCustomer;
  }
}
