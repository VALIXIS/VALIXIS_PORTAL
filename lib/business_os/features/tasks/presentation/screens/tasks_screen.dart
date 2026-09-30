import 'package:flutter/material.dart';
import '../../../operations/presentation/pages/operations_page.dart';

export '../../../operations/presentation/screens/tasks_board_screen.dart';

/// Legacy export and wrapper for the unified interactive Kanban Task Board.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OperationsPage(initialTab: OperationsTab.tasks);
  }
}
