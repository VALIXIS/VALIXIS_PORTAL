import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Rich markdown and mention text content parser and renderer.
class MarkdownContentView extends StatelessWidget {
  const MarkdownContentView({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.contains('```')) {
      final parts = content.split('```');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(parts.length, (index) {
          if (index.isOdd) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              padding: const EdgeInsets.all(AppSpacing.md),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.brandCyan.withAlpha(60)),
              ),
              child: SelectableText(
                parts[index].trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppColors.brandCyan,
                  fontSize: 12,
                ),
              ),
            );
          }
          return _buildTextSpanWidget(parts[index]);
        }),
      );
    }

    return _buildTextSpanWidget(content);
  }

  Widget _buildTextSpanWidget(String text) {
    final words = text.split(' ');
    final spans = <InlineSpan>[];

    for (final word in words) {
      if (word.startsWith('@')) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: AppColors.brandCyan.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brandCyan.withAlpha(80)),
              ),
              child: Text(
                word,
                style: const TextStyle(
                  color: AppColors.brandCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}
