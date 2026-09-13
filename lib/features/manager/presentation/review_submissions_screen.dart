import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/realtime_sync_service.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/manager_dashboard_provider.dart';
import 'providers/review_provider.dart';
import 'widgets/feedback_dialog.dart';

/// Screen for auditing and reviewing employee GitHub Pull Request submissions.
class ReviewSubmissionsScreen extends ConsumerStatefulWidget {
  const ReviewSubmissionsScreen({super.key});

  @override
  ConsumerState<ReviewSubmissionsScreen> createState() =>
      _ReviewSubmissionsScreenState();
}

class _ReviewSubmissionsScreenState
    extends ConsumerState<ReviewSubmissionsScreen> {
  String _selectedTab = 'pending'; // 'pending', 'approved', 'rejected', 'all'
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.read(realtimeSyncProvider.notifier).forceRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(managerDashboardProvider);
    final reviewState = ref.watch(reviewNotifierProvider);
    final isActionLoading = reviewState.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.brandCyan,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          _refresh();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: metricsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl4),
              child: CircularProgressIndicator(color: AppColors.brandCyan),
            ),
          ),
          error: (err, _) => Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Error loading submissions',
                description: err.toString(),
                action: AppButton(
                  label: 'Retry',
                  prefixIcon: Icons.refresh_rounded,
                  onPressed: _refresh,
                ),
              ),
            ),
          ),
          data: (metrics) {
            final allSubmissions = metrics.recentSubmissions;

            final filteredSubmissions = allSubmissions.where((sub) {
              final status = (sub['review_status']?.toString() ??
                      sub['status']?.toString() ??
                      'pending')
                  .toLowerCase()
                  .trim();

              if (_selectedTab == 'pending' && status != 'pending' && status != 'submitted') {
                return false;
              } else if (_selectedTab == 'approved' && status != 'approved') {
                return false;
              } else if (_selectedTab == 'rejected' && status != 'rejected') {
                return false;
              }

              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                final title = (sub['task_title']?.toString() ?? '').toLowerCase();
                final emp = (sub['employee_name']?.toString() ?? '').toLowerCase();
                final repo = (sub['github_repository']?.toString() ??
                        sub['github_repo']?.toString() ??
                        '')
                    .toLowerCase();
                final branch = (sub['branch_name']?.toString() ?? '').toLowerCase();
                if (!title.contains(q) &&
                    !emp.contains(q) &&
                    !repo.contains(q) &&
                    !branch.contains(q)) {
                  return false;
                }
              }

              return true;
            }).toList();

            final pendingCount = allSubmissions.where((s) {
              final st = (s['review_status']?.toString() ??
                      s['status']?.toString() ??
                      '')
                  .toLowerCase()
                  .trim();
              return st == 'pending' || st == 'submitted';
            }).length;

            final isDesktop = MediaQuery.of(context).size.width >= 900;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? AppSpacing.xl : AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reviews & PRs',
                            style: AppTypography.textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$pendingCount ${pendingCount == 1 ? 'pull request' : 'pull requests'} awaiting manager review',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (pendingCount > 0 ? AppColors.brandCyan : AppColors.success)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (pendingCount > 0 ? AppColors.brandCyan : AppColors.success)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          pendingCount > 0 ? '$pendingCount PENDING' : 'ALL REVIEWED',
                          style: AppTypography.telemetryHeader(
                            size: 9,
                            color: pendingCount > 0 ? AppColors.brandCyan : AppColors.success,
                            spacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Filter Tabs
                  Row(
                    children: [
                      _TabButton(
                        label: 'Pending',
                        count: pendingCount,
                        isSelected: _selectedTab == 'pending',
                        onTap: () => setState(() => _selectedTab = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'Approved',
                        isSelected: _selectedTab == 'approved',
                        onTap: () => setState(() => _selectedTab = 'approved'),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'Rejected',
                        isSelected: _selectedTab == 'rejected',
                        onTap: () => setState(() => _selectedTab = 'rejected'),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'All (${allSubmissions.length})',
                        isSelected: _selectedTab == 'all',
                        onTap: () => setState(() => _selectedTab = 'all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search reviews by task, employee, repo...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandCyan, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Submissions list
                  if (filteredSubmissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl3),
                      child: Center(
                        child: EmptyState(
                          icon: Icons.rate_review_rounded,
                          title: _selectedTab == 'pending'
                              ? 'No Pending PR Submissions'
                              : 'No Reviews Found',
                          description: _selectedTab == 'pending'
                              ? 'All submitted pull requests have been audited and reviewed.'
                              : 'No submissions match the selected filter criteria.',
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSubmissions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final sub = filteredSubmissions[index];
                        final taskId = sub['task_id']?.toString() ?? '';
                        final prUrl = sub['pr_url']?.toString() ?? '';
                        final rawStatus = (sub['review_status']?.toString() ??
                                sub['status']?.toString() ??
                                'pending')
                            .toLowerCase()
                            .trim();
                        final isPending = rawStatus == 'pending' || rawStatus == 'submitted';

                        final taskTitle = sub['task_title']?.toString() ?? 'Task #$taskId';
                        final employeeName = sub['employee_name']?.toString() ?? 'Employee';
                        final repo = sub['github_repository']?.toString() ??
                            sub['github_repo']?.toString() ??
                            sub['repo']?.toString() ??
                            'VALIXIS_PORTAL';
                        final branch = sub['branch_name']?.toString() ?? '';
                        final feedback = sub['manager_feedback']?.toString() ??
                            sub['feedback']?.toString();
                        final submittedAtRaw = sub['submitted_at']?.toString() ?? '';
                        final submittedAt = submittedAtRaw.length > 10
                            ? submittedAtRaw.substring(0, 10)
                            : submittedAtRaw;

                        final statusColor = switch (rawStatus) {
                          'approved' => AppColors.success,
                          'rejected' => AppColors.error,
                          _ => AppColors.warning,
                        };

                        return GlassCard(
                          isInteractive: true,
                          showGlow: isPending,
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: ID, repo, status pill
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          '#$taskId',
                                          style: AppTypography.mono(
                                            size: 11,
                                            weight: FontWeight.w700,
                                            color: AppColors.brandCyan,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandBlue.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.source_rounded, size: 11, color: AppColors.brandBlue),
                                            const SizedBox(width: 4),
                                            Text(
                                              repo,
                                              style: AppTypography.mono(
                                                size: 11,
                                                color: AppColors.brandBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: statusColor.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Text(
                                      rawStatus.toUpperCase(),
                                      style: AppTypography.telemetryHeader(
                                        size: 9,
                                        color: statusColor,
                                        spacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Task Title
                              Text(
                                taskTitle,
                                style: AppTypography.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              // Employee & Submission Time
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    employeeName,
                                    style: AppTypography.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (submittedAt.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      submittedAt,
                                      style: AppTypography.mono(
                                        size: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (branch.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.fork_right_rounded, size: 12, color: AppColors.brandPurple),
                                    const SizedBox(width: 4),
                                    Text(
                                      branch,
                                      style: AppTypography.mono(
                                        size: 11,
                                        color: AppColors.brandPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),

                              // PR URL pill (tappable to open GitHub in browser)
                              if (prUrl.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    final uri = Uri.tryParse(prUrl);
                                    if (uri != null) launchUrl(uri);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.commit_rounded, size: 15, color: AppColors.brandCyan),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            prUrl,
                                            style: AppTypography.mono(
                                              size: 12,
                                              color: AppColors.brandCyan,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.open_in_new_rounded, size: 13, color: AppColors.brandCyan),
                                      ],
                                    ),
                                  ),
                                ),

                              // Recorded feedback if exists
                              if (feedback != null && feedback.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: Text(
                                    'Manager Feedback: $feedback',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],

                              // Actions (Approve / Reject) if pending
                              if (isPending) ...[
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AppButton(
                                      label: 'Reject',
                                      variant: AppButtonVariant.danger,
                                      size: AppButtonSize.small,
                                      prefixIcon: Icons.cancel_rounded,
                                      onPressed: isActionLoading
                                          ? null
                                          : () async {
                                              final fb = await FeedbackDialog.show(
                                                context,
                                                title: 'Reject Submission',
                                                actionLabel: 'Confirm Rejection',
                                                isApprove: false,
                                              );
                                              if (fb != null) {
                                                await ref
                                                    .read(reviewNotifierProvider.notifier)
                                                    .reject(taskId: taskId, feedback: fb);
                                                _refresh();
                                              }
                                            },
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    AppButton(
                                      label: 'Approve',
                                      size: AppButtonSize.small,
                                      prefixIcon: Icons.check_circle_rounded,
                                      onPressed: isActionLoading
                                          ? null
                                          : () async {
                                              final fb = await FeedbackDialog.show(
                                                context,
                                                title: 'Approve Submission',
                                                actionLabel: 'Confirm Approval',
                                                isApprove: true,
                                              );
                                              if (fb != null) {
                                                await ref
                                                    .read(reviewNotifierProvider.notifier)
                                                    .approve(taskId: taskId, feedback: fb);
                                                _refresh();
                                              }
                                            },
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandBlue.withValues(alpha: 0.25) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.brandCyan : AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandCyan : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? AppColors.surfaceBase : AppColors.brandCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

