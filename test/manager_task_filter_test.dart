import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/features/tasks/domain/models/sprint_models.dart';
import 'package:valixis_portal/shared/models/task.dart';

void main() {
  group('Task and Priority Parsing', () {
    test('TaskPriority.fromString parses properly with fallback', () {
      expect(TaskPriority.fromString('Critical'), equals(TaskPriority.critical));
      expect(TaskPriority.fromString('urgent'), equals(TaskPriority.critical));
      expect(TaskPriority.fromString('high'), equals(TaskPriority.high));
      expect(TaskPriority.fromString('Medium'), equals(TaskPriority.medium));
      expect(TaskPriority.fromString('low'), equals(TaskPriority.low));
      expect(TaskPriority.fromString(null), equals(TaskPriority.low));
    });

    test('TaskStatus.fromString handles aliases and completion states', () {
      expect(TaskStatus.fromString('in_progress'), equals(TaskStatus.inProgress));
      expect(TaskStatus.fromString('in progress'), equals(TaskStatus.inProgress));
      expect(TaskStatus.fromString('under_review'), equals(TaskStatus.submitted));
      expect(TaskStatus.fromString('submitted'), equals(TaskStatus.submitted));
      expect(TaskStatus.fromString('approved'), equals(TaskStatus.approved));
      expect(TaskStatus.fromString('completed'), equals(TaskStatus.approved));
      expect(TaskStatus.fromString('rejected'), equals(TaskStatus.rejected));
      expect(TaskStatus.fromString('assigned'), equals(TaskStatus.assigned));

      expect(TaskStatus.approved.isCompleted, isTrue);
      expect(TaskStatus.inProgress.isCompleted, isFalse);
      expect(TaskStatus.inProgress.isPending, isTrue);
    });

    test('Task model serializes and deserializes cleanly', () {
      final now = DateTime.now();
      final task = Task(
        id: 't-99',
        title: 'Android Build Optimization',
        description: 'Configure Gradle for clean release build',
        objective: 'Ensure zero lint warnings',
        aiPrompt: 'You are an Android engineer',
        branchName: 'feature/android-build',
        githubRepo: 'VALIXIS_PORTAL',
        prUrl: 'https://github.com/valixis/portal/pull/99',
        priority: TaskPriority.critical,
        status: TaskStatus.inProgress,
        deadline: now,
        assignedTo: 'Nagasai',
        createdAt: now,
      );

      final json = task.toJson();
      expect(json['id'], equals('t-99'));
      expect(json['title'], equals('Android Build Optimization'));
      expect(json['priority'], equals('Critical'));
      expect(json['status'], equals('inProgress'));
      expect(json['assigned_to'], equals('Nagasai'));

      final reconstructed = Task.fromJson(json);
      expect(reconstructed.id, equals('t-99'));
      expect(reconstructed.title, equals('Android Build Optimization'));
      expect(reconstructed.priority, equals(TaskPriority.critical));
      expect(reconstructed.status, equals(TaskStatus.inProgress));
      expect(reconstructed.assignedTo, equals('Nagasai'));
    });
  });

  group('SprintApp Multi-App Resolution Engine', () {
    final now = DateTime.now();

    test('Resolves Krishna tasks to ResumeBrain despite PDF mentioned in title or prompt', () {
      // Exact task from the user screenshot:
      final task1 = Task(
        id: 'rsm-07',
        title: 'Krishna - Day 7: RSM-TPL-07 Golden Master PDF Audit & Test Suite',
        description: 'Export 20 sample resumes across all templates and verify 100% ATS readability and zero formatting artifacts.',
        githubRepo: 'VALIXIS/ResumeBrain',
        branchName: 'feature/krishna-resume-golden-pdf-audit',
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: now.add(const Duration(days: 4)),
        assignedTo: 'Krishna',
      );

      final task2 = Task(
        id: 'rsm-06',
        title: 'Krishna - Day 6: RSM-TPL-06 Export Customization Sheet',
        description: 'hiding icons, page numbers, photo avatar slots, and custom date formats in the export dialog.',
        githubRepo: 'VALIXIS/ResumeBrain',
        branchName: 'feature/krishna-resume-export-customization-sheet',
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: now.add(const Duration(days: 3)),
        assignedTo: 'Krishna',
      );

      expect(SprintApp.fromTask(task1), equals(SprintApp.resumeBrain));
      expect(SprintApp.fromTask(task2), equals(SprintApp.resumeBrain));
    });

    test('Tier 1: GitHub Repository takes absolute precedence', () {
      final taskResume = Task(
        id: 't-1',
        title: 'Export document to PDF preview',
        githubRepo: 'VALIXIS/ResumeBrain',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Krishna',
      );
      expect(SprintApp.fromTask(taskResume), equals(SprintApp.resumeBrain));

      final taskPdf = Task(
        id: 't-2',
        title: 'Scan user resume and OCR',
        githubRepo: 'VALIXIS/AI_PDF',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Vignesh',
      );
      expect(SprintApp.fromTask(taskPdf), equals(SprintApp.aiPdfMaker));

      final taskFitora = Task(
        id: 't-3',
        title: 'Add support for custom routine',
        githubRepo: 'VALIXIS/Fitora',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Hasitha',
      );
      expect(SprintApp.fromTask(taskFitora), equals(SprintApp.fitora));

      final taskPlanly = Task(
        id: 't-4',
        title: 'Support weekly calendar sync',
        githubRepo: 'VALIXIS/planly_app',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Adithya',
      );
      expect(SprintApp.fromTask(taskPlanly), equals(SprintApp.planly));

      final taskPulse = Task(
        id: 't-5',
        title: 'Executive dashboard metric telemetry',
        githubRepo: 'VALIXIS/Pulse',
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Jyothsna',
      );
      expect(SprintApp.fromTask(taskPulse), equals(SprintApp.pulse));

      final taskDesk = Task(
        id: 't-6',
        title: 'Helpdesk ticket assignment queue',
        githubRepo: 'VALIXIS/Desk',
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Jyothsna',
      );
      expect(SprintApp.fromTask(taskDesk), equals(SprintApp.desk));
    });

    test('Tier 2 & 3: Branch name and Title prefixes resolve correctly when repo is generic', () {
      final taskWithBranch = Task(
        id: 't-b1',
        title: 'Implement layout engine',
        githubRepo: 'VALIXIS_PORTAL',
        branchName: 'feature/krishna-resume-layout',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Krishna',
      );
      expect(SprintApp.fromTask(taskWithBranch), equals(SprintApp.resumeBrain));

      final taskWithTitleCode = Task(
        id: 't-c1',
        title: 'FIT-04 Calorie burn computation algorithm',
        githubRepo: null,
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Hasitha',
      );
      expect(SprintApp.fromTask(taskWithTitleCode), equals(SprintApp.fitora));

      final taskWithPdfCode = Task(
        id: 't-c2',
        title: 'PDF-02 OCR scanner batch converter',
        githubRepo: null,
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Vignesh',
      );
      expect(SprintApp.fromTask(taskWithPdfCode), equals(SprintApp.aiPdfMaker));
    });

    test('Avoids English collision with "support" and "routine"', () {
      final taskWithSupportVerb = Task(
        id: 't-supp',
        title: 'Add support for dark mode in Fitora fitness tracker',
        description: 'Support high contrast colors for gym workouts',
        githubRepo: null,
        priority: TaskPriority.low,
        status: TaskStatus.assigned,
        deadline: now,
        assignedTo: 'Hasitha',
      );
      expect(SprintApp.fromTask(taskWithSupportVerb), equals(SprintApp.fitora));
      expect(SprintApp.fromTask(taskWithSupportVerb), isNot(equals(SprintApp.desk)));
    });
  });
}
