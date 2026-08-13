import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/models/employee.dart';
import 'providers/employee_management_provider.dart';
import 'providers/whatsapp_provider.dart';

class WhatsAppScreen extends ConsumerStatefulWidget {
  const WhatsAppScreen({super.key});

  @override
  ConsumerState<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends ConsumerState<WhatsAppScreen> {
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();
  String? _selectedEmployeeId;

  PlatformFile? _attachedFile;
  Uint8List? _attachedFileBytes;
  bool _isPicking = false;

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  String _lookupMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'gif': return 'image/gif';
      case 'pdf': return 'application/pdf';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls': return 'application/vnd.ms-excel';
      case 'xlsx': return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt': return 'text/plain';
      default: return 'application/octet-stream';
    }
  }

  Future<void> _pickFile() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // 5MB validation
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds the 5MB limit.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        Uint8List? bytes = file.bytes;
        if (bytes == null && !kIsWeb && file.path != null) {
          bytes = await io.File(file.path!).readAsBytes();
        }

        setState(() {
          _attachedFile = file;
          _attachedFileBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('[WhatsAppScreen] File picking error: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachedFile = null;
      _attachedFileBytes = null;
    });
  }

  Future<void> _send() async {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final employeesAsync = ref.read(employeeManagementProvider);
    final rawEmployees = employeesAsync.valueOrNull ?? [];
    final employee = rawEmployees.firstWhere((e) => e.employee.id == _selectedEmployeeId).employee;

    final phone = employee.phone;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected employee does not have a phone number.'), backgroundColor: AppColors.error),
      );
      return;
    }

    Map<String, dynamic>? filePayload;
    if (_attachedFile != null && _attachedFileBytes != null) {
      final ext = _attachedFile!.extension ?? 'bin';
      filePayload = {
        'base64': base64Encode(_attachedFileBytes!),
        'mimetype': _lookupMimeType(ext),
        'filename': _attachedFile!.name,
      };
    }

    final success = await ref.read(whatsappSendNotifierProvider.notifier).sendWhatsApp(
      recipient: phone,
      message: message,
      file: filePayload,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp message sent successfully!'), backgroundColor: AppColors.success),
        );
        _messageController.clear();
        _removeAttachment();
      } else {
        final error = ref.read(whatsappSendNotifierProvider).error;
        final errorMsg = error is Exception ? error.toString().replaceFirst('Exception: ', '') : error?.toString() ?? 'Failed to send message.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildStatusBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeManagementProvider);
    final isEmployeesLoading = employeesAsync.isLoading;
    final hasEmployeesError = employeesAsync.hasError;

    final rawEmployees = employeesAsync.valueOrNull ?? [];
    final employees = rawEmployees;

    Employee? selectedEmployee;
    if (_selectedEmployeeId != null) {
      for (final e in employees) {
        if (e.employee.id == _selectedEmployeeId) {
          selectedEmployee = e.employee;
          break;
        }
      }
    }

    final hasPhone = selectedEmployee != null &&
        selectedEmployee.phone != null &&
        selectedEmployee.phone!.trim().isNotEmpty;

    final isSending = ref.watch(whatsappSendNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(AppRoutes.managerDashboard),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Direct WhatsApp Broadcast',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Compose manual alerts and attach files directly to team members',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                GlassCard(
                  showGlow: true,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Select Recipient
                      Row(
                        children: const [
                          Icon(Icons.person_outline_rounded, color: AppColors.brandCyan, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            '1. Select Employee',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (isEmployeesLoading)
                        _buildStatusBox(
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandCyan),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text('Loading employee roster...', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ],
                          ),
                        )
                      else if (hasEmployeesError)
                        _buildStatusBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Unable to fetch employee roster.', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                              TextButton(
                                onPressed: () => ref.refresh(employeeManagementProvider),
                                child: const Text('Retry', style: TextStyle(color: AppColors.brandCyan, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        )
                      else if (employees.isEmpty)
                        _buildStatusBox(
                          child: Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                              SizedBox(width: AppSpacing.sm),
                              Text('No employees available.', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedEmployeeId,
                          dropdownColor: AppColors.surfaceElevated,
                          style: const TextStyle(color: AppColors.textPrimary),
                          hint: const Text('Choose an employee from team roster', style: TextStyle(color: AppColors.textMuted)),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_search_rounded, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                          ),
                          items: employees.map((e) {
                            final hasNoPhoneMarker = (e.employee.phone == null || e.employee.phone!.trim().isEmpty) ? ' (No Phone)' : '';
                            return DropdownMenuItem(
                              value: e.employee.id,
                              child: Text(
                                '${e.employee.fullName} (${e.employee.email})$hasNoPhoneMarker',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: isSending ? null : (val) => setState(() => _selectedEmployeeId = val),
                        ),

                      if (selectedEmployee != null && !hasPhone) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: const [
                            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 14),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'This employee does not have a phone number registered in the database.',
                              style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      // Step 2: Compose Message
                      Row(
                        children: const [
                          Icon(Icons.chat_bubble_outline_rounded, color: AppColors.brandBlue, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            '2. Message details',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      KeyboardListener(
                        focusNode: _messageFocusNode,
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                            if (!HardwareKeyboard.instance.isShiftPressed) {
                              _send();
                            }
                          }
                        },
                        child: AppTextField(
                          controller: _messageController,
                          hint: 'Type your WhatsApp message here... (Press Enter to Send, Shift+Enter for new line)',
                          maxLines: 5,
                          enabled: !isSending,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Step 3: Attach file
                      Row(
                        children: const [
                          Icon(Icons.attach_file_rounded, color: AppColors.brandPurple, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            '3. Optional file attachment (Max 5MB)',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      if (_attachedFile != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined, color: AppColors.brandPurple),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _attachedFile!.name,
                                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(_attachedFile!.size / 1024).toStringAsFixed(1)} KB',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                                onPressed: isSending ? null : _removeAttachment,
                              ),
                            ],
                          ),
                        )
                      else
                        AppButton(
                          label: _isPicking ? 'Opening Picker...' : 'Attach File (Image/PDF/Doc)',
                          prefixIcon: Icons.add_to_photos_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: isSending || _isPicking ? null : _pickFile,
                          isFullWidth: true,
                        ),

                      const SizedBox(height: AppSpacing.xl2),

                      AppButton(
                        label: 'Send WhatsApp Message',
                        prefixIcon: Icons.send_rounded,
                        onPressed: isSending || _selectedEmployeeId == null || !hasPhone ? null : _send,
                        isLoading: isSending,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
