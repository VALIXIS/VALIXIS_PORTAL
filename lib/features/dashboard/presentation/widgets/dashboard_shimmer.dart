import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_shimmer.dart';

/// Shimmer layout while dashboard data is loading.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer(width: 240, height: 32),
          const SizedBox(height: AppSpacing.xs),
          const AppShimmer(width: 180, height: 18),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: const [
              Expanded(child: AppShimmer(width: double.infinity, height: 110)),
              SizedBox(width: AppSpacing.base),
              Expanded(child: AppShimmer(width: double.infinity, height: 110)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppShimmer(width: 160, height: 24),
          const SizedBox(height: AppSpacing.base),
          const AppShimmer(width: double.infinity, height: 90),
          const SizedBox(height: AppSpacing.base),
          const AppShimmer(width: double.infinity, height: 90),
        ],
      ),
    );
  }
}
