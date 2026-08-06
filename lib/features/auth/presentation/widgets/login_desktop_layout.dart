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
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl4,
          vertical: AppSpacing.xl2,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xl4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withAlpha(25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.brandBlue.withAlpha(50),
                            width: 1.5,
                          ),
                        ),
                        child: Image.asset(
                          'assets/logos/valixis_icon.png',
                          width: 48,
                          height: 48,
                          errorBuilder: (context, error, _) => const Icon(
                            Icons.bolt_rounded,
                            size: 48,
                            color: AppColors.brandCyan,
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
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Next-Generation Enterprise Portal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl2),
                      const _BrandTagline(),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
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
            ],
          ),
        ),
      ),
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
        _FeaturePill(
          icon: Icons.bolt_rounded,
          title: 'Unified Operations Workspace',
          subtitle: 'Seamless task allocation and real-time review tracking',
        ),
        SizedBox(height: AppSpacing.md),
        _FeaturePill(
          icon: Icons.shield_outlined,
          title: 'Role-Based Enterprise Access',
          subtitle: 'Granular permissions for managers and employees',
        ),
        SizedBox(height: AppSpacing.md),
        _FeaturePill(
          icon: Icons.auto_awesome_rounded,
          title: 'AI-Assisted Workflow Suite',
          subtitle: 'Integrated prompt engineering and automated PR workflows',
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.brandCyan),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
