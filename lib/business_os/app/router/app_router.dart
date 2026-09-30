import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_loading_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_wizard.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/invoices/presentation/pages/invoices_page.dart';
import '../../features/invoices/presentation/screens/invoice_builder_screen.dart';
import '../../features/leads/presentation/pages/leads_page.dart';
import '../../features/operations/presentation/pages/operations_page.dart';
import '../../features/team/presentation/pages/team_page.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_paths.dart';

/// Lightweight fade transition page helper for performant 60 FPS navigation.
CustomTransitionPage<void> _buildFadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Declarative GoRouter provider reacting directly to Riverpod AuthStateNotifier.
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
  final authNotifier = ref.watch(authNotifierProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.dashboard,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authNotifier.state;
      final location = state.matchedLocation;

      final isAtLogin = location == RoutePaths.login;
      final isAtSignup = location == RoutePaths.signup;
      final isAtLoading = location == RoutePaths.authLoading;
      final isAtOnboarding = location == RoutePaths.onboarding;
      final isAtRoot = location == RoutePaths.root;

      // 1. Session Restoration / Async Loading State
      if (authState.isLoading) {
        return isAtLoading ? null : RoutePaths.authLoading;
      }

      // 2. Unauthenticated State
      if (authState is Unauthenticated || authState is AuthError) {
        if (isAtLogin || isAtSignup) {
          return null;
        }
        return RoutePaths.login;
      }

      // 3. Authenticated State
      if (authState is Authenticated) {
        final needsOnboarding = authState.needsOnboarding;

        if (needsOnboarding) {
          // Force onboarding until organization is created
          return isAtOnboarding ? null : RoutePaths.onboarding;
        } else {
          // Organization is active; prevent access to auth & onboarding flows
          if (isAtLogin ||
              isAtSignup ||
              isAtLoading ||
              isAtOnboarding ||
              isAtRoot) {
            return RoutePaths.dashboard;
          }
          return null;
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.root, redirect: (_, __) => RoutePaths.dashboard),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.signup,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          key: state.pageKey,
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authLoading,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          key: state.pageKey,
          child: const AuthLoadingPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          key: state.pageKey,
          child: const OnboardingWizard(),
        ),
      ),

      // Authenticated Business Module Shell
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: RoutePaths.leads,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LeadsPage()),
          ),
          GoRoute(
            path: RoutePaths.customers,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomersPage()),
          ),
          GoRoute(
            path: RoutePaths.operations,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OperationsPage()),
          ),
          GoRoute(
            path: RoutePaths.projects,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OperationsPage(initialTab: OperationsTab.projects),
            ),
          ),
          GoRoute(
            path: RoutePaths.tasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OperationsPage(initialTab: OperationsTab.tasks),
            ),
          ),
          GoRoute(
            path: RoutePaths.invoices,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InvoicesPage()),
          ),
          GoRoute(
            path: RoutePaths.invoiceBuilder,
            pageBuilder: (context, state) => NoTransitionPage(
              child: InvoiceBuilderScreen(
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.invoices);
                  }
                },
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.team,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TeamPage()),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() => router.dispose());
  return router;
});
