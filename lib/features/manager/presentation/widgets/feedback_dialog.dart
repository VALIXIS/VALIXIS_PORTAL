import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';

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
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isApprove
                ? 'Optional approval comments for the employee:'
                : 'Provide feedback or reasons for rejection:',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _controller,
            hint: widget.isApprove ? 'Great job!' : 'Needs code cleanup...',
            maxLines: 3,
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
