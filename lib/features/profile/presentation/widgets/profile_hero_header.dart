import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/employee.dart';
import 'edit_profile_dialog.dart';

/// Hero header widget for employee profile displaying avatar, badges, email, and Edit Profile action.
class ProfileHeroHeader extends StatefulWidget {
  const ProfileHeroHeader({super.key, required this.employee});

  final Employee employee;

  @override
  State<ProfileHeroHeader> createState() => _ProfileHeroHeaderState();
}

class _ProfileHeroHeaderState extends State<ProfileHeroHeader> {
  String _bio = 'Senior Software Engineer specializing in Flutter & Cloud Architecture';
  String _phone = '+1 (555) 019-2834';
  String _github = 'https://github.com/valixis-dev';
  String _linkedin = 'https://linkedin.com/in/valixis-dev';

  void _copyEmailToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.employee.email));
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

  Future<void> _openEditProfileDialog() async {
    final result = await EditProfileDialog.show(
      context,
      bio: _bio,
      phone: _phone,
      github: _github,
      linkedin: _linkedin,
    );

    if (result != null) {
      setState(() {
        _bio = result['bio'] ?? _bio;
        _phone = result['phone'] ?? _phone;
        _github = result['github'] ?? _github;
        _linkedin = result['linkedin'] ?? _linkedin;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile details updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.employee.fullName.isNotEmpty
        ? widget.employee.fullName[0].toUpperCase()
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
            widget.employee.fullName,
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
              if (widget.employee.role != null) ...[
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
                    widget.employee.role!.toUpperCase(),
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
              if (widget.employee.department != null) ...[
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
                    widget.employee.department!,
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
          Text(
            _bio,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                        widget.employee.email,
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
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Edit Profile',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                prefixIcon: Icons.edit_rounded,
                onPressed: _openEditProfileDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
