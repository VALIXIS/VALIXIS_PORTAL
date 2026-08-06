import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/empty_state.dart';
import '../../../../shared/components/glass_card.dart';

class _AttachmentItem {
  _AttachmentItem({
    required this.name,
    required this.size,
    required this.extension,
  });

  final String name;
  final String size;
  final String extension;
  bool isDownloading = false;
}

/// Task file attachments manager with drop zone UI and upload capabilities.
class TaskAttachmentsCard extends StatefulWidget {
  const TaskAttachmentsCard({super.key});

  @override
  State<TaskAttachmentsCard> createState() => _TaskAttachmentsCardState();
}

class _TaskAttachmentsCardState extends State<TaskAttachmentsCard> {
  final List<_AttachmentItem> _attachments = [];

  void _simulateDownload(_AttachmentItem item) {
    setState(() => item.isDownloading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => item.isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded ${item.name} successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _simulateUpload() {
    setState(() {
      _attachments.add(
        _AttachmentItem(
          name: 'attachment_${DateTime.now().millisecondsSinceEpoch}.txt',
          size: '256 KB',
          extension: 'TXT',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File attached successfully!'),
        backgroundColor: AppColors.info,
      ),
    );
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.attach_file_rounded,
                      color: AppColors.brandPurple, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Task Attachments',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.cloud_upload_rounded,
                    color: AppColors.brandCyan),
                tooltip: 'Upload Attachment',
                onPressed: _simulateUpload,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_attachments.isEmpty)
            const EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'No Attachments Uploaded',
              description: 'Attach files or specifications to this task workspace.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _attachments.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final file = _attachments[index];

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.insert_drive_file_rounded,
                            color: AppColors.brandCyan, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              file.size,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (file.isDownloading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.download_rounded,
                              size: 18, color: AppColors.brandCyan),
                          onPressed: () => _simulateDownload(file),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
