import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/auth_provider.dart';

/// Screen displayed when an authenticated user does not have Manager permissions.
class UnauthorizedScreen extends ConsumerWidget {
  const UnauthorizedScreen({super.key, this.userEmail});

  final String? userEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String email = userEmail ?? 'Employee';
    try {
      final user = ref.watch(authNotifierProvider).valueOrNull;
      if (user?.email != null && user!.email!.isNotEmpty) {
        email = user.email!;
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: GlassCard(
                showGlow: true,
                padding: const EdgeInsets.all(AppSpacing.xl2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.error.withAlpha(80),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        color: AppColors.error,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Manager Access Required',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Signed in as $email.\n\n'
                      'The VALIXIS Manager application is strictly restricted to company managers, founders, and leads.\n\n'
                      'Please use the VALIXIS Web Portal for employee tasks or sign in with an authorized manager account.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl2),
                    AppButton(
                      label: 'Sign Out',
                      variant: AppButtonVariant.secondary,
                      prefixIcon: Icons.logout_rounded,
                      isFullWidth: true,
                      onPressed: () {
                        try {
                          ref.read(authNotifierProvider.notifier).signOut();
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
