import 'package:flutter/material.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/glass_card.dart';

/// Premium Glassmorphism Login Card containing form inputs and submit button.
class LoginCard extends StatelessWidget {
  const LoginCard({
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: child,
          ),
        );
      },
      child: GlassCard(
        showGlow: true,
        borderRadius: AppRadius.xl2,
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logos/valixis_wordmark.png',
                      height: 44,
                      errorBuilder: (context, error, _) => const _FallbackWordmark(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _EnterpriseBadge(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Sign in to access your enterprise workspace',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              AppTextField(
                controller: emailController,
                label: 'Work Email',
                hint: 'name@company.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                enabled: !isLoading,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: passwordController,
                label: 'Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixIconTap: onTogglePassword,
                obscureText: obscurePassword,
                autofillHints: const [AutofillHints.password],
                enabled: !isLoading,
                onSubmitted: (_) => onSignIn(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.brandCyan,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              AppButton(
                label: 'Sign In',
                onPressed: isLoading ? null : onSignIn,
                isLoading: isLoading,
                isFullWidth: true,
                size: AppButtonSize.large,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Center(child: _SecurityFooter()),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnterpriseBadge extends StatelessWidget {
  const _EnterpriseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.brandBlue.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandBlue.withAlpha(60),
          width: 1,
        ),
      ),
      child: const Text(
        'ENTERPRISE PORTAL',
        style: TextStyle(
          color: AppColors.brandCyan,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
        SizedBox(width: 6),
        Text(
          'Protected by 256-bit enterprise encryption',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FallbackWordmark extends StatelessWidget {
  const _FallbackWordmark();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (b) => AppColors.brandGradient.createShader(b),
      child: const Text(
        'VALIXIS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 5,
        ),
      ),
    );
  }
}
