import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';

/// Modal dialog for recording manager feedback upon PR approval or rejection.
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.isApprove,
  });

  final String title;
  final String actionLabel;
  final bool isApprove;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required bool isApprove,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => FeedbackDialog(
        title: title,
        actionLabel: actionLabel,
        isApprove: isApprove,
      ),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isApprove ? AppColors.success : AppColors.error;

    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: iconColor.withAlpha(80), width: 1.5),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isApprove
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isApprove
                ? 'Add optional review comments for the employee:'
                : 'Provide required feedback or reasons for rejection:',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _controller,
            hint: widget.isApprove
                ? 'Great implementation! Unit tests passed.'
                : 'Please resolve merge conflicts and clean up dead code...',
            maxLines: 3,
            prefixIcon: Icons.chat_bubble_outline_rounded,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        AppButton(
          label: widget.actionLabel,
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
