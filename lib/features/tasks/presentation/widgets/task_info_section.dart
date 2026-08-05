import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';

/// Section displaying task title, objective, branch, repo link, and expected output.
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
        // Overview card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
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

        // Objective
        if (task.objective != null && task.objective!.isNotEmpty) ...[
          _DetailBlock(
            icon: Icons.flag_outlined,
            title: 'Objective',
            content: task.objective!,
          ),
          const SizedBox(height: AppSpacing.base),
        ],

        // Expected Output
        if (task.expectedOutput != null && task.expectedOutput!.isNotEmpty) ...[
          _DetailBlock(
            icon: Icons.verified_outlined,
            title: 'Expected Output',
            content: task.expectedOutput!,
          ),
          const SizedBox(height: AppSpacing.base),
        ],

        // Branch & Repo details
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              if (task.branchName != null && task.branchName!.isNotEmpty)
                _InfoRow(
                  icon: Icons.account_tree_outlined,
                  label: 'Branch Name',
                  valueWidget: SelectableText(
                    task.branchName!,
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (task.githubRepo != null && task.githubRepo!.isNotEmpty) ...[
                if (task.branchName != null && task.branchName!.isNotEmpty)
                  const Divider(height: AppSpacing.xl),
                _InfoRow(
                  icon: Icons.code_rounded,
                  label: 'GitHub Repository',
                  valueWidget: InkWell(
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
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new_rounded,
                            size: 14, color: AppColors.brandBlue),
                      ],
                    ),
                  ),
                ),
              ],
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
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
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Flexible(child: valueWidget),
      ],
    );
  }
}
