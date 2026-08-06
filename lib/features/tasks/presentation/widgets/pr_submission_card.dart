import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../providers/task_details_provider.dart';
import '../providers/tasks_provider.dart';

/// Card component for submitting GitHub Pull Request URLs via Supabase Edge Function.
class PrSubmissionCard extends ConsumerStatefulWidget {
  const PrSubmissionCard({
    super.key,
    required this.task,
    this.onSubmitted,
  });

  final Task task;
  final VoidCallback? onSubmitted;

  @override
  ConsumerState<PrSubmissionCard> createState() => _PrSubmissionCardState();
}

class _PrSubmissionCardState extends ConsumerState<PrSubmissionCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prController;

  @override
  void initState() {
    super.initState();
    _prController = TextEditingController(text: widget.task.prUrl ?? '');
  }

  @override
  void dispose() {
    _prController.dispose();
    super.dispose();
  }

  Future<void> _submitPr() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success =
          await ref.read(submissionNotifierProvider.notifier).submitPr(
                taskId: widget.task.id,
                prUrl: _prController.text.trim(),
              );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceElevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: const BorderSide(color: AppColors.success),
              ),
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.success),
                  SizedBox(width: AppSpacing.sm),
                  Text('Pull Request submitted successfully!',
                      style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          );
          ref.invalidate(dashboardProvider);
          ref.invalidate(tasksProvider);
          ref.invalidate(taskDetailsProvider(widget.task.id));
          widget.onSubmitted?.call();
        } else {
          final error = ref.read(submissionNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceElevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: const BorderSide(color: AppColors.error),
              ),
              content: Text(
                'Submission failed: ${error ?? "Unknown error"}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(submissionNotifierProvider);
    final isLoading = submissionState.isLoading;
    final isSubmitted = widget.task.status == TaskStatus.submitted ||
        widget.task.status == TaskStatus.approved;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      showGlow: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.merge_type_rounded,
                    color: AppColors.brandBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'PR Submission',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isSubmitted
                  ? 'Pull Request already submitted for review.'
                  : 'Submit your GitHub Pull Request URL when implementation is complete.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _prController,
              label: 'GitHub Pull Request URL',
              hint: 'https://github.com/valixis/repo/pull/12',
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              enabled: !isLoading,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'PR URL is required';
                }
                final uri = Uri.tryParse(val.trim());
                if (uri == null ||
                    !uri.hasAbsolutePath ||
                    !val.startsWith('https://github.com/')) {
                  return 'Enter a valid GitHub PR URL (https://github.com/...)';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: isSubmitted ? 'Update PR Link' : 'Submit Pull Request',
              onPressed: isLoading ? null : _submitPr,
              isLoading: isLoading,
              isFullWidth: true,
              size: AppButtonSize.large,
              prefixIcon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
