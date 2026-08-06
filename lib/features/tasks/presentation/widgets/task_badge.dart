import 'package:flutter/material.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../shared/models/task.dart';

/// Priority badge component with indicator dot and glowing outline.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: priority.color.withAlpha(65), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: priority.color.withAlpha(150),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: priority.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge component with soft translucent fill.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: status.color.withAlpha(65), width: 1),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
