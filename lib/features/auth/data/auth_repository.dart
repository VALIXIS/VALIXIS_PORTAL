import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client_provider.dart';

/// Riverpod provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

/// Repository handling authentication operations via Supabase.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Current authenticated user, or null if unauthenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Current auth session, or null if expired/unauthenticated.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of authentication state changes.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Signs in a user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user and clears session storage.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
