import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/user_role.dart';
import '../models/audit_entry.dart';

class RbacService {
  final List<AuditVaultEntry> _mockAuditVault = [];

  RbacService() {
    _seedMockAuditVault();
  }

  void _seedMockAuditVault() {
    final now = DateTime.now();
    _mockAuditVault.addAll([
      AuditVaultEntry(
        id: 'aud_101',
        organizationId: 'org_valixis_prod',
        userId: 'usr_exec_01',
        role: 'executive',
        action: 'FETCH_ARR_FORECASTS',
        resource: 'arr_forecasts',
        accessGranted: true,
        metadata: {'forecast_type': 'arr_12m', 'confidence': 0.98},
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      AuditVaultEntry(
        id: 'aud_102',
        organizationId: 'org_valixis_prod',
        userId: 'usr_mgr_02',
        role: 'manager',
        action: 'DISPATCH_SELF_HEALING',
        resource: 'flow/webhooks/remediation',
        accessGranted: true,
        metadata: {'incident_id': 'anom_101'},
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  List<AuditVaultEntry> getAuditVaultLogs() => List.unmodifiable(_mockAuditVault);

  /// Verifies access to ARR Forecasts.
  /// Throws [RbacException] if user is not Executive.
  Future<Map<String, dynamic>> fetchArrForecastData(UserProfile user) async {
    if (!user.role.canAccessArrForecasts) {
      final deniedEntry = AuditVaultEntry(
        id: 'aud_${const Uuid().v4().substring(0, 8)}',
        organizationId: user.organizationId,
        userId: user.id,
        role: user.role.code,
        action: 'FETCH_ARR_FORECAST_ATTEMPT',
        resource: 'arr_forecasts',
        accessGranted: false,
        metadata: {
          'error': 'UNAUTHORIZED: Executive role required to view ARR forecasts.',
          'attempted_by': user.email,
        },
        createdAt: DateTime.now(),
      );
      _mockAuditVault.insert(0, deniedEntry);

      throw RbacException(
        'UNAUTHORIZED: User with role "${user.role.label}" is denied access to executive ARR forecasts.',
        errorCode: 'ERR_RBAC_DENIED_ARR_FORECAST',
      );
    }

    final successEntry = AuditVaultEntry(
      id: 'aud_${const Uuid().v4().substring(0, 8)}',
      organizationId: user.organizationId,
      userId: user.id,
      role: user.role.code,
      action: 'FETCH_ARR_FORECAST_SUCCESS',
      resource: 'arr_forecasts',
      accessGranted: true,
      metadata: {'granted_to': user.email},
      createdAt: DateTime.now(),
    );
    _mockAuditVault.insert(0, successEntry);

    return {
      'organization_id': user.organizationId,
      'predicted_arr_usd': 14850000.00,
      'confidence_score': 97.5,
      'cashflow_30d': 1250000.00,
      'status': 'AUTHORIZED',
    };
  }

  /// Rotates API key with strict RBAC checking.
  /// Throws [RbacException] if user is not Executive.
  Future<Map<String, dynamic>> rotateApiKey({
    required UserProfile user,
    required String keyName,
  }) async {
    if (!user.role.canRotateApiKeys) {
      final violationEntry = AuditVaultEntry(
        id: 'aud_${const Uuid().v4().substring(0, 8)}',
        organizationId: user.organizationId,
        userId: user.id,
        role: user.role.code,
        action: 'ROTATE_API_KEY_ATTEMPT',
        resource: 'api_keys/$keyName',
        accessGranted: false,
        metadata: {
          'error': 'SECURITY VIOLATION: Manager/Auditor role cannot rotate API keys.',
          'attempted_by': user.email,
          'key_name': keyName,
        },
        createdAt: DateTime.now(),
      );
      _mockAuditVault.insert(0, violationEntry);

      throw RbacException(
        'UNAUTHORIZED: Only Executive role can rotate API keys.',
        errorCode: 'ERR_RBAC_DENIED_KEY_ROTATION',
      );
    }

    final newToken = 'vlx_live_${const Uuid().v4().replaceAll('-', '')}';

    final successEntry = AuditVaultEntry(
      id: 'aud_${const Uuid().v4().substring(0, 8)}',
      organizationId: user.organizationId,
      userId: user.id,
      role: user.role.code,
      action: 'ROTATE_API_KEY_SUCCESS',
      resource: 'api_keys/$keyName',
      accessGranted: true,
      metadata: {
        'key_name': keyName,
        'token_prefix': '${newToken.substring(0, 12)}...',
        'rotated_by': user.email,
      },
      createdAt: DateTime.now(),
    );
    _mockAuditVault.insert(0, successEntry);

    return {
      'status': 'SUCCESS',
      'key_name': keyName,
      'new_api_key': newToken,
      'rotated_at': DateTime.now().toIso8601String(),
    };
  }
}
