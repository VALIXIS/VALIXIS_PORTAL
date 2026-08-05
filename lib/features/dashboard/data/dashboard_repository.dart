import 'package:supabase_flutter/supabase_flutter.dart';
import '../../employee/data/employee_repository.dart';
import '../../tasks/data/tasks_repository.dart';
import '../../../shared/models/employee.dart';
import '../../../shared/models/task.dart';

class DashboardData {
  const DashboardData({
    required this.employee,
    required this.pendingCount,
    required this.completedCount,
    required this.recentTasks,
  });

  final Employee employee;
  final int pendingCount;
  final int completedCount;
  final List<Task> recentTasks;
}

/// Repository synthesizing metrics and data for the Dashboard.
class DashboardRepository {
  DashboardRepository({
    required EmployeeRepository employeeRepository,
    required TasksRepository tasksRepository,
    this.client,
  })  : _employeeRepo = employeeRepository,
        _tasksRepo = tasksRepository;

  final EmployeeRepository _employeeRepo;
  final TasksRepository _tasksRepo;
  final SupabaseClient? client;

  /// Aggregates profile info, task counts, and recent tasks for [userId].
  Future<DashboardData> getDashboardData(String userId) async {
    final results = await Future.wait([
      _employeeRepo.getEmployeeProfile(userId),
      _tasksRepo.getAssignedTasks(userId),
    ]);

    final employee = results[0] as Employee;
    final tasks = results[1] as List<Task>;

    final pendingCount = tasks.where((t) => t.status.isPending).length;
    final completedCount = tasks.where((t) => t.status.isCompleted).length;

    return DashboardData(
      employee: employee,
      pendingCount: pendingCount,
      completedCount: completedCount,
      recentTasks: tasks.take(5).toList(),
    );
  }

  /// Invokes `manager-dashboard` Edge Function for administrative metrics.
  Future<Map<String, dynamic>?> getManagerDashboardData() async {
    final supabase = client;
    if (supabase == null) return null;

    final response = await supabase.functions.invoke('manager-dashboard');
    if (response.status < 400 && response.data != null) {
      return response.data as Map<String, dynamic>;
    }
    return null;
  }
}
