import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/auth_state_notifier.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';

/// Organization Setup Wizard for new authenticated users.
class OnboardingWizard extends ConsumerStatefulWidget {
  const OnboardingWizard({super.key});

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  late String _selectedCurrency;
  late String _selectedTimezone;

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = AppCurrency.supportedCurrencies.first.code;
    _selectedTimezone = AppTimezones.initialTimezone;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  String? _validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company or organization name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  Future<void> _handleCreateOrganization() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .createOrganization(
            companyName: _companyNameController.text.trim(),
            currency: _selectedCurrency,
            timezone: _selectedTimezone,
          );
      // Automatic navigation to /dashboard is triggered by GoRouter reacting to AuthState
    } catch (e) {
      if (mounted) {
        final state = ref.read(authStateProvider);
        if (state is AuthError) {
          setState(() => _errorMessage = state.message);
        } else {
          setState(
            () => _errorMessage =
                'Failed to create organization. Please try again.',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Set Up Your Workspace',
                      subtitle:
                          'Create your organization to initialize the Business OS.',
                    ),
                    const SizedBox(height: 28),

                    // Inline Error
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    AuthTextField(
                      label: 'Company or Business Name',
                      hintText: 'Acme Corporation',
                      controller: _companyNameController,
                      prefixIcon: Icons.business_rounded,
                      enabled: !_isLoading,
                      validator: _validateCompanyName,
                    ),
                    const SizedBox(height: 20),

                    // Currency Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operating Currency', style: AppTypography.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCurrency,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevated,
                          style: AppTypography.body.copyWith(fontSize: 14),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.monetization_on_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          items: AppCurrency.supportedCurrencies.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.code,
                              child: Text(
                                '${c.code} — ${c.name} (${c.symbol})',
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoading
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() => _selectedCurrency = val);
                                  }
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Timezone Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Workspace Timezone', style: AppTypography.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTimezone,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevated,
                          style: AppTypography.body.copyWith(fontSize: 14),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          items: AppTimezones.commonTimezones.map((tz) {
                            return DropdownMenuItem<String>(
                              value: tz,
                              child: Text(tz),
                            );
                          }).toList(),
                          onChanged: _isLoading
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() => _selectedTimezone = val);
                                  }
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    AuthSubmitButton(
                      label: 'Create Organization',
                      loadingLabel: 'Creating workspace...',
                      isLoading: _isLoading,
                      onPressed: _handleCreateOrganization,
                    ),
                    const SizedBox(height: 16),

                    // Sign Out option
                    Center(
                      child: TextButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => ref
                                  .read(authNotifierProvider.notifier)
                                  .logout(),
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        label: Text(
                          'Sign Out and switch user',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
