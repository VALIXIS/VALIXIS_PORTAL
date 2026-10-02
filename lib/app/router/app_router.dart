import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/auth/presentation/unauthorized_screen.dart';
import '../../features/calendar/presentation/sprint_calendar_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/manager/presentation/employee_management_screen.dart';
import '../../features/manager/presentation/manager_audit_logs_screen.dart';
import '../../features/manager/presentation/manager_dashboard_screen.dart';
import '../../features/manager/presentation/manager_tasks_screen.dart';
import '../../features/manager/presentation/review_submissions_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tasks/presentation/task_details_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../shared/layout/app_shell.dart';

// Business OS Integrated Modules
import '../../business_os/app/router/route_paths.dart';
import '../../business_os/features/customers/presentation/pages/customers_page.dart';
import '../../business_os/features/dashboard/presentation/pages/dashboard_page.dart';
import '../../business_os/features/invoices/presentation/pages/invoices_page.dart';
import '../../business_os/features/invoices/presentation/screens/invoice_builder_screen.dart';
import '../../business_os/features/leads/presentation/pages/leads_page.dart';
import '../../business_os/features/operations/presentation/pages/operations_page.dart';
import '../../business_os/features/team/presentation/pages/team_page.dart';

// Flow Integrated Modules
import '../../flow/flow_route_paths.dart';
import '../../flow/features/workflows/workflows_screen.dart';
import '../../flow/features/logs/logs_screen.dart';
import '../../flow/features/analytics/analytics_screen.dart';

// Pulse Integrated Modules
import '../../pulse/pulse_route_paths.dart';
import '../../pulse/pulse_scope.dart';
import '../../pulse/features/dashboard/screens/executive_pulse_dashboard.dart';
import '../../pulse/features/forensic/screens/forensic_explorer_screen.dart';
import '../../pulse/features/predictive/predictive_screen.dart';
import '../../pulse/features/anomalies/anomaly_inspector_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String unauthorized = '/unauthorized';

  // Primary Manager Routes
  static const String managerDashboard = '/manager';
  static const String managerTasks = '/manager/all-tasks';
  static const String managerReviews = '/manager/reviews';
  static const String managerAuditLogs = '/manager/audit-logs';
  static const String managerEmployees = '/manager/employees';
  static const String taskDetails = '/tasks/:id';
  static const String profile = '/profile';
  static const String calendar = '/calendar';

  // Business OS Routes (Manager only)
  static const String businessOs = RoutePaths.root;
  static const String businessOsDashboard = RoutePaths.dashboard;
  static const String businessOsLeads = RoutePaths.leads;
  static const String businessOsCustomers = RoutePaths.customers;
  static const String businessOsOperations = RoutePaths.operations;
  static const String businessOsProjects = RoutePaths.projects;
  static const String businessOsTasks = RoutePaths.tasks;
  static const String businessOsInvoices = RoutePaths.invoices;
  static const String businessOsInvoiceBuilder = RoutePaths.invoiceBuilder;
  static const String businessOsTeam = RoutePaths.team;

  // Flow Routes (Manager only)
  static const String flow = FlowRoutePaths.root;
  static const String flowWorkflows = FlowRoutePaths.workflows;
  static const String flowLogs = FlowRoutePaths.logs;
  static const String flowAnalytics = FlowRoutePaths.analytics;

  // Pulse Routes (Manager only)
  static const String pulse = PulseRoutePaths.root;
  static const String pulseDashboard = PulseRoutePaths.dashboard;
  static const String pulseForensic = PulseRoutePaths.forensic;
  static const String pulsePredictive = PulseRoutePaths.predictive;
  static const String pulseAnomalies = PulseRoutePaths.anomalies;

  // Compatibility aliases
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String managerCreateTask = '/manager/all-tasks';
  static const String managerAssignments = '/manager/all-tasks';
  static const String managerWhatsApp = '/manager';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return _buildRouter(ref, notifier);
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) => notifyListeners());
    _ref.listen(roleProvider, (previous, next) => notifyListeners());
  }

  final Ref _ref;
}

GoRouter _buildRouter(Ref ref, Listenable refreshListenable) => GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: refreshListenable,
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);
        final isAuthenticated = authState.valueOrNull != null;
        final isSplash = state.matchedLocation == AppRoutes.splash;
        final isLogin = state.matchedLocation == AppRoutes.login;
        final isUnauthorized = state.matchedLocation == AppRoutes.unauthorized;

        if (isSplash) return null;

        if (!isAuthenticated && !isLogin) {
          return AppRoutes.login;
        }

        if (isAuthenticated) {
          final roleAsync = ref.read(roleProvider);
          if (roleAsync.isLoading) return null;

          final userRole = roleAsync.valueOrNull ?? UserRole.employee;
          final isManager = userRole.isManager;
          final matched = state.matchedLocation;

          if (isManager) {
            if (isLogin || isUnauthorized || isSplash) {
              return AppRoutes.managerDashboard;
            }
            return null;
          }

          // Employee role - STRICT GATEKEEPING: Employees cannot access or know of manager/executive suites
          if (matched.startsWith('/manager') ||
              matched.startsWith('/business-os') ||
              matched.startsWith('/flow') ||
              matched.startsWith('/pulse')) {
            return AppRoutes.unauthorized;
          }

          if (isLogin || isUnauthorized || isSplash) {
            return AppRoutes.dashboard;
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          pageBuilder: (context, state) => _fadePage(
            key: state.pageKey,
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => _fadePage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.unauthorized,
          name: 'unauthorized',
          pageBuilder: (context, state) => _fadePage(
            key: state.pageKey,
            child: const UnauthorizedScreen(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.managerDashboard,
              name: 'managerDashboard',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const ManagerDashboardScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.managerTasks,
              name: 'managerTasks',
              pageBuilder: (context, state) {
                final status = state.uri.queryParameters['status'];
                return _fadePage(
                  key: state.pageKey,
                  child: ManagerTasksScreen(initialStatusFilter: status),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.managerReviews,
              name: 'managerReviews',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const ReviewSubmissionsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.managerAuditLogs,
              name: 'managerAuditLogs',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const ManagerAuditLogsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.managerEmployees,
              name: 'managerEmployees',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const EmployeeManagementScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const DashboardScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.tasks,
              name: 'tasks',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const TasksScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.taskDetails,
              name: 'taskDetails',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return _fadePage(
                  key: state.pageKey,
                  child: TaskDetailsScreen(taskId: id),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.calendar,
              name: 'calendar',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const SprintCalendarScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
            ),
            // ── Business OS Integrated Routes (Manager Only) ───────────────
            GoRoute(
              path: AppRoutes.businessOs,
              redirect: (_, _) => AppRoutes.businessOsDashboard,
            ),
            GoRoute(
              path: AppRoutes.businessOsDashboard,
              name: 'businessOsDashboard',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const DashboardPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsLeads,
              name: 'businessOsLeads',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const LeadsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsCustomers,
              name: 'businessOsCustomers',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const CustomersPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsOperations,
              name: 'businessOsOperations',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const OperationsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsProjects,
              name: 'businessOsProjects',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const OperationsPage(initialTab: OperationsTab.projects),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsTasks,
              name: 'businessOsTasks',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const OperationsPage(initialTab: OperationsTab.tasks),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsInvoices,
              name: 'businessOsInvoices',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const InvoicesPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsInvoiceBuilder,
              name: 'businessOsInvoiceBuilder',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: InvoiceBuilderScreen(
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.businessOsInvoices);
                    }
                  },
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.businessOsTeam,
              name: 'businessOsTeam',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const TeamPage(),
              ),
            ),

            // ── Flow Routes (Manager only) ───────────────────────────
            GoRoute(
              path: AppRoutes.flow,
              name: 'flowRoot',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const WorkflowsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.flowWorkflows,
              name: 'flowWorkflows',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const WorkflowsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.flowLogs,
              name: 'flowLogs',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const LogsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.flowAnalytics,
              name: 'flowAnalytics',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const AnalyticsScreen(),
              ),
            ),

            // ── Pulse Routes (Manager only) ──────────────────────────
            GoRoute(
              path: AppRoutes.pulse,
              name: 'pulseRoot',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const PulseScope(child: ExecutivePulseDashboard()),
              ),
            ),
            GoRoute(
              path: AppRoutes.pulseDashboard,
              name: 'pulseDashboard',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const PulseScope(child: ExecutivePulseDashboard()),
              ),
            ),
            GoRoute(
              path: AppRoutes.pulseForensic,
              name: 'pulseForensic',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const PulseScope(child: ForensicExplorerScreen()),
              ),
            ),
            GoRoute(
              path: AppRoutes.pulsePredictive,
              name: 'pulsePredictive',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const PulseScope(child: PredictiveScreen()),
              ),
            ),
            GoRoute(
              path: AppRoutes.pulseAnomalies,
              name: 'pulseAnomalies',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const PulseScope(child: AnomalyInspectorScreen()),
              ),
            ),
          ],
        ),
      ],
    );

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.03, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
