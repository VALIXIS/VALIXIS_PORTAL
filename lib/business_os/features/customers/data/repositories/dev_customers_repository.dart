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
    final now = DateTime.now();
    return [
      Customer(
        id: 'cust-aerodynamics-01',
        organizationId: 'org_dev_01',
        name: 'Dr. Aris Thorne',
        companyName: 'AeroDynamics Aerospace',
        email: 'aris.thorne@aerodynamics.com',
        phone: '+1 (555) 942-8812',
        status: 'active',
        billingAddress: '400 Flightway Blvd, Suite 800, Seattle, WA',
        taxId: 'US-91823719',
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Customer(
        id: 'cust-biosynthetix-02',
        organizationId: 'org_dev_01',
        name: 'Clara Oswald',
        companyName: 'BioSynthetix Pharma',
        email: 'c.oswald@biosynthetix.io',
        phone: '+1 (555) 328-9941',
        status: 'active',
        billingAddress: '12 Discovery Way, Cambridge, MA',
        taxId: 'US-84910284',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Customer(
        id: 'cust-omnichain-03',
        organizationId: 'org_dev_01',
        name: 'David Kim',
        companyName: 'OmniChain Retail Network',
        email: 'david.kim@omnichain.com',
        phone: '+1 (555) 871-3309',
        status: 'active',
        billingAddress: '900 Logistics Ave, Chicago, IL',
        taxId: 'US-10293847',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Customer(
        id: 'cust-krypton-04',
        organizationId: 'org_dev_01',
        name: 'Nathan Drake',
        companyName: 'Krypton Cyber Security',
        email: 'nathan@kryptonsec.com',
        phone: '+1 (555) 234-5678',
        status: 'active',
        billingAddress: '55 Sentinel Tower, Austin, TX',
        taxId: 'US-56473829',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
      Customer(
        id: 'cust-nextgen-05',
        organizationId: 'org_dev_01',
        name: 'Elena Rostova',
        companyName: 'NextGen Cloud Labs',
        email: 'elena.rostova@nextgenlabs.ai',
        phone: '+1 (555) 456-7890',
        status: 'active',
        billingAddress: '101 Innovation Parkway, San Francisco, CA',
        taxId: 'US-39281726',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  void _seedRelationships() {
    final now = DateTime.now();

    // AeroDynamics Aerospace
    _tasksByCustomerId['cust-aerodynamics-01'] = [
      CustomerTask(
        id: 'task-aero-01',
        title: 'Review flight telemetry integration schema',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 3)),
        assignee: 'Marcus Vance',
      ),
      CustomerTask(
        id: 'task-aero-02',
        title: 'Complete annual security compliance review',
        priority: 'critical',
        status: 'under_review',
        dueDate: now.add(const Duration(days: 7)),
        assignee: 'Elena Rostova',
      ),
      CustomerTask(
        id: 'task-aero-03',
        title: 'Provision dedicated VPC subnet',
        priority: 'medium',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 10)),
        assignee: 'DevOps Lead',
      ),
    ];

    _invoicesByCustomerId['cust-aerodynamics-01'] = [
      CustomerInvoice(
        id: 'inv-aero-01',
        invoiceNumber: 'INV-2026-0041',
        amount: 18500.00,
        status: 'paid',
        issueDate: now.subtract(const Duration(days: 35)),
        dueDate: now.subtract(const Duration(days: 5)),
      ),
      CustomerInvoice(
        id: 'inv-aero-02',
        invoiceNumber: 'INV-2026-0089',
        amount: 18500.00,
        status: 'sent',
        issueDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 25)),
      ),
    ];

    // BioSynthetix Pharma
    _tasksByCustomerId['cust-biosynthetix-02'] = [
      CustomerTask(
        id: 'task-bio-01',
        title: 'Clinical trial dataset HIPAA ingest verification',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 5)),
        assignee: 'Dr. Aris Thorne',
      ),
      CustomerTask(
        id: 'task-bio-02',
        title: 'Q3 Enterprise renewal consultation call',
        priority: 'medium',
        status: 'backlog',
        dueDate: now.add(const Duration(days: 14)),
        assignee: 'Clara Oswald',
      ),
    ];

    _invoicesByCustomerId['cust-biosynthetix-02'] = [
      CustomerInvoice(
        id: 'inv-bio-01',
        invoiceNumber: 'INV-2026-0022',
        amount: 9200.00,
        status: 'paid',
        issueDate: now.subtract(const Duration(days: 40)),
        dueDate: now.subtract(const Duration(days: 10)),
      ),
      CustomerInvoice(
        id: 'inv-bio-02',
        invoiceNumber: 'INV-2026-0077',
        amount: 9200.00,
        status: 'sent',
        issueDate: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 28)),
      ),
    ];

    // OmniChain Retail Network
    _tasksByCustomerId['cust-omnichain-03'] = [
      CustomerTask(
        id: 'task-omni-01',
        title: 'ERP inventory synchronization pipeline stress test',
        priority: 'critical',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 2)),
        assignee: 'David Kim',
      ),
    ];

    _invoicesByCustomerId['cust-omnichain-03'] = [
      CustomerInvoice(
        id: 'inv-omni-01',
        invoiceNumber: 'INV-2026-0015',
        amount: 24000.00,
        status: 'paid',
        issueDate: now.subtract(const Duration(days: 45)),
        dueDate: now.subtract(const Duration(days: 15)),
      ),
      CustomerInvoice(
        id: 'inv-omni-02',
        invoiceNumber: 'INV-2026-0063',
        amount: 24000.00,
        status: 'paid',
        issueDate: now.subtract(const Duration(days: 15)),
        dueDate: now.add(const Duration(days: 15)),
      ),
    ];

    // Krypton Cyber Security
    _tasksByCustomerId['cust-krypton-04'] = [
      CustomerTask(
        id: 'task-kryp-01',
        title: 'SIEM webhook endpoint verification',
        priority: 'medium',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 5)),
        assignee: 'Nathan Drake',
      ),
    ];

    _invoicesByCustomerId['cust-krypton-04'] = [
      CustomerInvoice(
        id: 'inv-kryp-01',
        invoiceNumber: 'INV-2026-0033',
        amount: 4800.00,
        status: 'paid',
        issueDate: now.subtract(const Duration(days: 20)),
        dueDate: now.add(const Duration(days: 10)),
      ),
    ];

    // NextGen Cloud Labs
    _tasksByCustomerId['cust-nextgen-05'] = [
      CustomerTask(
        id: 'task-next-01',
        title: 'AI model fine-tuning cluster onboarding',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 4)),
        assignee: 'Elena Rostova',
      ),
    ];

    _invoicesByCustomerId['cust-nextgen-05'] = [
      CustomerInvoice(
        id: 'inv-next-01',
        invoiceNumber: 'INV-2026-0091',
        amount: 32000.00,
        status: 'sent',
        issueDate: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 29)),
      ),
    ];
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
