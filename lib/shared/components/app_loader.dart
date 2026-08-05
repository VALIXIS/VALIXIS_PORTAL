import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// App-wide loading indicator.
///
/// Uses the VALIXIS brand gradient for the circular progress.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = 32.0,
    this.strokeWidth = 2.5,
    this.message,
  });

  final double size;
  final double strokeWidth;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
            backgroundColor: AppColors.surfaceElevated,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-screen loading overlay.
class AppLoaderOverlay extends StatelessWidget {
  const AppLoaderOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceBase,
      child: Center(child: AppLoader(message: message)),
    );
  }
}
