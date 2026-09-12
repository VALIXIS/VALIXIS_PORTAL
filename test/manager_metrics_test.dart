import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/features/manager/data/manager_repository.dart';
import 'package:valixis_portal/shared/models/task.dart';

void main() {
  group('ManagerDashboardMetrics', () {
    test('correctly parses raw metrics JSON and calculates pending reviews', () {
      final json = {
        'metrics': {
          'total_employees': 5,
          'total_tasks': 12,
          'assigned_tasks': 3,
          'in_progress_tasks': 4,
          'approved_tasks': 4,
          'rejected_tasks': 1,
        },
        'employees': [
          {'id': 'emp-1', 'auth_id': 'auth-1', 'name': 'Nagasai', 'email': 'nagasai@valixis.com', 'role': 'manager'},
          {'id': 'emp-2', 'auth_id': 'auth-2', 'name': 'Developer One', 'email': 'dev1@valixis.com', 'role': 'employee'},
        ],
        'tasks': [
          {
            'id': '101',
            'title': 'Implement Supabase Realtime',
            'priority': 'Critical',
            'status': 'in_progress',
            'deadline': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          },
          {
            'id': '102',
            'title': 'Build Mobile Manager Navigation',
            'priority': 'High',
            'status': 'submitted',
            'deadline': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          },
        ],
        'assignments': [
          {'id': 'asg-1', 'task_id': '101', 'employee_id': 'emp-2', 'status': 'in_progress'},
          {'id': 'asg-2', 'task_id': '102', 'employee_id': 'emp-2', 'status': 'submitted'},
        ],
        'recent_submissions': [
          {
            'id': 'sub-1',
            'task_id': '102',
            'assignment_id': 'asg-2',
            'employee_id': 'emp-2',
            'pr_url': 'https://github.com/valixis/portal/pull/42',
            'review_status': 'pending',
            'submitted_at': '2026-09-01T12:00:00Z',
          }
        ],
      };

      final metrics = ManagerDashboardMetrics.fromJson(json);

      expect(metrics.totalEmployees, equals(2));
      expect(metrics.totalTasks, equals(2));
      expect(metrics.submittedCount, equals(1)); // 1 pending submission
      expect(metrics.recentTasks.length, equals(2));
      expect(metrics.recentSubmissions.length, equals(1));

      final task102 = metrics.recentTasks.firstWhere((t) => t.id == '102');
      expect(task102.assignedTo, contains('Developer One'));
      expect(task102.status, equals(TaskStatus.submitted));
      expect(task102.prUrl, equals('https://github.com/valixis/portal/pull/42'));
    });
  });
}
