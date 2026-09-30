import 'package:flutter/material.dart';
import '../pages/leads_kanban_screen.dart';

export '../pages/leads_kanban_screen.dart';

/// Backward-compatibility alias for [LeadsKanbanScreen].
class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeadsKanbanScreen();
  }
}
