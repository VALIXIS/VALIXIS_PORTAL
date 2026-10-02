import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ApiKeyRotationModal extends StatefulWidget {
  const ApiKeyRotationModal({super.key});

  @override
  State<ApiKeyRotationModal> createState() => _ApiKeyRotationModalState();
}

class _ApiKeyRotationModalState extends State<ApiKeyRotationModal> {
  final TextEditingController _keyNameController =
      TextEditingController(text: 'prod_telemetry_ingest_key');
  String? _newRotatedKey;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentProfile;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D111A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: user.role.canRotateApiKeys
                  ? const Color(0xFF00E5FF).withOpacity(0.4)
                  : const Color(0xFFFF5252).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: user.role.canRotateApiKeys
                    ? const Color(0xFF00E5FF).withOpacity(0.15)
                    : const Color(0xFFFF5252).withOpacity(0.15),
                blurRadius: 25,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.vpn_key_rounded,
                    color: user.role.canRotateApiKeys
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFFFF5252),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Rotate Organization API Key',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: user.role.roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: user.role.roleColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(user.role.roleIcon, color: user.role.roleColor, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Active Role: ${user.role.label.toUpperCase()}',
                        style: TextStyle(
                          color: user.role.roleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Target API Key Name:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _keyNameController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF161E2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gavel_rounded, color: Color(0xFFFF5252), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFFF5252),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_newRotatedKey != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API KEY ROTATED SUCCESSFULLY',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _newRotatedKey!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  ElevatedButton.icon(
                    onPressed: authProvider.isProcessing
                        ? null
                        : () async {
                            setState(() {
                              _errorMessage = null;
                              _newRotatedKey = null;
                            });
                            try {
                              final res = await authProvider.rotateApiKey(_keyNameController.text);
                              if (mounted) {
                                setState(() {
                                  _newRotatedKey = res?['new_api_key'] as String?;
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _errorMessage = e.toString().replaceAll('RbacException[UNAUTHORIZED]: ', '');
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.role.canRotateApiKeys
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFFFF5252),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: Text(
                      user.role.canRotateApiKeys ? 'Rotate Key Now' : 'Test Penetration Attempt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
