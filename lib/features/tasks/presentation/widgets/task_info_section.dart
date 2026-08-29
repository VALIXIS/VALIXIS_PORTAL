import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import 'task_badge.dart';

/// Section displaying complete read-only task information entered by manager.
class TaskInfoSection extends StatelessWidget {
  const TaskInfoSection({super.key, required this.task});

  final Task task;

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PriorityBadge(priority: task.priority),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.base),
                Text(
                  task.description!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        if (task.objective != null && task.objective!.isNotEmpty) ...[
          _DetailBlock(
            icon: Icons.flag_outlined,
            title: 'Objective',
            content: task.objective!,
          ),
          const SizedBox(height: AppSpacing.base),
        ],
        if (task.expectedOutput != null && task.expectedOutput!.isNotEmpty) ...[
          _DetailBlock(
            icon: Icons.verified_outlined,
            title: 'Expected Output',
            content: task.expectedOutput!,
          ),
          const SizedBox(height: AppSpacing.base),
        ],
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.code_rounded,
                label: 'Repository',
                valueWidget: task.githubRepo != null && task.githubRepo!.isNotEmpty
                    ? InkWell(
                        onTap: () => _launchUrl(task.githubRepo!),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              task.githubRepo!,
                              style: const TextStyle(
                                color: AppColors.brandBlue,
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.brandBlue),
                          ],
                        ),
                      )
                    : const Text('VALIXIS_PORTAL', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const Divider(height: AppSpacing.xl),
              const _InfoRow(
                icon: Icons.call_split_rounded,
                label: 'Base Branch',
                valueWidget: SelectableText(
                  'main',
                  style: TextStyle(color: AppColors.brandCyan, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                ),
              ),
              if (task.branchName != null &&
                  task.branchName!.isNotEmpty &&
                  !task.branchName!.contains(task.id.toLowerCase())) ...[
                const Divider(height: AppSpacing.xl),
                _InfoRow(
                  icon: Icons.account_tree_outlined,
                  label: 'Feature Branch',
                  valueWidget: SelectableText(
                    task.branchName!,
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                label: 'Assigned Date',
                valueWidget: Text(
                  task.createdAt != null ? DateFormatter.formatShortDate(task.createdAt!) : 'Recently Assigned',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const Divider(height: AppSpacing.xl),
              const _InfoRow(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Created By',
                valueWidget: Text(
                  'Engineering Manager',
                  style: TextStyle(color: AppColors.brandPurple, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.brandCyan, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.valueWidget,
  });

  final IconData icon;
  final String label;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
        Flexible(child: valueWidget),
      ],
    );
  }
}
