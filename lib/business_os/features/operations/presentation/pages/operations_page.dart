import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_page.dart';
import '../providers/operations_provider.dart';
import '../screens/projects_screen.dart';
import '../screens/tasks_board_screen.dart';
import '../widgets/create_task_modal.dart';

enum OperationsTab { projects, tasks }

/// Primary Operations Workspace page hosting Project Workspaces and Kanban Task Board.
class OperationsPage extends ConsumerStatefulWidget {
  final OperationsTab initialTab;

  const OperationsPage({
    super.key,
    this.initialTab = OperationsTab.projects,
  });

  @override
  ConsumerState<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends ConsumerState<OperationsPage> {
  late OperationsTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _openCreateTaskModal() async {
    final activeProjectId = ref.read(tasksProvider).filterProjectId;
    final projId = activeProjectId != 'all' && activeProjectId != null ? activeProjectId : null;
    await CreateTaskModal.show(context, initialProjectId: projId);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Operations & Project Workspaces',
      subtitle: 'Active client delivery pipelines, project health, and Kanban task execution.',
      trailing: ElevatedButton.icon(
        key: const Key('create_task_quick_action'),
        onPressed: _openCreateTaskModal,
        icon: const Icon(Icons.add_task_rounded, size: 16),
        label: const Text('Create Task'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Workspace Mode Selector (Projects Grid vs Kanban Tasks Board)
          _buildWorkspaceToggle(),
          const SizedBox(height: 20),

          // Active Workspace View
          if (_currentTab == OperationsTab.projects)
            ProjectsScreen(
              key: const Key('operations_projects_view'),
              onProjectSelected: (project) {
                setState(() {
                  _currentTab = OperationsTab.tasks;
                });
              },
              onCreateTask: _openCreateTaskModal,
            )
          else
            TasksBoardScreen(
              key: const Key('operations_tasks_view'),
              onCreateTask: _openCreateTaskModal,
            ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildToggleTab(
              tabKey: const Key('tab_projects'),
              label: 'Projects Grid',
              icon: Icons.folder_special_rounded,
              isSelected: _currentTab == OperationsTab.projects,
              onTap: () {
                setState(() {
                  _currentTab = OperationsTab.projects;
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildToggleTab(
              tabKey: const Key('tab_tasks'),
              label: 'Kanban Task Board',
              icon: Icons.view_kanban_rounded,
              isSelected: _currentTab == OperationsTab.tasks,
              onTap: () {
                setState(() {
                  _currentTab = OperationsTab.tasks;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required Key tabKey,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: tabKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
