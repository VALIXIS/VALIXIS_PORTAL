import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/employee/presentation/providers/employee_provider.dart';
import '../../core/network/realtime_sync_service.dart';
import '../components/app_button.dart';

/// Modal bottom sheet presenting the manager's account information, sync status, and secure sign-out.
class ManagerProfileSheet extends ConsumerWidget {
  const ManagerProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ManagerProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final employee = ref.watch(employeeProvider).valueOrNull;
    final roleAsync = ref.watch(roleProvider);
    final syncState = ref.watch(realtimeSyncProvider);

    final email = user?.email ?? 'manager@valixis.com';
    final nameFromMeta = (user?.userMetadata?['full_name'] as String?) ??
        (user?.userMetadata?['name'] as String?) ??
        (user?.userMetadata?['display_name'] as String?);

    final String name;
    if (employee != null && employee.fullName.trim().isNotEmpty) {
      name = employee.fullName.trim();
    } else if (nameFromMeta != null && nameFromMeta.trim().isNotEmpty) {
      name = nameFromMeta.trim();
    } else if (email.toLowerCase() == 'official.valixis@gmail.com') {
      name = 'Subhash';
    } else if (email.toLowerCase().contains('jyothsna')) {
      name = 'Jyothsna';
    } else {
      final prefix = email.split('@').first;
      name = prefix
          .split(RegExp(r'[._-]'))
          .where((s) => s.isNotEmpty)
          .map((s) => s[0].toUpperCase() + s.substring(1))
          .join(' ');
    }
    final role = roleAsync.valueOrNull?.name.toUpperCase() ?? 'MANAGER';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandBlue.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1) : 'M',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: AppTypography.mono(
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.brandPurple.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    role,
                    style: AppTypography.telemetryHeader(
                      size: 9,
                      color: AppColors.brandPurple,
                      spacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),
            // Sync & connection details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      syncState.status == SyncConnectionState.connected
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_sync_rounded,
                      size: 18,
                      color: syncState.status == SyncConnectionState.connected
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Supabase Realtime Sync',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (syncState.status == SyncConnectionState.connected
                            ? AppColors.success
                            : AppColors.warning)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    syncState.status.name.toUpperCase(),
                    style: TextStyle(
                      color: syncState.status == SyncConnectionState.connected
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Force Refresh Data',
              prefixIcon: Icons.refresh_rounded,
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
              onPressed: () {
                ref.read(realtimeSyncProvider.notifier).forceRefresh();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Synchronized latest data from Supabase.'),
                    backgroundColor: AppColors.surfaceElevated,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Sign Out',
              prefixIcon: Icons.logout_rounded,
              variant: AppButtonVariant.danger,
              isFullWidth: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
