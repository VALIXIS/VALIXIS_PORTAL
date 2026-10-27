import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_border_radius.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../shared/layout/responsive_layout.dart';
import 'providers/auth_provider.dart';
import 'widgets/login_background_orbs.dart';
import 'widgets/login_card.dart';
import 'widgets/login_desktop_layout.dart';

/// Login Screen wired to Supabase Auth via Riverpod with native browser autofill
/// and persistent remembered employee credentials.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _rememberEmail = true;

  @override
  void initState() {
    super.initState();
    _rememberEmail = AuthStorageService.getRememberMe();
    final savedEmail = AuthStorageService.getRememberedEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _passwordFocusNode.canRequestFocus) {
          _passwordFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Signal browser credential manager to capture credentials for 1-click Google autofill
      TextInput.finishAutofillContext(shouldSave: true);

      // Persist or clear remembered email based on user selection
      if (_rememberEmail && email.isNotEmpty) {
        AuthStorageService.setRememberedEmail(email);
        AuthStorageService.setRememberMe(true);
      } else {
        AuthStorageService.clearRememberedEmail();
        AuthStorageService.setRememberMe(false);
      }

      await ref.read(authNotifierProvider.notifier).signIn(
            email: email,
            password: password,
          );
    }
  }

  void _showErrorSnackBar(Object error) {
    final message = error is AuthException
        ? error.message
        : 'Authentication failed. Please verify your credentials.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.error),
        ),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<User?>>(authNotifierProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        _showErrorSnackBar(next.error!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            const LoginBackgroundOrbs(),
            SafeArea(
              child: ResponsiveLayout(
                mobile: (_) => Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xl2,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: LoginCard(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        passwordFocusNode: _passwordFocusNode,
                        obscurePassword: _obscurePassword,
                        isLoading: isLoading,
                        rememberEmail: _rememberEmail,
                        onToggleRememberEmail: (v) =>
                            setState(() => _rememberEmail = v),
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onSignIn: _onSignIn,
                      ),
                    ),
                  ),
                ),
                desktop: (_) => LoginDesktopLayout(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  passwordFocusNode: _passwordFocusNode,
                  obscurePassword: _obscurePassword,
                  isLoading: isLoading,
                  rememberEmail: _rememberEmail,
                  onToggleRememberEmail: (v) =>
                      setState(() => _rememberEmail = v),
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onSignIn: _onSignIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
