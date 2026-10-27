import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/role_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/providers/role_provider.dart';
import 'router/app_router.dart';
import 'providers.dart';

/// Root application widget for VALIXIS Portal & Manager.
///
/// Dynamically updates the application & browser tab title:
/// - 'VALIXIS Manager' for managers (Subhash, Jyothsna).
/// - 'VALIXIS Portal' for employees (Adithya, Hasitha, Krishna, Vignesh, Vaseem, etc.).
class ValixisApp extends ConsumerWidget {
  const ValixisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    final role = ref.watch(roleProvider).valueOrNull ?? UserRole.employee;
    final userAsync = ref.watch(authNotifierProvider);
    final userEmail = userAsync.valueOrNull?.email?.toLowerCase() ?? '';
    final isKnownManager = role.isManager ||
        userEmail == 'official.valixis@gmail.com' ||
        userEmail.contains('jyothsna') ||
        userEmail.contains('manager');

    final appTitle = isKnownManager ? 'VALIXIS Manager' : 'VALIXIS Portal';

    return MaterialApp.router(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
