import 'package:flutter/material.dart';
import '../screens/executive_dashboard_screen.dart';

export '../screens/executive_dashboard_screen.dart';

/// Top-level Dashboard Page integrated into AppShell router.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExecutiveDashboardScreen();
  }
}
