import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/leads_provider.dart';

/// Modal dialog for creating or editing a CRM pipeline lead.
class LeadFormDialog extends ConsumerStatefulWidget {
  final Lead? existingLead;

  const LeadFormDialog({super.key, this.existingLead});

  static Future<Lead?> show(BuildContext context, {Lead? existingLead}) {
    return showDialog<Lead>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => LeadFormDialog(existingLead: existingLead),
    );
  }

  @override
  ConsumerState<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends ConsumerState<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _valueController;
  late final TextEditingController _notesController;

  late LeadStage _selectedStage;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingLead != null;

  @override
  void initState() {
    super.initState();
    final lead = widget.existingLead;

    _nameController = TextEditingController(text: lead?.name ?? '');
    _companyController = TextEditingController(text: lead?.companyName ?? '');
    _emailController = TextEditingController(text: lead?.email ?? '');
    _phoneController = TextEditingController(text: lead?.phone ?? '');
    _valueController = TextEditingController(
      text: lead != null && lead.estimatedValue > 0
          ? lead.estimatedValue.toStringAsFixed(0)
          : '',
    );
    _notesController = TextEditingController(text: lead?.notes ?? '');
    _selectedStage = lead?.stage ?? LeadStage.newLead;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final company = _companyController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final valueText = _valueController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(valueText) ?? 0.0;
    final notes = _notesController.text.trim();

    try {
      if (_isEditing) {
        final updatedLead = widget.existingLead!.copyWith(
          name: name,
          companyName: company,
          email: email.isNotEmpty ? email : null,
          phone: phone.isNotEmpty ? phone : null,
          stage: _selectedStage,
          estimatedValue: value,
          notes: notes.isNotEmpty ? notes : null,
        );

        final result = await ref
            .read(leadsNotifierProvider.notifier)
            .editLead(updatedLead);

        if (mounted) {
          if (result != null) {
            Navigator.of(context).pop(result);
          } else {
            setState(() {
              _isSubmitting = false;
              _errorMessage = 'Failed to update lead record.';
            });
          }
        }
      } else {
        final result = await ref
            .read(leadsNotifierProvider.notifier)
            .createLead(
              name: name,
              companyName: company,
              email: email.isNotEmpty ? email : null,
              phone: phone.isNotEmpty ? phone : null,
              stage: _selectedStage,
              estimatedValue: value,
              notes: notes.isNotEmpty ? notes : null,
            );

        if (mounted) {
          if (result != null) {
            Navigator.of(context).pop(result);
          } else {
            setState(() {
              _isSubmitting = false;
              _errorMessage = 'Failed to create lead.';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing
                                  ? 'Edit Lead'
                                  : 'New Sales Opportunity',
                              style: AppTypography.title.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEditing
                                  ? 'Update contact details or pipeline progress'
                                  : 'Add a new client prospect to the pipeline',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.border, height: 28),

                  // Error banner if any
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
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
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Fields
                  _buildTextField(
                    label: 'Contact / Lead Name *',
                    hint: 'e.g. Elena Rostova',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Contact name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    label: 'Company or Account Name *',
                    hint: 'e.g. Nexus Global Logistics',
                    controller: _companyController,
                    icon: Icons.business_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Company name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Work Email',
                          hint: 'contact@company.com',
                          controller: _emailController,
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              if (!v.contains('@') || !v.contains('.')) {
                                return 'Invalid email format';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildTextField(
                          label: 'Phone Number',
                          hint: '+1 (555) 000-0000',
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Deal Value (\$) *',
                          hint: '45000',
                          controller: _valueController,
                          icon: Icons.attach_money_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final numVal = double.tryParse(
                                v.replaceAll(',', ''),
                              );
                              if (numVal == null || numVal < 0) {
                                return 'Enter a positive value';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pipeline Stage',
                              style: AppTypography.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<LeadStage>(
                              initialValue: _selectedStage,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceElevated,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  _selectedStage.icon,
                                  color: _selectedStage.color,
                                  size: 18,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              items: LeadStage.values.map((s) {
                                return DropdownMenuItem<LeadStage>(
                                  value: s,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: s.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(s.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _selectedStage = val);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    label: 'Notes / Scope Summary',
                    hint:
                        'Key deal context, customer timeline, budget notes...',
                    controller: _notesController,
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Create Lead'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: !_isSubmitting,
          validator: validator,
          style: AppTypography.body.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
