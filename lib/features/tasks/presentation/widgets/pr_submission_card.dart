import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

/// Card component for submitting GitHub Pull Request URLs with instructional helper guidelines
/// and automatic GitHub PR detection.
class PrSubmissionCard extends ConsumerStatefulWidget {
  const PrSubmissionCard({super.key, required this.task, this.onSubmitted});

  final Task task;
  final VoidCallback? onSubmitted;

  @override
  ConsumerState<PrSubmissionCard> createState() => _PrSubmissionCardState();
}

class _PrSubmissionCardState extends ConsumerState<PrSubmissionCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prController;
  bool _isAutoDetecting = false;

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

  /// Sanitizes input PR URL to ensure standard format (e.g., https://github.com/owner/repo/pull/123)
  String _sanitizeUrl(String input) {
    String trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;

    // Auto-prefix https:// if missing
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }

    // Standardize http -> https
    if (trimmed.startsWith('http://')) {
      trimmed = trimmed.replaceFirst('http://', 'https://');
    }

    return trimmed;
  }

  /// Validates GitHub PR URL with flexible pattern matching
  String? _validatePrUrl(String? val) {
    if (val == null || val.trim().isEmpty) return 'PR URL is required';
    final sanitized = _sanitizeUrl(val);

    final prRegex = RegExp(
      r'^https:\/\/(www\.)?github\.com\/[\w.-]+\/[\w.-]+\/pull\/\d+',
      caseSensitive: false,
    );

    if (!prRegex.hasMatch(sanitized)) {
      return 'Enter a valid GitHub PR URL (e.g. github.com/owner/repo/pull/123)';
    }

    return null;
  }

  Future<void> _submitPr() async {
    if (ref.read(submissionNotifierProvider).isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      final sanitizedUrl = _sanitizeUrl(_prController.text);
      _prController.text = sanitizedUrl;

      final success = await ref.read(submissionNotifierProvider.notifier).submitPr(
            taskId: widget.task.id,
            prUrl: sanitizedUrl,
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
                  Text('Pull Request submitted successfully!', style: TextStyle(color: AppColors.textPrimary)),
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
              content: Text('Submission failed: ${error ?? "Unknown error"}', style: const TextStyle(color: AppColors.textPrimary)),
            ),
          );
        }
      }
    }
  }

  Future<void> _autoDetectPr() async {
    setState(() => _isAutoDetecting = true);
    try {
      String repoPath = widget.task.githubRepo ?? 'VALIXIS/VALIXIS_PORTAL';
      repoPath = repoPath.replaceAll('https://github.com/', '').replaceAll('http://github.com/', '').trim();
      if (repoPath.endsWith('.git')) {
        repoPath = repoPath.substring(0, repoPath.length - 4);
      }

      final url = Uri.parse('https://api.github.com/repos/$repoPath/pulls?state=open&per_page=10');
      final response = await http.get(url, headers: {'Accept': 'application/vnd.github.v3+json'});

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> pulls = jsonDecode(response.body);
          if (pulls.isEmpty) {
            _showToast('No open PRs found on $repoPath. Please open a PR on GitHub first.', isError: true);
          } else {
            // Try matching branch name first
            Map<String, dynamic>? matchedPr;
            final targetBranch = widget.task.branchName?.trim();

            if (targetBranch != null && targetBranch.isNotEmpty) {
              for (final pr in pulls) {
                final headRef = pr['head']?['ref'] as String?;
                if (headRef != null && (headRef == targetBranch || headRef.contains(targetBranch))) {
                  matchedPr = pr as Map<String, dynamic>;
                  break;
                }
              }
            }

            // Fallback to most recent open PR
            matchedPr ??= pulls.first as Map<String, dynamic>;

            final htmlUrl = matchedPr['html_url'] as String;
            final prNumber = matchedPr['number'];
            final prTitle = matchedPr['title'];

            _prController.text = htmlUrl;
            _showToast('⚡ Auto-detected PR #$prNumber: "$prTitle"');
          }
        } else {
          _showToast('Could not fetch PRs from GitHub (HTTP ${response.statusCode}). Please paste PR URL manually.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to auto-detect PR. Please paste PR URL manually.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAutoDetecting = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: isError ? AppColors.error : AppColors.brandBlue),
        ),
        content: Row(
          children: [
            Icon(isError ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded, color: isError ? AppColors.error : AppColors.brandBlue),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(submissionNotifierProvider);
    final isLoading = submissionState.isLoading;
    final isSubmitted = widget.task.status == TaskStatus.submitted || widget.task.status == TaskStatus.approved;
    final repoName = widget.task.githubRepo ?? 'VALIXIS/VALIXIS_PORTAL';
    final branchName = widget.task.branchName;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      showGlow: true,
      child: Form(
        key: _formKey,
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
                      decoration: BoxDecoration(color: AppColors.brandBlue.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.merge_type_rounded, color: AppColors.brandBlue, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('PR Submission', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
                TextButton.icon(
                  onPressed: (_isAutoDetecting || isLoading) ? null : _autoDetectPr,
                  icon: _isAutoDetecting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandCyan))
                      : const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.brandCyan),
                  label: Text(
                    _isAutoDetecting ? 'Detecting...' : '⚡ Auto-Detect PR',
                    style: const TextStyle(color: AppColors.brandCyan, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.brandCyan.withAlpha(20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.brandCyan, width: 1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isSubmitted ? 'Pull Request already submitted for review.' : 'Submit your GitHub Pull Request URL when implementation is complete.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _prController,
              label: 'GitHub Pull Request URL',
              hint: 'https://github.com/VALIXIS/VALIXIS_PORTAL/pull/15',
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              enabled: !isLoading,
              validator: _validatePrUrl,
            ),
            const SizedBox(height: AppSpacing.md),
            _PrInstructionalHelperCard(repoName: repoName, branchName: branchName),
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

class _PrInstructionalHelperCard extends StatelessWidget {
  const _PrInstructionalHelperCard({required this.repoName, this.branchName});

  final String repoName;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final b = branchName;
    final hasCustomBranch = b != null &&
        b.isNotEmpty &&
        !b.contains('feature/');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.brandCyan),
              SizedBox(width: AppSpacing.xs),
              Text('Submission Guidelines', style: TextStyle(color: AppColors.brandCyan, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _HelperMetaRow(label: 'Repository:', value: repoName),
          const SizedBox(height: 4),
          const _HelperMetaRow(label: 'Target Branch:', value: 'main'),
          if (hasCustomBranch) ...[
            const SizedBox(height: 4),
            _HelperMetaRow(label: 'Feature Branch:', value: b),
          ],
          const SizedBox(height: 4),
          _HelperMetaRow(
            label: 'Example PR:',
            value: 'https://github.com/${repoName.replaceAll("https://github.com/", "")}/pull/1',
            isUrl: true,
          ),
        ],
      ),
    );
  }
}

class _HelperMetaRow extends StatelessWidget {
  const _HelperMetaRow({required this.label, required this.value, this.isUrl = false});

  final String label;
  final String value;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: isUrl ? AppColors.brandBlue : AppColors.textPrimary, fontSize: 12, fontFamily: isUrl ? null : 'monospace', fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
