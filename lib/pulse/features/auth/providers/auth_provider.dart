import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/audit_entry.dart';
import '../services/rbac_service.dart';

class AuthProvider extends ChangeNotifier {
  final RbacService _rbacService;

  UserProfile _currentProfile = const UserProfile(
    id: 'usr_exec_01',
    email: 'executive@valixis.com',
    name: 'Jyothsna Sri (CEO / Executive)',
    organizationId: 'org_valixis_prod',
    role: UserRole.executive,
  );

  UserProfile get currentProfile => _currentProfile;
  UserRole get currentRole => _currentProfile.role;

  bool get isExecutive => _currentProfile.role.isExecutive;
  bool get isManager => _currentProfile.role.isManager;
  bool get isAuditor => _currentProfile.role.isAuditor;

  bool get canAccessArrForecasts => _currentProfile.role.canAccessArrForecasts;
  bool get canRotateApiKeys => _currentProfile.role.canRotateApiKeys;
  bool get hasAuditorWatermark => _currentProfile.role.hasAuditorWatermark;

  String? _lastRbacError;
  String? get lastRbacError => _lastRbacError;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  AuthProvider(this._rbacService);

  void switchRole(UserRole newRole) {
    _currentProfile = _currentProfile.copyWith(
      role: newRole,
      name: newRole == UserRole.executive
          ? 'Jyothsna Sri (CEO / Executive)'
          : (newRole == UserRole.manager
              ? 'Alex Morgan (Ops Manager)'
              : 'External Compliance Auditor'),
      email: newRole == UserRole.executive
          ? 'executive@valixis.com'
          : (newRole == UserRole.manager
              ? 'manager@valixis.com'
              : 'auditor@big4-compliance.com'),
    );
    _lastRbacError = null;
    notifyListeners();
  }

  List<AuditVaultEntry> getAuditLogs() => _rbacService.getAuditVaultLogs();

  Future<Map<String, dynamic>?> fetchExecutiveArrForecast() async {
    _isProcessing = true;
    _lastRbacError = null;
    notifyListeners();

    try {
      final res = await _rbacService.fetchArrForecastData(_currentProfile);
      _isProcessing = false;
      notifyListeners();
      return res;
    } on RbacException catch (e) {
      _lastRbacError = e.message;
      _isProcessing = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _lastRbacError = e.toString();
      _isProcessing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> rotateApiKey(String keyName) async {
    _isProcessing = true;
    _lastRbacError = null;
    notifyListeners();

    try {
      final res = await _rbacService.rotateApiKey(
        user: _currentProfile,
        keyName: keyName,
      );
      _isProcessing = false;
      notifyListeners();
      return res;
    } on RbacException catch (e) {
      _lastRbacError = e.message;
      _isProcessing = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _lastRbacError = e.toString();
      _isProcessing = false;
      notifyListeners();
      rethrow;
    }
  }
}
