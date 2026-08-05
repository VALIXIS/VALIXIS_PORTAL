import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'login_card.dart';

/// Desktop split-screen layout for authentication.
class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logos/valixis_icon.png',
                    width: 72,
                    errorBuilder: (context, error, _) => ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.brandGradient.createShader(b),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppColors.brandGradient.createShader(b),
                    child: const Text(
                      'VALIXIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Employee Portal',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  const _BrandTagline(),
                ],
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl3),
            child: LoginCard(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              obscurePassword: obscurePassword,
              isLoading: isLoading,
              onTogglePassword: onTogglePassword,
              onSignIn: onSignIn,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandTagline extends StatelessWidget {
  const _BrandTagline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Tag(icon: Icons.bolt_rounded, text: 'Unified workspace'),
        SizedBox(height: AppSpacing.sm),
        _Tag(icon: Icons.shield_outlined, text: 'Enterprise-grade security'),
        SizedBox(height: AppSpacing.sm),
        _Tag(icon: Icons.people_outline_rounded, text: 'Built for your team'),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.brandCyan),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
