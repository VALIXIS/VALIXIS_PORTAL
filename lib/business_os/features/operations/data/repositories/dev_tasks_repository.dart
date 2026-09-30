import 'dart:async';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/tasks_repository.dart';

/// In-memory development repository for tasks.
class DevTasksRepository implements TasksRepository {
  final List<TaskItem> _tasks;

  DevTasksRepository({List<TaskItem>? initialTasks})
      : _tasks = initialTasks ?? _defaultTasks();

  static List<TaskItem> _defaultTasks() {
    final now = DateTime.now();
    return [
      TaskItem(
        id: 'task_dev_001',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_001',
        customerId: 'cust_dev_001',
        assignedTo: 'mem_dev_002', // Jyothsna
        title: 'Automate Supabase RLS policies for Enterprise multi-tenancy',
        description: 'Implement explicit tenant check functions and prevent recursive security policies.',
        priority: 'critical',
        status: 'in_progress',
        dueDate: now.add(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(days: 4)),
        projectName: 'Core Platform Scale & RLS',
        assigneeName: 'Jyothsna',
        assigneeRole: 'Admin',
        customerName: 'Acme Cloud Technologies',
      ),
      TaskItem(
        id: 'task_dev_002',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_002',
        customerId: 'cust_dev_002',
        assignedTo: 'mem_dev_001', // Subhash
        title: 'Implement rate-limiting middleware for Gemini API calls',
        description: 'Add token bucket algorithm with exponential backoff on HTTP 429 quota exhaustion.',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
        projectName: 'AI Scoring Engine Pipeline',
        assigneeName: 'Subhash',
        assigneeRole: 'Owner',
        customerName: 'Nexus Financial',
      ),
      TaskItem(
        id: 'task_dev_003',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_003',
        customerId: 'cust_dev_003',
        assignedTo: 'mem_dev_003', // Devon Patel
        title: 'Design interactive customer 360 profile slide-over drawer',
        description: 'Build slide-over drawer with metric KPIs, historical invoices, and contact data.',
        priority: 'high',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        projectName: 'Enterprise Customer Portal',
        assigneeName: 'Devon Patel',
        assigneeRole: 'Employee',
        customerName: 'Global Logistics Ltd',
      ),
      TaskItem(
        id: 'task_dev_004',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_001',
        customerId: 'cust_dev_001',
        assignedTo: 'mem_dev_005', // Marcus Vance
        title: 'Setup end-to-end CRM integration test suite in CI/CD',
        description: 'Verify lead capture, conversion to customer, and billing generation workflows.',
        priority: 'medium',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 5)),
        projectName: 'Core Platform Scale & RLS',
        assigneeName: 'Marcus Vance',
        assigneeRole: 'Employee',
        customerName: 'Acme Cloud Technologies',
      ),
      TaskItem(
        id: 'task_dev_005',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_004',
        customerId: 'cust_dev_004',
        assignedTo: 'mem_dev_004', // Elena Rostova
        title: 'Export billing PDF invoices and transaction records',
        description: 'Ensure accurate tax itemization, currency formatting, and organization letterheads.',
        priority: 'low',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 6)),
        projectName: 'ISO 27001 Security Audit',
        assigneeName: 'Elena Rostova',
        assigneeRole: 'Employee',
        customerName: 'Apex Capital',
      ),
      TaskItem(
        id: 'task_dev_006',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_002',
        customerId: 'cust_dev_002',
        assignedTo: 'mem_dev_001', // Subhash
        title: 'Benchmark Vector embeddings latency under load',
        description: 'Evaluate p95 and p99 query latency across 50,000 lead knowledge chunks.',
        priority: 'high',
        status: 'under_review',
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        projectName: 'AI Scoring Engine Pipeline',
        assigneeName: 'Subhash',
        assigneeRole: 'Owner',
        customerName: 'Nexus Financial',
      ),
      TaskItem(
        id: 'task_dev_007',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_001',
        customerId: 'cust_dev_001',
        assignedTo: 'mem_dev_003', // Devon Patel
        title: 'Refactor ValixisRail navigation collapse animation',
        description: 'Support smooth responsive toggle and tooltip overlays across mobile and desktop.',
        priority: 'medium',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 7)),
        projectName: 'Core Platform Scale & RLS',
        assigneeName: 'Devon Patel',
        assigneeRole: 'Employee',
        customerName: 'Acme Cloud Technologies',
      ),
      TaskItem(
        id: 'task_dev_008',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_003',
        customerId: 'cust_dev_003',
        assignedTo: 'mem_dev_003', // Devon Patel
        title: 'Add tenant organization switcher to application header',
        description: 'Enable seamless switching between enterprise workspaces with session preservation.',
        priority: 'high',
        status: 'backlog',
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 1)),
        projectName: 'Enterprise Customer Portal',
        assigneeName: 'Devon Patel',
        assigneeRole: 'Employee',
        customerName: 'Global Logistics Ltd',
      ),
      TaskItem(
        id: 'task_dev_009',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_004',
        customerId: 'cust_dev_004',
        assignedTo: 'mem_dev_002', // Jyothsna
        title: 'Audit PostgreSQL indices for tasks and members tables',
        description: 'Ensure foreign keys and composite queries use b-tree indexes.',
        priority: 'critical',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 8)),
        projectName: 'ISO 27001 Security Audit',
        assigneeName: 'Jyothsna',
        assigneeRole: 'Admin',
        customerName: 'Apex Capital',
      ),
      TaskItem(
        id: 'task_dev_010',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_002',
        customerId: 'cust_dev_002',
        assignedTo: 'mem_dev_005', // Marcus Vance
        title: 'Configure webhook retry backoff with exponential jitter',
        description: 'Prevent thundering herd issues on CRM webhook receivers.',
        priority: 'medium',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
        projectName: 'AI Scoring Engine Pipeline',
        assigneeName: 'Marcus Vance',
        assigneeRole: 'Employee',
        customerName: 'Nexus Financial',
      ),
      TaskItem(
        id: 'task_dev_011',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_004',
        customerId: 'cust_dev_004',
        assignedTo: 'mem_dev_004', // Elena Rostova
        title: 'Document API security whitepaper for SOC2 type II compliance',
        description: 'Publish documentation detailing at-rest and in-transit TLS 1.3 safeguards.',
        priority: 'medium',
        status: 'done',
        dueDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 10)),
        projectName: 'ISO 27001 Security Audit',
        assigneeName: 'Elena Rostova',
        assigneeRole: 'Employee',
        customerName: 'Apex Capital',
      ),
      TaskItem(
        id: 'task_dev_012',
        organizationId: 'org_dev_001',
        projectId: 'proj_dev_003',
        customerId: 'cust_dev_003',
        assignedTo: 'mem_dev_003', // Devon Patel
        title: 'Optimize mobile breakpoint layout on 390px viewports',
        description: 'Eliminate all RenderFlex horizontal overflow risks on iOS/Android displays.',
        priority: 'low',
        status: 'backlog',
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 1)),
        projectName: 'Enterprise Customer Portal',
        assigneeName: 'Devon Patel',
        assigneeRole: 'Employee',
        customerName: 'Global Logistics Ltd',
      ),
    ];
  }

  @override
  Future<List<TaskItem>> getTasks(String organizationId, {String? projectId}) async {
    await Future.delayed(const Duration(milliseconds: 30));
    if (projectId != null && projectId.isNotEmpty && projectId != 'all') {
      return _tasks.where((t) => t.projectId == projectId).toList();
    }
    return List.unmodifiable(_tasks);
  }

  @override
  Future<TaskItem> createTask({
    required String organizationId,
    required String title,
    String? projectId,
    String? customerId,
    String? assignedTo,
    String? description,
    String priority = 'medium',
    String status = 'backlog',
    DateTime? dueDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }

    // Lookup assignee name if known
    String? assigneeName;
    if (assignedTo == 'mem_dev_001') assigneeName = 'Subhash';
    if (assignedTo == 'mem_dev_002') assigneeName = 'Jyothsna';
    if (assignedTo == 'mem_dev_003') assigneeName = 'Devon Patel';
    if (assignedTo == 'mem_dev_004') assigneeName = 'Elena Rostova';
    if (assignedTo == 'mem_dev_005') assigneeName = 'Marcus Vance';

    // Lookup project name if known
    String? projectName;
    if (projectId == 'proj_dev_001') projectName = 'Core Platform Scale & RLS';
    if (projectId == 'proj_dev_002') projectName = 'AI Scoring Engine Pipeline';
    if (projectId == 'proj_dev_003') projectName = 'Enterprise Customer Portal';
    if (projectId == 'proj_dev_004') projectName = 'ISO 27001 Security Audit';

    final newTask = TaskItem(
      id: 'task_dev_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: organizationId,
      projectId: projectId,
      customerId: customerId,
      assignedTo: assignedTo,
      title: cleanTitle,
      description: description?.trim().isNotEmpty == true ? description!.trim() : null,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      projectName: projectName ?? (projectId != null ? 'Selected Project' : null),
      assigneeName: assigneeName ?? (assignedTo != null ? 'Assigned Member' : null),
    );

    _tasks.insert(0, newTask);
    return newTask;
  }

  @override
  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 40));
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw Exception('Task not found: $taskId');
    }

    final updated = _tasks[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _tasks[index] = updated;
    return updated;
  }
}
