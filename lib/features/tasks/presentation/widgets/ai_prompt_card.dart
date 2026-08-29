import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/glass_card.dart';

/// Code-style panel component displaying AI Prompt with one-click clipboard copying.
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
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.brandCyan,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'AI Prompt Specification',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              AppButton(
                label: 'Copy AI Prompt',
                prefixIcon: Icons.copy_rounded,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                onPressed: () => _copyPromptToClipboard(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase.withAlpha(240),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.terminal_rounded,
                        size: 15, color: AppColors.brandCyan),
                    SizedBox(width: 6),
                    Text(
                      'AI_PROMPT_SPECIFICATION.MD',
                      style: TextStyle(
                        color: AppColors.brandCyan,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border, height: 20),
                SelectableText(
                  prompt,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
