import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/team_provider.dart';

/// Modal dialog allowing administrators to invite new members to the tenant organization.
class InviteMemberDialog extends ConsumerStatefulWidget {
  const InviteMemberDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (context) => const InviteMemberDialog(),
    );
  }

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();

  String _selectedRole = 'employee'; // 'employee' | 'admin'
  bool _isSubmitting = false;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    if (_isSubmitting) return;

    setState(() {
      _localError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await ref
        .read(teamMembersProvider.notifier)
        .inviteMember(
          email: _emailController.text.trim(),
          role: _selectedRole,
          fullName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          jobTitle: _jobTitleController.text.trim().isNotEmpty
              ? _jobTitleController.text.trim()
              : null,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final inviteError = ref.read(teamMembersProvider).inviteError;
      setState(() {
        _localError =
            inviteError ?? 'Failed to send invitation. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inviteError = ref.watch(teamMembersProvider).inviteError;
    final displayError = _localError ?? inviteError;

    return Dialog(
      key: const Key('invite_member_dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassContainer(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person_add_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Invite Team Member',
                                style: AppTypography.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: AppColors.textMuted,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a colleague to your organization workspace with assigned governance role.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // Error Banner
                  if (displayError != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayError,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email Input Field
                  Text('Email Address *', style: AppTypography.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('invite_email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isSubmitting,
                    style: AppTypography.body.copyWith(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'colleague@valixis.io',
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email address is required';
                      }
                      final email = value.trim();
                      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!regex.hasMatch(email)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Full Name (Optional)
                  Text('Full Name', style: AppTypography.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('invite_name_field'),
                    controller: _nameController,
                    enabled: !_isSubmitting,
                    style: AppTypography.body.copyWith(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Jane Smith',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Title (Optional)
                  Text('Job Title / Designation', style: AppTypography.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('invite_job_title_field'),
                    controller: _jobTitleController,
                    enabled: !_isSubmitting,
                    style: AppTypography.body.copyWith(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Operations Specialist',
                      prefixIcon: Icon(Icons.work_outline_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role Selection (Employee vs Admin)
                  Text('Access & Governance Role', style: AppTypography.label),
                  const SizedBox(height: 8),
                  _buildRoleSelector(),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        key: const Key('invite_cancel_button'),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        key: const Key('invite_submit_button'),
                        onPressed: _isSubmitting ? null : _handleInvite,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.send_rounded, size: 16),
                                  SizedBox(width: 8),
                                  Text('Send Invitation'),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      key: const Key('invite_role_selector'),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _RoleChoiceCard(
              title: 'Employee',
              subtitle: 'Operational execution & tasks',
              icon: Icons.badge_outlined,
              isSelected: _selectedRole == 'employee',
              onTap: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _selectedRole = 'employee';
                      });
                    },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _RoleChoiceCard(
              title: 'Admin',
              subtitle: 'Full governance & management',
              icon: Icons.shield_rounded,
              isSelected: _selectedRole == 'admin',
              onTap: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _selectedRole = 'admin';
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10.5,
                color: isSelected
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
