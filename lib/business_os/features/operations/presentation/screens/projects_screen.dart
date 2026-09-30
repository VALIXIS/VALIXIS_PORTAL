import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/operations_provider.dart';
import '../widgets/project_card.dart';

/// Screen displaying active workspace projects in a responsive grid.
class ProjectsScreen extends ConsumerStatefulWidget {
  final ValueChanged<Project>? onProjectSelected;
  final VoidCallback? onCreateTask;

  const ProjectsScreen({
    super.key,
    this.onProjectSelected,
    this.onCreateTask,
  });

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'all'; // 'all' | 'planning' | 'in_progress' | 'on_hold' | 'completed'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final isMobile = AppBreakpoints.isMobile(context);

    if (projectsState.isLoading && projectsState.projects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (projectsState.error != null && projectsState.projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Unable to load projects',
                style: AppTypography.h3,
              ),
              const SizedBox(height: 8),
              Text(
                projectsState.error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.read(projectsProvider.notifier).loadProjects(refresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Filter projects locally by search and status
    final filteredProjects = projectsState.projects.where((p) {
      if (_selectedStatus != 'all' && p.status != _selectedStatus) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.trim().toLowerCase();
        final matchName = p.name.toLowerCase().contains(query);
        final matchDesc = p.description?.toLowerCase().contains(query) ?? false;
        final matchCust = p.customerDisplayTag.toLowerCase().contains(query);
        if (!matchName && !matchDesc && !matchCust) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Projects Metrics Summary Cards
        _buildMetricsOverview(projectsState),
        const SizedBox(height: 20),

        // 2. Filter & Search Controls
        _buildFilterBar(isMobile),
        const SizedBox(height: 20),

        // 3. Projects Grid or Empty State
        if (filteredProjects.isEmpty)
          _buildEmptyState()
        else
          _buildProjectsGrid(filteredProjects),
      ],
    );
  }

  Widget _buildMetricsOverview(ProjectsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        final cards = [
          _buildMetricCard(
            label: 'Total Projects',
            value: state.totalProjects.toString(),
            icon: Icons.folder_special_rounded,
            color: AppColors.primary,
          ),
          _buildMetricCard(
            label: 'Active Delivery',
            value: state.activeProjectsCount.toString(),
            icon: Icons.trending_up_rounded,
            color: AppColors.accent,
          ),
          _buildMetricCard(
            label: 'Completed',
            value: state.completedProjectsCount.toString(),
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
          ),
          _buildMetricCard(
            label: 'Average Completion',
            value: '${state.averageCompletion.toStringAsFixed(0)}%',
            icon: Icons.pie_chart_outline_rounded,
            color: AppColors.warning,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: cards.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: c,
            )).toList(),
          );
        }

        return Row(
          children: cards.asMap().entries.map((entry) {
            final idx = entry.key;
            final card = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: idx < cards.length - 1 ? 12.0 : 0.0,
                ),
                child: card,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isMobile) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchInput(),
                const SizedBox(height: 12),
                _buildStatusDropdown(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildSearchInput()),
                const SizedBox(width: 16),
                _buildStatusDropdown(),
              ],
            ),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      key: const Key('projects_search_field'),
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Search projects by name, description, customer...',
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceElevated.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButton<String>(
          key: const Key('projects_status_filter_dropdown'),
          value: _selectedStatus,
          dropdownColor: AppColors.surfaceElevated,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Statuses')),
            DropdownMenuItem(value: 'planning', child: Text('Planning')),
            DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
            DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedStatus = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(List<Project> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 650) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1150) {
          crossAxisCount = 2;
        }

        // Calculate card width and dynamic aspect ratio
        const spacing = 16.0;
        final totalSpacing = spacing * (crossAxisCount - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        // ProjectCard content height is around 250px - 280px
        const itemHeight = 265.0;
        final childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          key: const Key('projects_grid_view'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio > 0.5 ? childAspectRatio : 1.2,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              key: Key('project_card_${project.id}'),
              project: project,
              onTap: () {
                _handleProjectSelect(project);
              },
              onViewTasks: () {
                _handleProjectSelect(project);
              },
            );
          },
        );
      },
    );
  }

  void _handleProjectSelect(Project project) {
    // Set project filter in Tasks provider
    ref.read(tasksProvider.notifier).setProjectFilter(project.id);
    if (widget.onProjectSelected != null) {
      widget.onProjectSelected!(project);
    }
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_off_outlined,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedStatus != 'all'
                  ? 'No projects match your search or status filter criteria.'
                  : 'Get started by creating your first operations project.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_searchController.text.isNotEmpty || _selectedStatus != 'all')
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedStatus = 'all';
                  });
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Clear Project Filters'),
              ),
          ],
        ),
      ),
    );
  }
}
