import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/task.dart';

/// Multi-app sprint & co-founder project suite.
enum SprintApp {
  all('All Projects', AppColors.brandCyan, Icons.apps_rounded),
  desk('Desk', Color(0xFF8B5CF6), Icons.support_agent_rounded),
  pulse('Pulse', Color(0xFF00E5FF), Icons.monitor_heart_rounded),
  fitora('Fitora', Color(0xFF10B981), Icons.directions_run_rounded),
  planly('Planly', Color(0xFF8B5CF6), Icons.calendar_month_rounded),
  aiPdfMaker('AI PDF Maker', Color(0xFFF59E0B), Icons.picture_as_pdf_rounded),
  resumeBrain('Resume Brain', Color(0xFF00E5FF), Icons.psychology_rounded);

  const SprintApp(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;

  String get displayName => label;

  /// Resolves the app/project using a deterministic 5-tier precedence engine:
  /// 1. GitHub Repository (Ground Truth Authority)
  /// 2. Git Branch Name (Explicit Developer Scope)
  /// 3. Task Title Codes & Prefixes (e.g. RSM-, FIT-, PLN-, PDF-, DSK-, PLS-)
  /// 4. Disambiguated Context (Resume/ATS > PDF Export, strict keyword matching)
  /// 5. Fallback: SprintApp.all
  static SprintApp fromTask(Task task) {
    // ── Tier 1: GitHub Repository (Absolute Ground Truth) ──
    final repo = (task.githubRepo ?? '').toLowerCase().trim();
    if (repo.isNotEmpty) {
      if (repo.contains('resumebrain') ||
          repo.contains('resume_brain') ||
          repo.contains('resume-brain') ||
          repo.contains('resume')) {
        return SprintApp.resumeBrain;
      }
      if (repo.contains('ai_pdf') ||
          repo.contains('ai-pdf') ||
          repo.contains('aipdf') ||
          repo.contains('pdf')) {
        return SprintApp.aiPdfMaker;
      }
      if (repo.contains('fitora')) {
        return SprintApp.fitora;
      }
      if (repo.contains('planly') || repo.contains('planly_app')) {
        return SprintApp.planly;
      }
      if (repo.contains('pulse')) {
        return SprintApp.pulse;
      }
      if (repo.contains('desk') || repo.contains('helpdesk')) {
        return SprintApp.desk;
      }
    }

    // ── Tier 2: Git Branch Name ──
    final branch = (task.branchName ?? '').toLowerCase().trim();
    if (branch.isNotEmpty) {
      if (branch.contains('resume') ||
          branch.contains('rsm-') ||
          branch.contains('rsm_') ||
          branch.contains('/rsm')) {
        return SprintApp.resumeBrain;
      }
      if (branch.contains('ai_pdf') ||
          branch.contains('ai-pdf') ||
          branch.contains('aipdf') ||
          branch.contains('-pdf-') ||
          branch.contains('/pdf-') ||
          branch.endsWith('-pdf') ||
          branch.contains('pdf_')) {
        return SprintApp.aiPdfMaker;
      }
      if (branch.contains('fitora') ||
          branch.contains('fit-') ||
          branch.contains('fit_') ||
          branch.contains('/fit')) {
        return SprintApp.fitora;
      }
      if (branch.contains('planly') ||
          branch.contains('pln-') ||
          branch.contains('pln_') ||
          branch.contains('/pln')) {
        return SprintApp.planly;
      }
      if (branch.contains('pulse') ||
          branch.contains('pls-') ||
          branch.contains('pls_') ||
          branch.contains('/pls')) {
        return SprintApp.pulse;
      }
      if (branch.contains('desk') ||
          branch.contains('dsk-') ||
          branch.contains('dsk_') ||
          branch.contains('/dsk') ||
          branch.contains('helpdesk')) {
        return SprintApp.desk;
      }
    }

    // ── Tier 3: Task Code & Title Prefixes ──
    final title = task.title.toLowerCase().trim();
    if (title.contains('rsm-') ||
        title.contains('rsm_') ||
        title.contains('rsm ') ||
        title.contains('resume brain') ||
        title.contains('resumebrain') ||
        title.startsWith('resume')) {
      return SprintApp.resumeBrain;
    }
    if (title.contains('fit-') ||
        title.contains('fit_') ||
        title.contains('fit ') ||
        title.contains('fitora')) {
      return SprintApp.fitora;
    }
    if (title.contains('pln-') ||
        title.contains('pln_') ||
        title.contains('pln ') ||
        title.contains('planly')) {
      return SprintApp.planly;
    }
    if (title.contains('pls-') ||
        title.contains('pls_') ||
        title.contains('pulse')) {
      return SprintApp.pulse;
    }
    if (title.contains('dsk-') ||
        title.contains('dsk_') ||
        title.contains('helpdesk') ||
        title.contains('valixis desk')) {
      return SprintApp.desk;
    }
    if (title.contains('pdf-') ||
        title.contains('pdf_') ||
        title.contains('ai pdf') ||
        title.contains('aipdf') ||
        title.contains('ai_pdf') ||
        title.contains('pdf maker')) {
      return SprintApp.aiPdfMaker;
    }

    // ── Tier 4: Disambiguated Context (Description, Objective, AI Prompt) ──
    final body = '${task.title} ${task.description ?? ''} ${task.objective ?? ''} ${task.aiPrompt ?? ''}'
        .toLowerCase();

    // Check Resume terms first because resumes export to PDF and use ATS scoring
    if (body.contains('resume') ||
        body.contains('curriculum vitae') ||
        body.contains('resumebrain') ||
        body.contains('ats readability') ||
        body.contains('ats score') ||
        body.contains('ats format')) {
      return SprintApp.resumeBrain;
    }

    // Check AI PDF Maker specific terms
    if (body.contains('ai pdf') ||
        body.contains('ai_pdf') ||
        body.contains('pdf maker') ||
        body.contains('pdf scanner') ||
        body.contains('pdf editor') ||
        body.contains('ocr scanner') ||
        body.contains('pdf merge') ||
        body.contains('pdf convert') ||
        (body.contains('pdf') &&
            !body.contains('resume') &&
            !body.contains('fitora') &&
            !body.contains('planly'))) {
      return SprintApp.aiPdfMaker;
    }

    // Fitora fitness domain
    if (body.contains('fitora') ||
        body.contains('workout') ||
        body.contains('calorie') ||
        body.contains('fitness') ||
        body.contains('exercise')) {
      return SprintApp.fitora;
    }

    // Planly routine & habits
    if (body.contains('planly') ||
        body.contains('habit tracker') ||
        body.contains('daily planner') ||
        body.contains('routine planner')) {
      return SprintApp.planly;
    }

    // Pulse telemetry
    if (body.contains('pulse') ||
        body.contains('telemetry') ||
        body.contains('forensic pivot') ||
        body.contains('anomaly detection')) {
      return SprintApp.pulse;
    }

    // Desk helpdesk / support (prevent matching generic "support" verb)
    if (body.contains('valixis desk') ||
        body.contains('helpdesk') ||
        body.contains('support ticket') ||
        body.contains('customer support')) {
      return SprintApp.desk;
    }

    return SprintApp.all;
  }
}

/// Sprint team members & co-founders for workload isolation.
enum SprintMember {
  all('All Members', 'ALL', AppColors.brandCyan),
  jyothsna('Jyothsna', 'J', Color(0xFF8B5CF6)),
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
