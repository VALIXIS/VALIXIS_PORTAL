import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/glass_card.dart';

/// Card component displaying AI Prompt with one-click clipboard copying.
class AiPromptCard extends StatelessWidget {
  const AiPromptCard({super.key, required this.prompt});

  final String prompt;

  void _copyPromptToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: prompt));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.brandCyan),
        ),
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.brandCyan),
            SizedBox(width: AppSpacing.sm),
            Text(
              'AI Prompt copied to clipboard!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome_rounded,
                      color: AppColors.brandCyan, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'AI Prompt',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              AppButton(
                label: 'Copy AI Prompt',
                prefixIcon: Icons.copy_rounded,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => _copyPromptToClipboard(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase.withAlpha(180),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              prompt,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
