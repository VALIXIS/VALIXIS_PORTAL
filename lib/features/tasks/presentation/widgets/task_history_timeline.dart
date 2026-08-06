import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';

class _HistoryEvent {
  const _HistoryEvent({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
}

/// Task History & Audit Timeline displaying status, assignment, PR, and review history.
class TaskHistoryTimeline extends StatelessWidget {
  const TaskHistoryTimeline({super.key, required this.task});

  final Task task;

  List<_HistoryEvent> _buildHistoryEvents() {
    final now = DateTime.now();
    return [
      _HistoryEvent(
        title: 'Task Created',
        subtitle: 'Task specification initialized by Manager',
        timestamp: now.subtract(const Duration(days: 3)),
        icon: Icons.add_task_rounded,
        color: AppColors.brandBlue,
      ),
      _HistoryEvent(
        title: 'Assigned to Employee',
        subtitle: 'Task allocated to engineering workspace',
        timestamp: now.subtract(const Duration(days: 2)),
        icon: Icons.assignment_ind_rounded,
        color: AppColors.brandPurple,
      ),
      _HistoryEvent(
        title: 'Status: ${task.status}',
        subtitle: 'Current task status is updated in workflow',
        timestamp: now.subtract(const Duration(hours: 4)),
        icon: Icons.alt_route_rounded,
        color: AppColors.brandCyan,
      ),
      if (task.prUrl != null && task.prUrl!.isNotEmpty)
        _HistoryEvent(
          title: 'PR Submitted',
          subtitle: 'Pull Request linked: ${task.prUrl}',
          timestamp: now.subtract(const Duration(hours: 1)),
          icon: Icons.upload_file_rounded,
          color: AppColors.success,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final events = _buildHistoryEvents();

    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history_rounded, color: AppColors.brandCyan, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Task Audit & Event History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isLast = index == events.length - 1;
              final formattedDate = DateFormatter.formatShortDate(event.timestamp);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: event.color.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: event.color.withAlpha(80), width: 1.5),
                          ),
                          child: Icon(event.icon, color: event.color, size: 14),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: AppColors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
