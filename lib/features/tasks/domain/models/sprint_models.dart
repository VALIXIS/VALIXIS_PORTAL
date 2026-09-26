import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/task.dart';

/// Multi-app sprint target mobile applications.
enum SprintApp {
  all('All Apps', null, AppColors.brandCyan, Icons.apps_rounded),
  fitora('Fitora', '🏃', Color(0xFF10B981), Icons.directions_run_rounded),
  planly('Planly', '📱', Color(0xFF8B5CF6), Icons.calendar_month_rounded),
  aiPdfMaker('AI PDF Maker', '📄', Color(0xFFF59E0B), Icons.picture_as_pdf_rounded),
  resumeBrain('Resume Brain', '🧠', Color(0xFF00E5FF), Icons.psychology_rounded);

  const SprintApp(this.label, this.emoji, this.color, this.icon);

  final String label;
  final String? emoji;
  final Color color;
  final IconData icon;

  String get displayName => emoji != null ? '$emoji $label' : label;

  /// Resolves the app from task repository, branch, title, or prompt content.
  static SprintApp fromTask(Task task) {
    final search = '${task.githubRepo ?? ''} ${task.title} ${task.description ?? ''} ${task.branchName ?? ''} ${task.objective ?? ''}'
        .toLowerCase();

    if (search.contains('fitora') || search.contains('fitness') || search.contains('workout') || search.contains('diet')) {
      return SprintApp.fitora;
    }
    if (search.contains('planly') || search.contains('planner') || search.contains('routine') || search.contains('habit')) {
      return SprintApp.planly;
    }
    if (search.contains('pdf') || search.contains('ai_pdf') || search.contains('document') || search.contains('scan')) {
      return SprintApp.aiPdfMaker;
    }
    if (search.contains('resume') || search.contains('cv') || search.contains('career') || search.contains('interview')) {
      return SprintApp.resumeBrain;
    }
    return SprintApp.all;
  }
}

/// Sprint team members for 5-developer workload isolation.
enum SprintMember {
  all('All Members', 'ALL', AppColors.brandCyan),
  hasitha('Hasitha', 'H', Color(0xFFEC4899)),
  vignesh('Vignesh', 'V', Color(0xFF3B82F6)),
  krishna('Krishna', 'K', Color(0xFF10B981)),
  vaseem('Vaseem', 'V', Color(0xFFF59E0B)),
  adithya('Adithya', 'A', Color(0xFF8B5CF6));

  const SprintMember(this.name, this.initial, this.color);

  final String name;
  final String initial;
  final Color color;

  bool matches(String assignee) {
    if (this == SprintMember.all) return true;
    final lower = assignee.toLowerCase().trim();
    return lower.contains(name.toLowerCase());
  }

  static SprintMember fromAssignee(String assignee) {
    final lower = assignee.toLowerCase().trim();
    for (final member in SprintMember.values) {
      if (member != SprintMember.all && lower.contains(member.name.toLowerCase())) {
        return member;
      }
    }
    return SprintMember.all;
  }
}

/// Day-by-day 10-day sprint schedule selector.
enum SprintDay {
  all('All Days', 'ALL', 0),
  day1('Day 1 (Mon)', 'D1', 1),
  day2('Day 2 (Tue)', 'D2', 2),
  day3('Day 3 (Wed)', 'D3', 3),
  day4('Day 4 (Thu)', 'D4', 4),
  day5('Day 5 (Fri)', 'D5', 5),
  day6('Day 6 (Mon)', 'D6', 6),
  day7('Day 7 (Tue)', 'D7', 7),
  day8('Day 8 (Wed)', 'D8', 8),
  day9('Day 9 (Thu)', 'D9', 9),
  day10('Day 10 (Fri)', 'D10', 10);

  const SprintDay(this.label, this.shortLabel, this.dayNumber);

  final String label;
  final String shortLabel;
  final int dayNumber;

  /// Resolves the sprint day from title, branch, description, or deadline offset.
  static SprintDay fromTask(Task task) {
    final text = '${task.title} ${task.branchName ?? ''} ${task.description ?? ''}'.toLowerCase();
    
    for (int i = 1; i <= 10; i++) {
      if (text.contains('day $i') ||
          text.contains('day-$i') ||
          text.contains('day_$i') ||
          text.contains('day$i') ||
          text.contains('d$i-') ||
          text.contains('d$i/')) {
        return SprintDay.values.firstWhere((d) => d.dayNumber == i, orElse: () => SprintDay.all);
      }
    }

    // Heuristic: compute from task deadline day of month or task creation day
    final dayVal = (task.deadline.day % 10) + 1;
    return SprintDay.values.firstWhere((d) => d.dayNumber == dayVal, orElse: () => SprintDay.day1);
  }
}

/// 5-stage sprint PR and implementation lifecycle.
enum SprintWorkflowStage {
  assigned('Assigned', AppColors.brandPurple, Icons.assignment_outlined, 0),
  inProgress('In Progress', AppColors.warning, Icons.trending_up_rounded, 1),
  apkTesting('APK Testing', Color(0xFF38BDF8), Icons.android_rounded, 2),
  prSubmitted('PR Submitted', Color(0xFF6366F1), Icons.commit_rounded, 3),
  approved('Approved', AppColors.success, Icons.verified_rounded, 4);

  const SprintWorkflowStage(this.label, this.color, this.icon, this.stageIndex);

  final String label;
  final Color color;
  final IconData icon;
  final int stageIndex;

  static SprintWorkflowStage fromTask(Task task) {
    if (task.status == TaskStatus.approved) return SprintWorkflowStage.approved;
    if (task.status == TaskStatus.submitted || (task.prUrl != null && task.prUrl!.isNotEmpty)) {
      return SprintWorkflowStage.prSubmitted;
    }
    if (task.status == TaskStatus.inProgress) {
      final text = '${task.title} ${task.description ?? ''}'.toLowerCase();
      if (text.contains('test') || text.contains('apk') || text.contains('qa')) {
        return SprintWorkflowStage.apkTesting;
      }
      return SprintWorkflowStage.inProgress;
    }
    return SprintWorkflowStage.assigned;
  }
}
