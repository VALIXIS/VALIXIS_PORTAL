import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/storage/session_storage.dart';
import '../../data/auth_repository.dart';
import 'heartbeat_provider.dart';
import 'role_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../employee/presentation/providers/employee_provider.dart';
import '../../../manager/presentation/providers/audit_logs_provider.dart';
import '../../../manager/presentation/providers/employee_management_provider.dart';
import '../../../manager/presentation/providers/manager_dashboard_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

/// Stream provider listening to raw Supabase auth state changes.
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

/// Notifier managing current user state, login, and logout execution.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref, ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._ref, this._repository)
      : super(AsyncValue.data(_repository.currentUser)) {
    _authSubscription = _repository.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.tokenRefreshed ||
          data.event == AuthChangeEvent.userUpdated) {
        state = AsyncValue.data(data.session?.user);
        _invalidateUserProviders();
      } else if (data.event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
        _invalidateUserProviders();
      }
    });
  }

  final Ref _ref;
  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  void _invalidateUserProviders() {
    _ref.invalidate(roleProvider);
    _ref.invalidate(employeeProvider);
    _ref.invalidate(tasksProvider);
    _ref.invalidate(managerDashboardProvider);
    _ref.invalidate(employeeManagementProvider);
    _ref.invalidate(dashboardProvider);
    _ref.invalidate(auditLogsProvider);
  }

  /// Executes user sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );
      _invalidateUserProviders();

      if (response.user != null) {
        SessionStorageService.setSessionActive();
        try {
          final supabase = _ref.read(supabaseClientProvider);
          final userEmail = response.user!.email?.trim().toLowerCase() ?? email.trim().toLowerCase();
          String actorName = 'User';
          String? empId;

          if (userEmail == 'official.valixis@gmail.com') {
            actorName = 'Subhash';
          } else if (userEmail == 'jyothsna@valixis.com') {
            actorName = 'Jyothsna';
          } else {
            try {
              final empRes = await supabase
                  .from('employees')
                  .select('id, name, full_name, email')
                  .eq('auth_id', response.user!.id)
                  .maybeSingle();
              if (empRes != null) {
                empId = empRes['id']?.toString();
                final nameStr = (empRes['name'] as String? ?? empRes['full_name'] as String? ?? '').trim();
                if (nameStr.isNotEmpty) {
                  actorName = nameStr;
                } else {
                  actorName = userEmail.split('@').first;
                }
              } else {
                actorName = userEmail.isNotEmpty ? userEmail.split('@').first : 'User';
              }
            } catch (_) {
              actorName = userEmail.isNotEmpty ? userEmail.split('@').first : 'User';
            }
          }

          final nowUtc = DateTime.now().toUtc().toIso8601String();
          final res = await supabase.from('audit_logs').insert({
            'actor': actorName,
            if (empId != null && empId.isNotEmpty) 'actor_id': empId,
            'action': 'Login',
            'category': 'Authentication',
            'status': 'Success',
            'ip_address': kIsWeb ? 'Web Client' : 'Mobile Client',
            'timestamp': nowUtc,
            'last_seen': nowUtc,
          }).select('id').single();

          final logId = res['id']?.toString();
          if (logId != null && logId.isNotEmpty) {
            _ref.read(heartbeatProvider).startNewSession(logId);
          }
        } catch (e) {
          debugPrint('[Audit Log] Failed to insert login audit record: $e');
        }
      }

      return response.user;
    });
  }

  /// Executes user sign out and session clearing.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = _repository.currentUser;
      if (user != null) {
        try {
          final supabase = _ref.read(supabaseClientProvider);
          final userEmail = user.email?.trim().toLowerCase() ?? '';
          String actorName = 'User';
          String? empId;

          if (userEmail == 'official.valixis@gmail.com') {
            actorName = 'Subhash';
          } else if (userEmail == 'jyothsna@valixis.com') {
            actorName = 'Jyothsna';
          } else {
            try {
              final empRes = await supabase
                  .from('employees')
                  .select('id, name, full_name, email')
                  .eq('auth_id', user.id)
                  .maybeSingle();
              if (empRes != null) {
                empId = empRes['id']?.toString();
                final nameStr = (empRes['name'] as String? ?? empRes['full_name'] as String? ?? '').trim();
                if (nameStr.isNotEmpty) {
                  actorName = nameStr;
                } else {
                  actorName = userEmail.split('@').first;
                }
              } else {
                actorName = userEmail.isNotEmpty ? userEmail.split('@').first : 'User';
              }
            } catch (_) {
              actorName = userEmail.isNotEmpty ? userEmail.split('@').first : 'User';
            }
          }

          final nowUtc = DateTime.now().toUtc().toIso8601String();
          await supabase.from('audit_logs').insert({
            'actor': actorName,
            if (empId != null && empId.isNotEmpty) 'actor_id': empId,
            'action': 'Logout',
            'category': 'Authentication',
            'status': 'Success',
            'ip_address': kIsWeb ? 'Web Client' : 'Mobile Client',
            'timestamp': nowUtc,
            'last_seen': nowUtc,
          });
        } catch (e) {
          debugPrint('[Audit Log] Failed to insert logout audit record: $e');
        }
      }

      _ref.read(heartbeatProvider).stop();
      SessionStorageService.clearSessionActive();
      await _repository.signOut();
      _invalidateUserProviders();
      return null;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
