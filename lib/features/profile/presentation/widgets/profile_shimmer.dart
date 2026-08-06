import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_shimmer.dart';

/// Loading skeleton for ProfileScreen.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: const [
          AppShimmer(width: double.infinity, height: 200),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: AppShimmer(width: double.infinity, height: 90)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppShimmer(width: double.infinity, height: 90)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppShimmer(width: double.infinity, height: 90)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppShimmer(width: double.infinity, height: 160),
        ],
      ),
    );
  }
}
