import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/ai_assistant_provider.dart';

/// Global trigger button for opening the VALIXIS AI Executive Assistant panel.
class AiAssistantButton extends ConsumerWidget {
  final bool isFloating;

  const AiAssistantButton({
    super.key,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(isAiPanelOpenProvider);
    final notifier = ref.read(aiAssistantProvider.notifier);

    const tooltipText = 'AI Executive Assistant';

    if (isFloating) {
      return FloatingActionButton(
        heroTag: 'ai_assistant_fab',
        onPressed: notifier.togglePanel,
        tooltip: tooltipText,
        backgroundColor: Colors.transparent,
        elevation: 6,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltipText,
      child: Semantics(
        label: tooltipText,
        button: true,
        child: IconButton(
          onPressed: notifier.togglePanel,
          tooltip: tooltipText,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: isOpen ? AppColors.purpleGradient : null,
              color: isOpen ? null : AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: isOpen ? Colors.white : AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
