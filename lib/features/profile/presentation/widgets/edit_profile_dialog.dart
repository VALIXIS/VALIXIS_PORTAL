import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';

/// Modal dialog for editing profile information, bio, and contact details.
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({
    super.key,
    required this.initialBio,
    required this.initialPhone,
    required this.initialGithub,
    required this.initialLinkedin,
  });

  final String initialBio;
  final String initialPhone;
  final String initialGithub;
  final String initialLinkedin;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String bio,
    required String phone,
    required String github,
    required String linkedin,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => EditProfileDialog(
        initialBio: bio,
        initialPhone: phone,
        initialGithub: github,
        initialLinkedin: linkedin,
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _githubController = TextEditingController(text: widget.initialGithub);
    _linkedinController = TextEditingController(text: widget.initialLinkedin);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.brandCyan.withAlpha(80), width: 1.5),
      ),
      title: Row(
        children: const [
          Icon(Icons.edit_note_rounded, color: AppColors.brandCyan, size: 22),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Edit Profile & Contact Info',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.brandBlue.withAlpha(40),
                    child: const Icon(Icons.person_rounded,
                        size: 36, color: AppColors.brandCyan),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Avatar upload UI triggered (backend hook ready).'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.brandCyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: AppColors.surfaceBase),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _bioController,
              label: 'Professional Bio',
              hint: 'Senior Software Engineer specializing in Flutter & Cloud Architecture',
              prefixIcon: Icons.description_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _phoneController,
              label: 'Contact Phone',
              hint: '+1 (555) 019-2834',
              prefixIcon: Icons.phone_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _githubController,
              label: 'GitHub Profile URL',
              hint: 'https://github.com/valixis-dev',
              prefixIcon: Icons.code_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _linkedinController,
              label: 'LinkedIn Profile URL',
              hint: 'https://linkedin.com/in/valixis-dev',
              prefixIcon: Icons.link_rounded,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        AppButton(
          label: 'Save Profile Changes',
          size: AppButtonSize.small,
          onPressed: () {
            Navigator.pop(context, {
              'bio': _bioController.text.trim(),
              'phone': _phoneController.text.trim(),
              'github': _githubController.text.trim(),
              'linkedin': _linkedinController.text.trim(),
            });
          },
        ),
      ],
    );
  }
}
