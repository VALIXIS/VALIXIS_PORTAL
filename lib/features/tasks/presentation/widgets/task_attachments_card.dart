import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../../../shared/components/empty_state.dart';
import '../../../../shared/components/glass_card.dart';

class _RealAttachmentItem {
  _RealAttachmentItem({
    required this.name,
    required this.sizeFormatted,
    required this.extension,
    required this.bytes,
  });

  final String name;
  final String sizeFormatted;
  final String extension;
  final Uint8List bytes;
}

/// Task file attachments card with real file picker uploading and browser file downloading.
class TaskAttachmentsCard extends StatefulWidget {
  const TaskAttachmentsCard({super.key});

  @override
  State<TaskAttachmentsCard> createState() => _TaskAttachmentsCardState();
}

class _TaskAttachmentsCardState extends State<TaskAttachmentsCard> {
  final List<_RealAttachmentItem> _attachments = [];
  bool _isUploading = false;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickAndUploadFile() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        final bytes = platformFile.bytes;
        final name = platformFile.name;

        if (bytes != null && bytes.isNotEmpty) {
          setState(() {
            _attachments.add(
              _RealAttachmentItem(
                name: name,
                sizeFormatted: _formatBytes(bytes.length),
                extension: name.contains('.') ? name.split('.').last.toUpperCase() : 'FILE',
                bytes: bytes,
              ),
            );
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploaded "$name" (${_formatBytes(bytes.length)}) successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _downloadFile(_RealAttachmentItem item) {
    try {
      downloadFile(item.name, item.bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading "${item.name}"... Check your Downloads folder.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteAttachment(int index) {
    final removed = _attachments.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${removed.name}"'),
        backgroundColor: AppColors.warning,
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
                  Icon(Icons.attach_file_rounded, color: AppColors.brandPurple, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Task Attachments',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isUploading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.cloud_upload_rounded, size: 16),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload File',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                onPressed: _isUploading ? null : _pickAndUploadFile,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_attachments.isEmpty)
            const EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'No Attachments Uploaded',
              description: 'Click "Upload File" above to pick real PDF, image, code, or spec files from your computer.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _attachments.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          file.extension,
                          style: const TextStyle(
                            color: AppColors.brandCyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              file.sizeFormatted,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_download_rounded, color: AppColors.brandCyan, size: 20),
                        tooltip: 'Download file to computer',
                        onPressed: () => _downloadFile(file),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                        tooltip: 'Delete attachment',
                        onPressed: () => _deleteAttachment(index),
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
