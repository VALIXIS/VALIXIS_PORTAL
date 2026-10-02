import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/logs/logs_screen.dart';
import '../../features/workflows/workflows_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/workflows',
    routes: [
      GoRoute(
        path: '/workflows',
        builder: (context, state) => const WorkflowsScreen(),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) => const LogsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});
