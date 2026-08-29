import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/audit_logs_provider.dart';
import 'widgets/audit_logs_table.dart';

/// Screen for Manager Security Audit Logs & System Activity Timeline with Clear All functionality.
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
  bool _isClearing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              'Clear All Audit Logs?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all security audit logs? This action cannot be undone and will permanently purge all recorded system authentication & activity logs.',
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
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Clear Everything', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isClearing = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('audit_logs').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      ref.invalidate(auditLogsProvider);

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(AppRoutes.managerDashboard),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Security Audit Logs',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Real-time system events, role allocations, and security logs',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppButton(
                  label: _isClearing ? 'Clearing...' : 'Clear Audit Logs',
                  prefixIcon: Icons.delete_sweep_rounded,
                  variant: AppButtonVariant.danger,
                  onPressed: _isClearing ? null : _onClearAllLogs,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassCard(
              showGlow: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: logsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl4),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Error loading audit logs',
                  description: err.toString(),
                ),
                data: (logs) {
                  final filtered = _query.isEmpty
                      ? logs
                      : logs
                          .where((l) =>
                              l.action.toLowerCase().contains(_query) ||
                              l.actor.toLowerCase().contains(_query))
                          .toList();

                  return Column(
                    children: [
                      AppTextField(
                        controller: _searchController,
                        hint: 'Filter audit logs by actor or event action...',
                        prefixIcon: Icons.search_rounded,
                        onChanged: (val) =>
                            setState(() => _query = val.toLowerCase().trim()),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (filtered.isEmpty)
                        const EmptyState(
                          icon: Icons.fact_check_rounded,
                          title: 'No Security Audit Logs Recorded',
                          description:
                              'Real-time audit log events will be recorded here upon employee authentication.',
                        )
                      else
                        AuditLogsTable(logs: filtered),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
