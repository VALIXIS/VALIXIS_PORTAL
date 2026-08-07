import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/role_service.dart';
import 'auth_provider.dart';

final roleServiceProvider = Provider<RoleService>((ref) {
  return RoleService(ref.watch(supabaseClientProvider));
});

/// Riverpod provider delivering the current authenticated [UserRole].
/// Reactively watches [authNotifierProvider] to refresh role state on user sign in/out.
final roleProvider = FutureProvider<UserRole>((ref) async {
  final userAsync = ref.watch(authNotifierProvider);
  final user = userAsync.valueOrNull;

  if (user == null) {
    return UserRole.employee;
  }

  return ref.watch(roleServiceProvider).getUserRole(user.id);
});
