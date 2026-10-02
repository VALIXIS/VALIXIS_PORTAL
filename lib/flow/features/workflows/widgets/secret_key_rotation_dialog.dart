import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class SecretKeyRotationDialog extends StatefulWidget {
  final String currentSecret;
  final void Function(String newSecret) onSecretRotated;

  const SecretKeyRotationDialog({
    super.key,
    required this.currentSecret,
    required this.onSecretRotated,
  });

  @override
  State<SecretKeyRotationDialog> createState() => _SecretKeyRotationDialogState();
}

class _SecretKeyRotationDialogState extends State<SecretKeyRotationDialog> {
  late String _newSecret;
  bool _showSecret = false;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _newSecret = _generateRandomSecret();
  }

  String _generateRandomSecret() {
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'vlx_sec_$hexStr';
  }

  void _regenerate() {
    setState(() {
      _newSecret = _generateRandomSecret();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.obsidianSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.obsidianBorder),
      ),
      title: const Row(
        children: [
          Icon(Icons.key, color: AppColors.electricCyan, size: 24),
          SizedBox(width: 8),
          Text(
            'Rotate Webhook Signing Secret',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rotating your secret immediately revokes all prior webhook HMAC signatures. External callers must update their X-Valixis-Signature headers.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            const Text(
              'NEW CRYPTOGRAPHIC SECRET TOKEN',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.obsidianDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.obsidianBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _showSecret ? _newSecret : '••••••••••••••••••••••••••••••••',
                      style: const TextStyle(
                        color: AppColors.electricCyan,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showSecret ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _showSecret = !_showSecret),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.electricCyan, size: 18),
                    onPressed: _regenerate,
                    tooltip: 'Generate New Secret',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.electricCyan, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _newSecret));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New secret copied to clipboard!')),
                      );
                    },
                    tooltip: 'Copy Secret',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton.icon(
          onPressed: _isRotating
              ? null
              : () async {
                  setState(() => _isRotating = true);
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                  widget.onSecretRotated(_newSecret);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Webhook signing secret successfully rotated!'),
                        backgroundColor: AppColors.emeraldGreen,
                      ),
                    );
                  }
                },
          icon: _isRotating
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.security, size: 16),
          label: Text(_isRotating ? 'Rotating...' : 'Confirm & Rotate Secret'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coralRed,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
