import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/app_breakpoints.dart';

/// Standardized page container for all authenticated features.
class AppPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool scrollable;
  final EdgeInsetsGeometry? customPadding;

  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.scrollable = true,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final horizontalPadding = customPadding != null
        ? 0.0
        : (isMobile ? 16.0 : (AppBreakpoints.isTablet(context) ? 24.0 : 32.0));
    final verticalPadding = isMobile ? 16.0 : 24.0;

    final headerSection = Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headline),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTypography.bodySmall),
                ],
                if (trailing != null) ...[
                  const SizedBox(height: 12),
                  trailing!,
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppTypography.headline),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!, style: AppTypography.bodyMedium),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing!],
              ],
            ),
    );

    Widget pageBody = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.maxContentWidth,
        ),
        child: Padding(
          padding:
              customPadding ??
              EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerSection,
              if (scrollable) child else Expanded(child: child),
            ],
          ),
        ),
      ),
    );

    if (scrollable) {
      pageBody = SingleChildScrollView(child: pageBody);
    }

    return ColoredBox(color: AppColors.background, child: pageBody);
  }
}
