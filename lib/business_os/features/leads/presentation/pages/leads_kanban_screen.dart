import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/leads_provider.dart';
import '../widgets/lead_column.dart';
import '../widgets/lead_form_dialog.dart';
import '../widgets/lead_metrics.dart';

/// Primary Leads CRM Pipeline & Interactive Kanban Screen for VALIXIS BUSINESS OS.
class LeadsKanbanScreen extends ConsumerStatefulWidget {
  const LeadsKanbanScreen({super.key});

  @override
  ConsumerState<LeadsKanbanScreen> createState() => _LeadsKanbanScreenState();
}

class _LeadsKanbanScreenState extends ConsumerState<LeadsKanbanScreen> {
  final TextEditingController _searchController = TextEditingController();
  LeadStage _activeMobileStage = LeadStage.newLead;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddLeadDialog([LeadStage? stage]) {
    LeadFormDialog.show(
      context,
      existingLead: stage != null
          ? Lead(
              id: '',
              organizationId: '',
              name: '',
              companyName: '',
              stage: stage,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadsState = ref.watch(leadsNotifierProvider);
    final isMobile = AppBreakpoints.isMobile(context);
    final selectedStageFilter = ref.watch(leadStageFilterProvider);

    return AppPage(
      title: 'Leads',
      subtitle: 'Manage your sales pipeline',
      scrollable: false, // Kanban board manages its own vertical column scrolls
      trailing: ElevatedButton.icon(
        onPressed: () => _openAddLeadDialog(),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Lead'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Success / Error / Rollback Notification Banner
          if (leadsState.errorMessage != null ||
              leadsState.successMessage != null)
            _buildNotificationBanner(leadsState),

          // 2. Responsive Header Metrics Bar
          const LeadMetricsBar(),
          const SizedBox(height: 16),

          // 3. Search and Stage Filter Toolbar
          _buildToolbar(selectedStageFilter),
          const SizedBox(height: 16),

          // 4. Main Kanban Area / Loading / Error / Empty
          Expanded(child: _buildMainContent(leadsState, isMobile)),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(LeadsState state) {
    final isError = state.errorMessage != null;
    final message = isError ? state.errorMessage! : state.successMessage!;
    final color = isError ? AppColors.error : AppColors.success;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isError
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16),
              color: color,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: () =>
                  ref.read(leadsNotifierProvider.notifier).clearMessages(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(LeadStage? selectedStageFilter) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search leads by name, company, email...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(leadSearchQueryProvider.notifier).state =
                                '';
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (val) {
                  ref.read(leadSearchQueryProvider.notifier).state = val;
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Stage Filter Dropdown
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<LeadStage?>(
                value: selectedStageFilter,
                dropdownColor: AppColors.surfaceElevated,
                icon: const Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                items: [
                  const DropdownMenuItem<LeadStage?>(
                    value: null,
                    child: Text('All Stages'),
                  ),
                  ...LeadStage.values.map((stage) {
                    return DropdownMenuItem<LeadStage?>(
                      value: stage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(stage.icon, size: 14, color: stage.color),
                          const SizedBox(width: 6),
                          Text(stage.label),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (newStage) {
                  ref.read(leadStageFilterProvider.notifier).state = newStage;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(LeadsState state, bool isMobile) {
    if (state.isLoading && state.leads.isEmpty) {
      return _buildSkeletonLoading(isMobile);
    }

    if (state.errorMessage != null && state.leads.isEmpty) {
      return _buildErrorState();
    }

    if (state.leads.isEmpty) {
      return _buildEmptyState();
    }

    return isMobile ? _buildMobileKanban() : _buildDesktopKanban();
  }

  Widget _buildSkeletonLoading(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading sales pipeline...',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text('Unable to load leads', style: AppTypography.title),
            const SizedBox(height: 8),
            Text(
              'A connection or server error occurred while retrieving pipeline records.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(leadsNotifierProvider.notifier).fetchLeads(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('No leads yet', style: AppTypography.title),
            const SizedBox(height: 8),
            Text(
              'Start building your sales pipeline by adding your first lead.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openAddLeadDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Lead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopKanban() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic column width: 5 columns distributed across width, min 260px each
        final availableWidth = constraints.maxWidth;
        final minTotalWidth = (280.0 * LeadStage.values.length) + (16.0 * 4);
        final columnWidth = availableWidth >= minTotalWidth
            ? (availableWidth - (16.0 * 4)) / LeadStage.values.length
            : 280.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: LeadStage.values.map((stage) {
              final stageLeads = ref.watch(leadsForStageProvider(stage));
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: LeadColumn(
                  stage: stage,
                  leads: stageLeads,
                  width: columnWidth,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMobileKanban() {
    final activeStageLeads = ref.watch(
      leadsForStageProvider(_activeMobileStage),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal Stage Selector Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: LeadStage.values.map((stage) {
              final isSelected = stage == _activeMobileStage;
              final count = ref.watch(leadsForStageProvider(stage)).length;

              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 12),
                child: ChoiceChip(
                  label: Text('${stage.label} ($count)'),
                  selected: isSelected,
                  selectedColor: stage.color.withValues(alpha: 0.25),
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? stage.color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? stage.color
                        : AppColors.border.withValues(alpha: 0.5),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _activeMobileStage = stage);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Single primary active column fills screen without overflow
        Expanded(
          child: LeadColumn(
            stage: _activeMobileStage,
            leads: activeStageLeads,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}
