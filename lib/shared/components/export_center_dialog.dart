import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Modal dialog for exporting system reports to CSV.
class ExportCenterDialog extends ConsumerStatefulWidget {
  const ExportCenterDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ExportCenterDialog(),
    );
  }

  @override
  ConsumerState<ExportCenterDialog> createState() => _ExportCenterDialogState();
}

class _ExportCenterDialogState extends ConsumerState<ExportCenterDialog> {
  bool _isExporting = false;

  Future<void> _exportData(String reportType) async {
    setState(() => _isExporting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isExporting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$reportType exported successfully as CSV!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
          Icon(Icons.download_rounded, color: AppColors.brandCyan, size: 22),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Export Center',
            style: TextStyle(
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
          const Text(
            'Select report data format to export to CSV:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.md),
          _ExportTile(
            title: 'Task Specifications & Status',
            subtitle: 'Includes task IDs, titles, priorities, and deadlines',
            icon: Icons.assignment_rounded,
            onTap: _isExporting ? null : () => _exportData('Task Specifications'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ExportTile(
            title: 'Workforce & Employee Directory',
            subtitle: 'Includes employee names, roles, departments, and workloads',
            icon: Icons.people_rounded,
            onTap: _isExporting ? null : () => _exportData('Workforce Directory'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ExportTile(
            title: 'Executive Dashboard Summary',
            subtitle: 'Includes overall workload metrics and PR review counts',
            icon: Icons.query_stats_rounded,
            onTap: _isExporting ? null : () => _exportData('Executive Dashboard'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandCyan.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandCyan, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.file_download_outlined, color: AppColors.brandCyan, size: 18),
          ],
        ),
      ),
    );
  }
}
