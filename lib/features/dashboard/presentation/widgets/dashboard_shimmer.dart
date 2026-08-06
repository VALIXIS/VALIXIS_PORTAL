import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_shimmer.dart';

/// Shimmer placeholder layout while dashboard data loads.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppShimmer(width: double.infinity, height: 100),
            const SizedBox(height: AppSpacing.lg),
            const AppShimmer(width: 140, height: 20),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: const [
                Expanded(child: AppShimmer(width: double.infinity, height: 36)),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: AppShimmer(width: double.infinity, height: 36)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: const [
                Expanded(child: AppShimmer(width: double.infinity, height: 120)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: AppShimmer(width: double.infinity, height: 120)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const AppShimmer(width: 160, height: 24),
            const SizedBox(height: AppSpacing.md),
            const AppShimmer(width: double.infinity, height: 90),
            const SizedBox(height: AppSpacing.md),
            const AppShimmer(width: double.infinity, height: 90),
          ],
        ),
      ),
    );
  }
}
