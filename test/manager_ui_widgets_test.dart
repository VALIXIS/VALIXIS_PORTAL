import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/core/theme/app_theme.dart';
import 'package:valixis_portal/features/auth/presentation/unauthorized_screen.dart';
import 'package:valixis_portal/features/manager/presentation/widgets/audit_logs_table.dart';
import 'package:valixis_portal/features/manager/presentation/widgets/manager_audit_log_card.dart';
import 'package:valixis_portal/features/manager/presentation/widgets/manager_hero_header.dart';
import 'package:valixis_portal/features/manager/presentation/widgets/manager_quick_actions.dart';
import 'package:valixis_portal/features/manager/presentation/widgets/manager_task_card.dart';
import 'package:valixis_portal/shared/models/task.dart';

Widget _wrapWithTheme(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Manager UI Widgets Tests', () {
    testWidgets('ManagerHeroHeader renders executive title and manager badge', (tester) async {
      await tester.pumpWidget(_wrapWithTheme(const ManagerHeroHeader()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Manager Overview'), findsOneWidget);
      expect(find.text('MANAGER'), findsOneWidget);
    });

    testWidgets('ManagerQuickActions renders manager navigation shortcuts and NO Create Task', (tester) async {
      await tester.pumpWidget(_wrapWithTheme(const ManagerQuickActions()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Reviews & PRs'), findsOneWidget);
      expect(find.text('Audit Logs'), findsOneWidget);
      expect(find.text('Team'), findsOneWidget);

      // Verify STRICTLY NO Create Task button exists
      expect(find.text('Create Task'), findsNothing);
      expect(find.text('Create New Task'), findsNothing);
    });

    testWidgets('ManagerAuditLogCard renders actor, action, status, and IP', (tester) async {
      final log = AuditLogItem(
        id: 'log-1',
        actor: 'Nagasai (Lead)',
        action: 'PR Approval',
        category: 'Task Management',
        timestamp: DateTime(2026, 9, 1, 14, 30),
        ipAddress: '192.168.1.100',
        status: 'Success',
        details: 'PR #42 approved',
      );

      await tester.pumpWidget(_wrapWithTheme(ManagerAuditLogCard(log: log)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nagasai (Lead)'), findsOneWidget);
      expect(find.text('PR Approval'), findsOneWidget);
      expect(find.text('Task Management'), findsOneWidget);
      expect(find.text('192.168.1.100'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('ManagerTaskCard renders task title, repo, assignee, and priority', (tester) async {
      final task = Task(
        id: '204',
        title: 'Real-time Mobile Sync Integration',
        priority: TaskPriority.critical,
        status: TaskStatus.inProgress,
        deadline: DateTime.now().add(const Duration(days: 3)),
        assignedTo: 'Nagasai',
        githubRepo: 'VALIXIS_PORTAL',
        branchName: 'feat/sync',
        prUrl: 'https://github.com/valixis/portal/pull/204',
      );

      await tester.pumpWidget(_wrapWithTheme(ManagerTaskCard(
        task: task,
        onReassign: () {},
        onUnassign: () {},
      )));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Real-time Mobile Sync Integration'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('VALIXIS_PORTAL'), findsOneWidget);
      expect(find.text('feat/sync'), findsOneWidget);
      expect(find.text('Nagasai'), findsOneWidget);
      expect(find.text('PR ACTIVE'), findsOneWidget);
    });

    testWidgets('ManagerTaskCard with onEdit fires edit callback when clicked', (tester) async {
      bool editFired = false;
      final task = Task(
        id: '205',
        title: 'Backend Refactoring Task',
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: DateTime.now().add(const Duration(days: 5)),
        assignedTo: 'Official Team',
        githubRepo: 'VALIXIS_PORTAL',
      );

      await tester.pumpWidget(_wrapWithTheme(ManagerTaskCard(
        task: task,
        onReassign: () {},
        onUnassign: () {},
        onEdit: () => editFired = true,
      )));
      await tester.pump(const Duration(milliseconds: 100));

      final editBtn = find.byTooltip('Edit Task');
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pump();
      expect(editFired, isTrue);
    });

    testWidgets('UnauthorizedScreen renders restricted access message and sign out', (tester) async {
      await tester.pumpWidget(_wrapWithTheme(const UnauthorizedScreen(userEmail: 'dev@valixis.com')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Manager Access Required'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
