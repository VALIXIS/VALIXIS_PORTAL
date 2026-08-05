import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_durations.dart';

/// Button variant for [AppButton].
enum AppButtonVariant { primary, secondary, ghost, danger }

/// VALIXIS reusable button component.
///
/// Supports primary gradient, secondary outlined, ghost, and danger variants.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return AnimatedOpacity(
      opacity: disabled ? 0.5 : 1.0,
      duration: AppDurations.fast,
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: size.height,
        child: switch (variant) {
          AppButtonVariant.primary => _PrimaryButton(button: this),
          AppButtonVariant.secondary => _SecondaryButton(button: this),
          AppButtonVariant.ghost => _GhostButton(button: this),
          AppButtonVariant.danger => _DangerButton(button: this),
        },
      ),
    );
  }
}

/// Button size presets.
enum AppButtonSize {
  small(36),
  medium(44),
  large(52);

  const AppButtonSize(this.height);
  final double height;

  double get fontSize => switch (this) {
        AppButtonSize.small => 12,
        AppButtonSize.medium => 14,
        AppButtonSize.large => 16,
      };

  EdgeInsets get padding => switch (this) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 12),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 28),
      };
}

// ── Private variant implementations ──────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.button, required this.color});

  final AppButton button;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (button.isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (button.prefixIcon != null) ...[
          Icon(button.prefixIcon, size: 16, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          button.label,
          style: TextStyle(
            fontSize: button.size.fontSize,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        if (button.suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(button.suffixIcon, size: 16, color: color),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.button});
  final AppButton button;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: button.isLoading ? null : button.onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          splashColor: Colors.white12,
          child: Padding(
            padding: button.size.padding,
            child: _ButtonContent(
              button: button,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.button});
  final AppButton button;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: button.isLoading ? null : button.onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.brandBlue, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: button.size.padding,
        foregroundColor: AppColors.brandBlue,
      ),
      child: _ButtonContent(button: button, color: AppColors.brandBlue),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.button});
  final AppButton button;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: button.isLoading ? null : button.onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: button.size.padding,
        foregroundColor: AppColors.textSecondary,
      ),
      child: _ButtonContent(button: button, color: AppColors.textSecondary),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.button});
  final AppButton button;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: button.isLoading ? null : button.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: button.size.padding,
        elevation: 0,
      ),
      child: _ButtonContent(button: button, color: AppColors.onPrimary),
    );
  }
}
