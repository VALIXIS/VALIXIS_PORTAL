import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/team_provider.dart';
import '../widgets/invite_member_dialog.dart';
import '../widgets/member_card.dart';

/// Full-featured Team Directory, Workload Monitor & Governance Screen.
/// Route: /team
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openInviteDialog() async {
    final result = await InviteMemberDialog.show(context);
    if (result == true && mounted) {
      final msg =
          ref.read(teamMembersProvider).inviteSuccessMessage ??
          'Invitation sent successfully.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(teamMembersProvider.notifier).clearInviteStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamMembersProvider);
    final isAdmin = ref.watch(isCurrentUserAdminProvider);
    final isMobile = AppBreakpoints.isMobile(context);

    return AppPage(
      title: 'Team Directory & Workload',
      subtitle:
          'Organization member roles, active workload meters, and invitations.',
      trailing: isAdmin
          ? ElevatedButton.icon(
              key: const Key('invite_member_button'),
              onPressed: _openInviteDialog,
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Invite Member'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Team Metrics Strip
          _buildMetricsStrip(teamState),
          const SizedBox(height: 20),

          // 2. Search & Role Filter Toolbar
          _buildFilterToolbar(teamState),
          const SizedBox(height: 20),

          // 3. Main Directory Content
          _buildDirectoryContent(teamState, isMobile),
        ],
      ),
    );
  }

  Widget _buildMetricsStrip(TeamState state) {
    final metrics = [
      _MetricData(
        title: 'ACTIVE MEMBERS',
        value: '${state.totalCount}',
        icon: Icons.people_outline_rounded,
        color: AppColors.primary,
        subtitle:
            '${state.adminCount} Admins · ${state.employeeCount} Employees',
      ),
      _MetricData(
        title: 'ACTIVE TASKS',
        value: '${state.totalActiveTasks}',
        icon: Icons.task_alt_rounded,
        color: AppColors.secondary,
        subtitle: 'Across all active assignments',
      ),
      _MetricData(
        title: 'OVERLOADED',
        value: '${state.overloadedCount}',
        icon: Icons.warning_amber_rounded,
        color: state.overloadedCount > 0 ? AppColors.error : AppColors.success,
        subtitle: state.overloadedCount > 0
            ? 'Action recommended (>6 tasks)'
            : 'Capacity optimal across team',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: metrics
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMetricCard(m),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: metrics
              .map(
                (m) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _buildMetricCard(m),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricData m) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.title,
                style: AppTypography.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted,
                ),
              ),
              Icon(m.icon, size: 16, color: m.color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m.value,
            style: AppTypography.headline.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            m.subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(TeamState state) {
    final isMobile = AppBreakpoints.isMobile(context);

    final searchField = SizedBox(
      height: 40,
      child: TextField(
        key: const Key('team_search_field'),
        controller: _searchController,
        style: AppTypography.body.copyWith(fontSize: 13),
        onChanged: (val) {
          ref.read(teamMembersProvider.notifier).setSearchQuery(val);
        },
        decoration: InputDecoration(
          hintText: 'Search members by name, email or role...',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(teamMembersProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );

    final roleFilters = Wrap(
      spacing: 6,
      children: [
        _buildFilterChip('All', 'all', state.roleFilter),
        _buildFilterChip('Admins', 'admin', state.roleFilter),
        _buildFilterChip('Employees', 'employee', state.roleFilter),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [searchField, const SizedBox(height: 10), roleFilters],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 16),
        roleFilters,
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = currentFilter == value;
    final keyName = 'filter_$value';

    return FilterChip(
      key: Key(keyName),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(teamMembersProvider.notifier).setRoleFilter(value);
      },
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        fontSize: 12,
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.25),
      checkmarkColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildDirectoryContent(TeamState state, bool isMobile) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.error != null) {
      return GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text('Failed to load team directory', style: AppTypography.title),
            const SizedBox(height: 6),
            Text(
              state.error!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(teamMembersProvider.notifier)
                  .loadMembers(refresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final members = state.filteredMembers;

    if (members.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            const Icon(
              Icons.person_search_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text('No Members Found', style: AppTypography.title),
            const SizedBox(height: 6),
            Text(
              state.searchQuery.isNotEmpty || state.roleFilter != 'all'
                  ? 'No team members match your current search or filter criteria.'
                  : 'No members have been added to this organization yet.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Mobile (< 600): Single column
        if (width < 600) {
          return Column(
            children: members
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TeamMemberCard(member: m),
                  ),
                )
                .toList(),
          );
        }

        // Tablet (600 - 1024): 2 columns
        // Desktop (>= 1024): 3 columns (or 2 if width < 1100)
        final int crossAxisCount = width >= 1150 ? 3 : 2;

        // Split members into rows of crossAxisCount
        final List<List<TeamMember>> rows = [];
        for (var i = 0; i < members.length; i += crossAxisCount) {
          rows.add(
            members.sublist(
              i,
              (i + crossAxisCount > members.length)
                  ? members.length
                  : i + crossAxisCount,
            ),
          );
        }

        return Column(
          children: rows.map((rowMembers) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < crossAxisCount; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 7,
                          right: i == crossAxisCount - 1 ? 0 : 7,
                        ),
                        child: i < rowMembers.length
                            ? TeamMemberCard(member: rowMembers[i])
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}
