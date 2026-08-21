import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/auth_repository.dart';
import 'heartbeat_provider.dart';
import 'role_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../manager/presentation/providers/employee_management_provider.dart';
import '../../../manager/presentation/providers/manager_dashboard_provider.dart';

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
    _ref.invalidate(managerDashboardProvider);
    _ref.invalidate(employeeManagementProvider);
    _ref.invalidate(dashboardProvider);
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
        try {
          final supabase = _ref.read(supabaseClientProvider);
          String? empId;
          try {
            final empRes = await supabase
                .from('employees')
                .select('id')
                .eq('auth_id', response.user!.id)
                .maybeSingle();
            if (empRes != null) {
              empId = empRes['id']?.toString();
            }
          } catch (_) {}

          final res = await supabase.from('audit_logs').insert({
            if (empId != null && empId.isNotEmpty) 'actor_id': empId,
            'action': 'Login',
            'category': 'Authentication',
            'status': 'Success',
            'ip_address': kIsWeb ? 'Web Client' : 'Mobile Client',
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
      _ref.read(heartbeatProvider).stop();
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
