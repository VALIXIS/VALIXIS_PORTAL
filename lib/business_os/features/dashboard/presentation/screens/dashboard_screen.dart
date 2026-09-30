import 'package:flutter/material.dart';
import 'executive_dashboard_screen.dart';

export 'executive_dashboard_screen.dart';

/// Legacy alias for ExecutiveDashboardScreen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExecutiveDashboardScreen();
  }
}
