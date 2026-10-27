import 'package:flutter/material.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/glass_card.dart';

/// Team members available for 1-click email pre-fill.
class _QuickEmployee {
  const _QuickEmployee({
    required this.name,
    required this.email,
    required this.initial,
    required this.color,
  });

  final String name;
  final String email;
  final String initial;
  final Color color;
}

const List<_QuickEmployee> _kQuickEmployees = [
  _QuickEmployee(
    name: 'Hasitha',
    email: 'hasitha@valixis.com',
    initial: 'H',
    color: Color(0xFFEC4899),
  ),
  _QuickEmployee(
    name: 'Krishna',
    email: 'krishna@valixis.com',
    initial: 'K',
    color: Color(0xFF10B981),
  ),
  _QuickEmployee(
    name: 'Vignesh',
    email: 'vignesh@valixis.com',
    initial: 'V',
    color: Color(0xFF3B82F6),
  ),
  _QuickEmployee(
    name: 'Adithya',
    email: 'adithya@valixis.com',
    initial: 'A',
    color: Color(0xFF8B5CF6),
  ),
  _QuickEmployee(
    name: 'Vaseem',
    email: 'vaseem@valixis.com',
    initial: 'V',
    color: Color(0xFFF59E0B),
  ),
];

/// Premium Glassmorphism Login Card containing form inputs and submit button.
/// Includes native browser AutofillGroup, Google Password Manager context,
/// and 1-click Quick Employee selectors.
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
    this.passwordFocusNode,
    this.rememberEmail = true,
    this.onToggleRememberEmail,
    this.onSelectEmployee,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSignIn;
  final FocusNode? passwordFocusNode;
  final bool rememberEmail;
  final ValueChanged<bool>? onToggleRememberEmail;
  final ValueChanged<String>? onSelectEmployee;

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
        child: AutofillGroup(
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
                        errorBuilder: (context, error, _) =>
                            const _FallbackWordmark(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _EnterpriseBadge(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
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
                  'Sign in to access your VALIXIS Portal',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Quick Employee Sign-In Selector ──────────────────────
                _buildQuickSelectSection(),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: emailController,
                  label: 'Work Email',
                  hint: 'name@company.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  enabled: !isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
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

                // ── Remember Email & Forgot Password Row ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: isLoading || onToggleRememberEmail == null
                          ? null
                          : () => onToggleRememberEmail!(!rememberEmail),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: rememberEmail,
                                onChanged: isLoading || onToggleRememberEmail == null
                                    ? null
                                    : (val) => onToggleRememberEmail!(val ?? true),
                                activeColor: AppColors.brandCyan,
                                checkColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember email',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
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
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
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
      ),
    );
  }

  Widget _buildQuickSelectSection() {
    final currentEmail = emailController.text.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'QUICK TEAM SIGN-IN',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            if (currentEmail.isNotEmpty && onSelectEmployee != null)
              InkWell(
                onTap: () => onSelectEmployee!(''),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.brandCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _kQuickEmployees.map((emp) {
              final isSelected = currentEmail == emp.email.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: isLoading || onSelectEmployee == null
                      ? null
                      : () => onSelectEmployee!(emp.email),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? emp.color.withValues(alpha: 0.2)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? emp.color
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: emp.color,
                          child: Text(
                            emp.initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          emp.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
