import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_shimmer.dart';

/// Shimmer loader skeleton for ManagerDashboardScreen.
class ManagerShimmer extends StatelessWidget {
  const ManagerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
          const AppShimmer(width: double.infinity, height: 220),
          const SizedBox(height: AppSpacing.xl),
          const AppShimmer(width: double.infinity, height: 160),
        ],
      ),
    );
  }
}
