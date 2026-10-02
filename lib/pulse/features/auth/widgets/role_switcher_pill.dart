import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_role.dart';
import 'audit_vault_modal.dart';
import 'api_key_rotation_modal.dart';

class RoleSwitcherPill extends StatelessWidget {
  const RoleSwitcherPill({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRole = authProvider.currentRole;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Role Selector Dropdown Button
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: currentRole.roleColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: currentRole.roleColor.withOpacity(0.4), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: currentRole,
              dropdownColor: const Color(0xFF0D111A),
              icon: Icon(Icons.arrow_drop_down_rounded, color: currentRole.roleColor),
              items: UserRole.values.map((role) {
                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Row(
                    children: [
                      Icon(role.roleIcon, color: role.roleColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        role.label,
                        style: TextStyle(
                          color: role.roleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newRole) {
                if (newRole != null) {
                  authProvider.switchRole(newRole);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 8),

        // API Key Rotation Action Button
        IconButton(
          tooltip: 'Rotate Organization API Key (RBAC Protected)',
          icon: Icon(
            Icons.key_rounded,
            color: currentRole.canRotateApiKeys
                ? const Color(0xFF00E5FF)
                : const Color(0xFFFF5252).withOpacity(0.7),
            size: 20,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => const ApiKeyRotationModal(),
            );
          },
        ),

        // Audit Vault Logs Button
        IconButton(
          tooltip: 'Audit Vault Logs & Security Trail',
          icon: const Icon(Icons.shield_rounded, color: Color(0xFF00E5FF), size: 20),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => const AuditVaultModal(),
            );
          },
        ),
      ],
    );
  }
}
