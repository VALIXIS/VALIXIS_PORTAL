import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../providers/user_preferences_provider.dart';

/// Modal dialog for customizing workspace UI preferences.
class UserPreferencesDialog extends ConsumerWidget {
  const UserPreferencesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const UserPreferencesDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.brandPurple.withAlpha(80), width: 1.5),
      ),
      title: Row(
        children: const [
          Icon(Icons.tune_rounded, color: AppColors.brandPurple, size: 22),
          SizedBox(width: AppSpacing.sm),
          Text(
            'User Preferences',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Compact Layout Mode', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Reduces list padding for high-density viewing', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            value: prefs.isCompactMode,
            onChanged: (_) => notifier.toggleCompactMode(),
            activeTrackColor: AppColors.brandCyan,
          ),
          const Divider(color: AppColors.border),
          SwitchListTile(
            title: const Text('Motion & UI Animations', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Enable smooth page transitions & entrance effects', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            value: prefs.enableAnimations,
            onChanged: (_) => notifier.toggleAnimations(),
            activeTrackColor: AppColors.brandCyan,
          ),
          const Divider(color: AppColors.border),
          SwitchListTile(
            title: const Text('Push Notifications', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Receive real-time alerts for PR reviews & assignments', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            value: prefs.notificationsEnabled,
            onChanged: (_) => notifier.toggleNotifications(),
            activeTrackColor: AppColors.brandCyan,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done', style: TextStyle(color: AppColors.brandCyan, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
