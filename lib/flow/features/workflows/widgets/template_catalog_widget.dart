import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/templates_provider.dart';

class TemplateCatalogWidget extends ConsumerWidget {
  const TemplateCatalogWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(templatesProvider);
    final notifier = ref.read(templatesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.electricCyan, size: 24),
            SizedBox(width: 8),
            Text(
              'Flagship Templates Catalog (1-Click Provisioner)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Deploy battle-tested AI automation pipelines into your workspace with a single click.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            mainAxisExtent: 330,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.templates.length,
          itemBuilder: (context, index) {
            final tmpl = state.templates[index];
            final isProvisioning = state.provisioningSlug == tmpl.slug;

            return Card(
              color: AppColors.obsidianCard,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(tmpl.badge).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getBadgeColor(tmpl.badge).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                tmpl.badge,
                                style: TextStyle(color: _getBadgeColor(tmpl.badge), fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            const Icon(Icons.bolt, color: AppColors.electricCyan, size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tmpl.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tmpl.description,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: tmpl.stepChips.map((chip) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.obsidianSurface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.obsidianBorder),
                              ),
                              child: Text(
                                chip,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isProvisioning
                                ? null
                                : () async {
                                    final success = await notifier.provisionTemplate(tmpl.slug);
                                    if (context.mounted && success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Provisioned "${tmpl.name}" into workspace!'),
                                          backgroundColor: AppColors.emeraldGreen,
                                        ),
                                      );
                                    }
                                  },
                            icon: isProvisioning
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.play_arrow, size: 16),
                            label: Text(isProvisioning ? 'Provisioning...' : 'Use Template'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricCyan,
                              foregroundColor: AppColors.obsidianDark,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'popular':
        return AppColors.emeraldGreen;
      case 'operations':
        return AppColors.violetAccent;
      case 'finance':
      default:
        return AppColors.electricCyan;
    }
  }
}
