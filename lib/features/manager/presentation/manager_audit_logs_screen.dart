import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/realtime_sync_service.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import 'providers/audit_logs_provider.dart';
import 'widgets/manager_audit_log_card.dart';

/// Screen for Manager Security Audit Logs & System Activity Timeline on mobile.
class ManagerAuditLogsScreen extends ConsumerStatefulWidget {
  const ManagerAuditLogsScreen({super.key});

  @override
  ConsumerState<ManagerAuditLogsScreen> createState() =>
      _ManagerAuditLogsScreenState();
}

class _ManagerAuditLogsScreenState
    extends ConsumerState<ManagerAuditLogsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'all';
  bool _isClearing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.read(realtimeSyncProvider.notifier).forceRefresh();
  }

  Future<void> _onClearAllLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.error.withAlpha(80), width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 22),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Clear Audit Logs?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all security audit logs? This action cannot be undone and permanently purges recorded system events.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isClearing = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('audit_logs')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
      _refresh();

      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All security audit logs cleared successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear audit logs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.brandCyan,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          _refresh();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: logsAsync.when(
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
                title: 'Error loading audit logs',
                description: err.toString(),
                action: AppButton(
                  label: 'Retry',
                  prefixIcon: Icons.refresh_rounded,
                  onPressed: _refresh,
                ),
              ),
            ),
          ),
          data: (logs) {
            final filtered = logs.where((l) {
              if (_selectedCategory != 'all') {
                if (_selectedCategory == 'active') {
                  if (!l.status.contains('Active')) return false;
                } else if (_selectedCategory == 'auth') {
                  if (l.category.toLowerCase() != 'authentication' &&
                      !l.action.toLowerCase().contains('login') &&
                      !l.action.toLowerCase().contains('logout')) {
                    return false;
                  }
                } else if (_selectedCategory == 'tasks') {
                  if (!l.category.toLowerCase().contains('task') &&
                      !l.action.toLowerCase().contains('task')) {
                    return false;
                  }
                }
              }

              if (_query.isNotEmpty) {
                final q = _query.toLowerCase();
                final matchActor = l.actor.toLowerCase().contains(q);
                final matchAction = l.action.toLowerCase().contains(q);
                final matchIp = l.ipAddress.toLowerCase().contains(q);
                final matchCategory = l.category.toLowerCase().contains(q);
                final matchDetails = (l.details ?? '').toLowerCase().contains(q);
                if (!matchActor && !matchAction && !matchIp && !matchCategory && !matchDetails) {
                  return false;
                }
              }

              return true;
            }).toList();

            final activeSessionCount = logs.where((l) => l.status.contains('Active')).length;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header with Clear Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Security & Audit Logs',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${logs.length} events recorded • $activeSessionCount active',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (logs.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.delete_sweep_rounded,
                            color: _isClearing ? AppColors.textMuted : AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'Clear Audit Logs',
                          onPressed: _isClearing ? null : _onClearAllLogs,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _CategoryFilterChip(
                          label: 'All (${logs.length})',
                          isSelected: _selectedCategory == 'all',
                          onTap: () => setState(() => _selectedCategory = 'all'),
                        ),
                        _CategoryFilterChip(
                          label: 'Active Sessions ($activeSessionCount)',
                          isSelected: _selectedCategory == 'active',
                          onTap: () => setState(() => _selectedCategory = 'active'),
                        ),
                        _CategoryFilterChip(
                          label: 'Authentication',
                          isSelected: _selectedCategory == 'auth',
                          onTap: () => setState(() => _selectedCategory = 'auth'),
                        ),
                        _CategoryFilterChip(
                          label: 'Tasks & Reviews',
                          isSelected: _selectedCategory == 'tasks',
                          onTap: () => setState(() => _selectedCategory = 'tasks'),
                        ),
                      ],
                    ),
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
                        hintText: 'Filter by actor, action, IP, or details...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandCyan, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _query = val.trim()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // List
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl3),
                      child: Center(
                        child: EmptyState(
                          icon: Icons.fact_check_rounded,
                          title: 'No Audit Logs Recorded',
                          description:
                              'Real-time audit log events will appear here when actions and logins occur.',
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return ManagerAuditLogCard(log: filtered[index]);
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandCyan.withAlpha(35) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.brandCyan : AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
