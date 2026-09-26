import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

/// Helper utility for one-click Antigravity prompt clipboard copying with haptics and toast.
abstract final class TaskPromptHelper {
  static void copyAgPrompt(
    BuildContext context,
    String? prompt, {
    String? taskTitle,
  }) {
    HapticFeedback.mediumImpact();

    final textToCopy = (prompt != null && prompt.trim().isNotEmpty)
        ? prompt.trim()
        : (taskTitle != null ? '// Task: $taskTitle\n// Prompt awaiting specification' : '');

    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        elevation: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.brandCyan, width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandCyan.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.brandCyan,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Antigravity prompt copied to clipboard!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ready to paste directly into Google Antigravity',
                    style: TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
