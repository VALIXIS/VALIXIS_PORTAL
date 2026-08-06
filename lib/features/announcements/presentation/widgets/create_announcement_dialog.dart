import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/models/announcement.dart';
import '../providers/announcements_provider.dart';

/// Modal dialog for managers to publish company announcements.
class CreateAnnouncementDialog extends ConsumerStatefulWidget {
  const CreateAnnouncementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const CreateAnnouncementDialog(),
    );
  }

  @override
  ConsumerState<CreateAnnouncementDialog> createState() => _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends ConsumerState<CreateAnnouncementDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  AnnouncementPriority _priority = AnnouncementPriority.standard;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    ref.read(announcementsProvider.notifier).addAnnouncement(
          title: title,
          content: content,
          author: 'Manager',
          priority: _priority,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Announcement published successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.brandCyan.withAlpha(80), width: 1.5),
      ),
      title: Row(
        children: const [
          Icon(Icons.campaign_rounded, color: AppColors.brandCyan, size: 22),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Publish Announcement',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Announcement Title',
              hint: 'e.g. Q3 Roadmap Review',
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _contentController,
              label: 'Message Content',
              hint: 'Details and instructions for the team...',
              prefixIcon: Icons.description_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<AnnouncementPriority>(
              initialValue: _priority,
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Priority Level',
                prefixIcon: Icon(Icons.flag_rounded, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
              items: AnnouncementPriority.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.label),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _priority = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        AppButton(
          label: 'Publish Notice',
          size: AppButtonSize.small,
          onPressed: _submit,
        ),
      ],
    );
  }
}
