import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import 'widgets/audit_logs_table.dart';

/// Screen for Manager Security Audit Logs & System Activity Timeline.
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

  final List<AuditLogItem> _logs = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _logs
        : _logs
            .where((l) =>
                l.action.toLowerCase().contains(_query) ||
                l.actor.toLowerCase().contains(_query))
            .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: AppSpacing.xl),
            GlassCard(
              showGlow: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
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
                          'Real-time audit log events will be recorded here.',
                    )
                  else
                    AuditLogsTable(logs: filtered),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
