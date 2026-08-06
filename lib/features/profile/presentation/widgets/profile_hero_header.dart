import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/employee.dart';

/// Hero header widget for employee profile displaying avatar, badges, and email.
class ProfileHeroHeader extends StatelessWidget {
  const ProfileHeroHeader({super.key, required this.employee});

  final Employee employee;

  void _copyEmailToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: employee.email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.brandCyan),
        ),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.brandCyan),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Work email copied to clipboard!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = employee.fullName.isNotEmpty
        ? employee.fullName[0].toUpperCase()
        : 'E';

    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.surfaceElevated,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.brandCyan,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            employee.fullName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (employee.role != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.brandPurple.withAlpha(60),
                    ),
                  ),
                  child: Text(
                    employee.role!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.brandPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (employee.department != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.brandBlue.withAlpha(60),
                    ),
                  ),
                  child: Text(
                    employee.department!,
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => _copyEmailToClipboard(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    employee.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded,
                      size: 12, color: AppColors.brandCyan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
