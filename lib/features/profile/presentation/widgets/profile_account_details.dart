import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/employee.dart';

/// Detailed account settings and security information cards for profile.
class ProfileAccountDetails extends StatelessWidget {
  const ProfileAccountDetails({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.badge_outlined,
                      color: AppColors.brandCyan, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Account Information',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(label: 'Employee ID', value: employee.id),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _DetailRow(
                label: 'System Role',
                value: employee.role ?? 'Employee',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _DetailRow(
                label: 'Department',
                value: employee.department ?? 'General Operations',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_outlined,
                      color: AppColors.brandPurple, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Security & Compliance',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const _DetailRow(
                label: 'Authentication',
                value: 'Supabase JWT Secured',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              const _DetailRow(
                label: 'Encryption',
                value: '256-Bit SSL/TLS',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              const _DetailRow(
                label: 'Access Control',
                value: 'Role-Based Access (RBAC)',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        SelectableText(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
