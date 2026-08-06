import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/activity_item.dart';

final activityFeedProvider = Provider<List<ActivityItem>>((ref) {
  final now = DateTime.now();
  return [
    ActivityItem(
      id: 'act-1',
      title: 'PR Submitted',
      description: 'Submitted PR #104 for "Authentication & Profile Redesign"',
      timestamp: now.subtract(const Duration(minutes: 18)),
      icon: Icons.upload_file_rounded,
      color: AppColors.brandCyan,
    ),
    ActivityItem(
      id: 'act-2',
      title: 'Task Assigned',
      description: 'Manager assigned task "Database Migration & Schema Audit"',
      timestamp: now.subtract(const Duration(hours: 3)),
      icon: Icons.assignment_ind_rounded,
      color: AppColors.brandBlue,
    ),
    ActivityItem(
      id: 'act-3',
      title: 'PR Approved',
      description: 'PR #102 "Employee Management Table" was approved & merged',
      timestamp: now.subtract(const Duration(hours: 6)),
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    ),
    ActivityItem(
      id: 'act-4',
      title: 'Code Audit Completed',
      description: 'Passed flutter analyze & static verification checks',
      timestamp: now.subtract(const Duration(days: 1)),
      icon: Icons.verified_rounded,
      color: AppColors.brandPurple,
    ),
  ];
});
