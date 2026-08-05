import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_shimmer.dart';

class ManagerShimmer extends StatelessWidget {
  const ManagerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer(width: 220, height: 28),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: const [
              Expanded(child: AppShimmer(width: double.infinity, height: 100)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: AppShimmer(width: double.infinity, height: 100)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: AppShimmer(width: double.infinity, height: 100)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppShimmer(width: double.infinity, height: 250),
        ],
      ),
    );
  }
}
