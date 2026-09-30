import 'package:flutter/material.dart';
import 'leads_kanban_screen.dart';

export 'leads_kanban_screen.dart';

/// Legacy page entrypoint wrapping [LeadsKanbanScreen] for route compatibility.
class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeadsKanbanScreen();
  }
}
