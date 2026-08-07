import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/manager/presentation/assign_task_screen.dart';
import '../../features/manager/presentation/create_task_screen.dart';
import '../../features/manager/presentation/employee_management_screen.dart';
import '../../features/manager/presentation/manager_audit_logs_screen.dart';
import '../../features/manager/presentation/manager_dashboard_screen.dart';
import '../../features/manager/presentation/review_submissions_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tasks/presentation/task_details_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../shared/layout/app_shell.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String taskDetails = '/tasks/:id';
  static const String profile = '/profile';

  // Manager Routes
  static const String managerDashboard = '/manager';
  static const String managerCreateTask = '/manager/tasks/create';
  static const String managerAssignments = '/manager/assignments';
  static const String managerReviews = '/manager/reviews';
  static const String managerEmployees = '/manager/employees';
  static const String managerAuditLogs = '/manager/audit-logs';
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

        if (isSplash) return null;

        if (!isAuthenticated && !isLogin) {
          debugPrint('[4. GoRouter redirect] authState: unauthenticated, destination: /login');
          return AppRoutes.login;
        }

        if (isAuthenticated) {
          final roleAsync = ref.read(roleProvider);
          debugPrint('[4. GoRouter redirect] authState: authenticated, roleProvider state: $roleAsync, location: ${state.matchedLocation}');

          if (roleAsync.isLoading) return null;

          final userRole = roleAsync.valueOrNull ?? UserRole.employee;
          final isManager = userRole.isManager;
          final isManagerRoute = state.matchedLocation.startsWith('/manager');

          if (isLogin) {
            final dest = isManager ? AppRoutes.managerDashboard : AppRoutes.dashboard;
            debugPrint('[4. GoRouter redirect] login redirect -> destination: $dest');
            return dest;
          }

          if (isManagerRoute && !isManager) {
            debugPrint('[4. GoRouter redirect] unauthorized manager route -> redirecting to /dashboard');
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
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
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
              path: AppRoutes.profile,
              name: 'profile',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.managerDashboard,
              name: 'managerDashboard',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const ManagerDashboardScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.managerCreateTask,
              name: 'managerCreateTask',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const CreateTaskScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.managerAssignments,
              name: 'managerAssignments',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const AssignTaskScreen(),
              ),
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
              path: AppRoutes.managerEmployees,
              name: 'managerEmployees',
              pageBuilder: (context, state) => _fadePage(
                key: state.pageKey,
                child: const EmployeeManagementScreen(),
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
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.04, 0.0),
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
