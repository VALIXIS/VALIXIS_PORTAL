import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/auth_repository.dart';
import '../../domain/role_service.dart';

final roleServiceProvider = Provider<RoleService>((ref) {
  return RoleService(ref.watch(supabaseClientProvider));
});

/// Riverpod provider delivering the current authenticated [UserRole].
final roleProvider = FutureProvider<UserRole>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return UserRole.employee;
  return ref.watch(roleServiceProvider).getUserRole(user.id);
});
