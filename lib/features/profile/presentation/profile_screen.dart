import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import 'widgets/profile_account_details.dart';
import 'widgets/profile_hero_header.dart';
import 'widgets/profile_metrics_summary.dart';
import 'widgets/profile_shimmer.dart';

/// Enterprise Profile Screen rendering employee profile, role badges, and task performance metrics.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: dashboardAsync.when(
        loading: () => const ProfileShimmer(),
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Unable to load Profile',
            description: 'Failed to retrieve your profile information.',
            action: AppButton(
              label: 'Retry Loading',
              prefixIcon: Icons.refresh_rounded,
              onPressed: () => ref.invalidate(dashboardProvider),
            ),
          ),
        ),
        data: (data) {
          final employee = data.employee;

          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ProfileHeroHeader(employee: employee),
                      const SizedBox(height: AppSpacing.md),
                      ProfileMetricsSummary(
                        pendingCount: data.pendingCount,
                        completedCount: data.completedCount,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProfileAccountDetails(employee: employee),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
