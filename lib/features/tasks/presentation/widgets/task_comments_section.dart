import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/glass_card.dart';
import 'markdown_content_view.dart';

class _CommentItem {
  _CommentItem({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isOwn = false,
  });

  final String id;
  final String authorName;
  String content;
  final DateTime createdAt;
  final bool isOwn;
}

/// Task discussion and threaded comments widget with @mentions and Markdown rendering.
class TaskCommentsSection extends StatefulWidget {
  const TaskCommentsSection({super.key, required this.taskId});

  final String taskId;

  @override
  State<TaskCommentsSection> createState() => _TaskCommentsSectionState();
}

class _TaskCommentsSectionState extends State<TaskCommentsSection> {
  final _commentController = TextEditingController();
  final List<_CommentItem> _comments = [
    _CommentItem(
      id: 'c1',
      authorName: 'Alex Rivera (Lead)',
      content:
          'Please ensure unit tests cover state transitions for @Sarah and @Employee.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    _CommentItem(
      id: 'c2',
      authorName: 'You',
      content:
          'Working on this now! Added ````flutter test```` verification script.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      isOwn: true,
    ),
  ];

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(
        _CommentItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorName: 'You',
          content: text,
          createdAt: DateTime.now(),
          isOwn: true,
        ),
      );
      _commentController.clear();
    });
  }

  void _insertMention(String mention) {
    _commentController.text = '${_commentController.text} @$mention ';
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  void _deleteComment(String id) {
    setState(() {
      _comments.removeWhere((c) => c.id == id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.forum_rounded, color: AppColors.brandCyan, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Task Discussion & Comments',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.border, height: 16),
            itemBuilder: (context, index) {
              final c = _comments[index];
              final initials =
                  c.authorName.isNotEmpty ? c.authorName[0].toUpperCase() : 'U';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: c.isOwn
                                ? AppColors.brandCyan.withAlpha(40)
                                : AppColors.brandPurple.withAlpha(40),
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: c.isOwn
                                    ? AppColors.brandCyan
                                    : AppColors.brandPurple,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            c.authorName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (c.isOwn)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.error),
                          onPressed: () => _deleteComment(c.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  MarkdownContentView(content: c.content),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text(
                'Mention team:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(width: AppSpacing.xs),
              _MentionChip(label: 'Alex', onTap: () => _insertMention('Alex')),
              const SizedBox(width: 4),
              _MentionChip(
                  label: 'Sarah', onTap: () => _insertMention('Sarah')),
              const SizedBox(width: 4),
              _MentionChip(label: 'Lead', onTap: () => _insertMention('Lead')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _commentController,
                  hint: 'Write a comment or mention @teammate...',
                  prefixIcon: Icons.chat_bubble_outline_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Post',
                prefixIcon: Icons.send_rounded,
                size: AppButtonSize.small,
                onPressed: _addComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MentionChip extends StatelessWidget {
  const _MentionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.brandBlue.withAlpha(25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.brandBlue.withAlpha(60)),
        ),
        child: Text(
          '@$label',
          style: const TextStyle(
            color: AppColors.brandCyan,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
