import 'package:flutter_test/flutter_test.dart';
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
}
