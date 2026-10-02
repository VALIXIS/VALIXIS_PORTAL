import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/pulse_theme.dart';
import 'features/telemetry/providers/telemetry_provider.dart';
import 'features/telemetry/services/telemetry_service.dart';
import 'features/auth/services/rbac_service.dart';
import 'features/auth/providers/auth_provider.dart';

/// Wraps Pulse components with the necessary MultiProvider context.
class PulseScope extends StatelessWidget {
  const PulseScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TelemetryService>(
          create: (_) => TelemetryService(),
        ),
        ChangeNotifierProvider<TelemetryProvider>(
          create: (ctx) => TelemetryProvider(
            ctx.read<TelemetryService>(),
          ),
        ),
        Provider<RbacService>(
          create: (_) => RbacService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            ctx.read<RbacService>(),
          ),
        ),
      ],
      child: Theme(
        data: PulseTheme.darkTheme,
        child: child,
      ),
    );
  }
}
