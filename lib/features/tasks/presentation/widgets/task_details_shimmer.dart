import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_shimmer.dart';

/// Shimmer loader skeleton for TaskDetailsScreen.
class TaskDetailsShimmer extends StatelessWidget {
  const TaskDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AppShimmer(width: 320, height: 32),
          SizedBox(height: AppSpacing.base),
          AppShimmer(width: double.infinity, height: 120),
          SizedBox(height: AppSpacing.base),
          AppShimmer(width: double.infinity, height: 160),
          SizedBox(height: AppSpacing.base),
          AppShimmer(width: double.infinity, height: 140),
        ],
      ),
    );
  }
}
