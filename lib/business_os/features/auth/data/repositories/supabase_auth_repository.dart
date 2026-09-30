import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../../shared/models/app_user.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/auth_repository.dart';

/// Production Supabase authentication & organization repository.
class SupabaseAuthRepository implements AuthRepository {
  final sp.SupabaseClient _client;
  final _controller = StreamController<AuthState>.broadcast();
  StreamSubscription<sp.AuthState>? _authSubscription;
  AuthState _current = const AuthLoading(message: 'Restoring session...');

  SupabaseAuthRepository(this._client) {
    _initListener();
  }

  void _initListener() {
    _authSubscription = _client.auth.onAuthStateChange.listen(
      (data) async {
        final event = data.event;
        final session = data.session;

        debugPrint('Supabase Auth Event: $event, user: ${session?.user.id}');

        switch (event) {
          case sp.AuthChangeEvent.signedIn:
          case sp.AuthChangeEvent.tokenRefreshed:
          case sp.AuthChangeEvent.userUpdated:
          case sp.AuthChangeEvent.initialSession:
            if (session != null) {
              final authState = await _buildAuthenticatedState(session);
              _updateState(authState);
            } else {
              _updateState(const Unauthenticated());
            }
            break;
          case sp.AuthChangeEvent.signedOut:
            _updateState(const Unauthenticated());
            break;
          case sp.AuthChangeEvent.passwordRecovery:
          default:
            break;
        }
      },
      onError: (err) {
        debugPrint('Supabase auth state stream error: $err');
        _updateState(Unauthenticated(message: _humanizeError(err)));
      },
    );
  }

  void _updateState(AuthState state) {
    _current = state;
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  Future<AuthState> _buildAuthenticatedState(sp.Session session) async {
    final spUser = session.user;
    final fullName =
        (spUser.userMetadata?['full_name'] as String?) ??
        (spUser.email?.split('@').first ?? 'User');

    // 1. Check organization membership
    try {
      final memberRecord = await _client
          .from('organization_members')
          .select('organization_id, role, organizations(*)')
          .eq('user_id', spUser.id)
          .eq('is_active', true)
          .maybeSingle();

      if (memberRecord != null && memberRecord['organizations'] != null) {
        final orgMap = memberRecord['organizations'] as Map<String, dynamic>;
        final org = Organization.fromJson(orgMap);
        final role = memberRecord['role'] as String? ?? 'member';

        final appUser = AppUser(
          id: spUser.id,
          email: spUser.email ?? '',
          displayName: fullName,
          role: role,
          organizationId: org.id,
          organizationName: org.name,
        );

        return Authenticated(
          user: appUser,
          organization: org,
          sessionToken: session.accessToken,
        );
      }
    } catch (e) {
      debugPrint('Note: Error fetching organization membership: $e');
    }

    // Authenticated but no active organization -> requires onboarding!
    final unassignedUser = AppUser(
      id: spUser.id,
      email: spUser.email ?? '',
      displayName: fullName,
      role: 'owner',
      organizationId: null,
      organizationName: '',
    );

    return Authenticated(
      user: unassignedUser,
      organization: null,
      sessionToken: session.accessToken,
    );
  }

  @override
  AuthState get currentState => _current;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Future<AuthState> getInitialState() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      final state = await _buildAuthenticatedState(session);
      _current = state;
      return state;
    }
    _current = const Unauthenticated();
    return _current;
  }

  @override
  Future<void> restoreSession() async {
    _updateState(const AuthLoading(message: 'Restoring session...'));
    final session = _client.auth.currentSession;
    if (session != null) {
      final state = await _buildAuthenticatedState(session);
      _updateState(state);
    } else {
      _updateState(const Unauthenticated());
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _updateState(const AuthLoading(message: 'Signing in...'));
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final session = response.session;
      if (session != null) {
        final state = await _buildAuthenticatedState(session);
        _updateState(state);
      } else {
        _updateState(const Unauthenticated());
      }
    } catch (e) {
      final humanMsg = _humanizeError(e);
      _updateState(AuthError(humanMsg, previousState: const Unauthenticated()));
      rethrow;
    }
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _updateState(const AuthLoading(message: 'Creating account...'));
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final session = response.session;
      if (session != null) {
        final state = await _buildAuthenticatedState(session);
        _updateState(state);
      } else {
        // Confirmation email may be required by Supabase auth configuration
        _updateState(
          const Unauthenticated(
            message:
                'Account created. Please check your email to confirm your account before signing in.',
          ),
        );
      }
    } catch (e) {
      final humanMsg = _humanizeError(e);
      _updateState(AuthError(humanMsg, previousState: const Unauthenticated()));
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Note: Sign out notice: $e');
    } finally {
      _updateState(const Unauthenticated());
    }
  }

  @override
  Future<Organization> createOrganization({
    required String companyName,
    required String currency,
    required String timezone,
  }) async {
    final currentState = _current;
    if (currentState is! Authenticated) {
      throw Exception('Authentication required to create an organization');
    }

    _updateState(const AuthLoading(message: 'Creating workspace...'));

    try {
      // Generate URL-friendly unique slug from company name
      final clean = companyName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      final baseSlug = clean.isEmpty ? 'org' : clean;
      final uniqueSuffix = DateTime.now().millisecondsSinceEpoch.toRadixString(
        36,
      );
      final slug = '$baseSlug-$uniqueSuffix';

      // 1. Invoke atomic create_organization RPC matching database signature:
      // public.create_organization(p_name text, p_slug text, p_currency text, p_timezone text, p_logo_url text)
      final dynamic rpcResult = await _client.rpc(
        'create_organization',
        params: {
          'p_name': companyName.trim(),
          'p_slug': slug,
          'p_currency': currency.trim().toUpperCase(),
          'p_timezone': timezone.trim(),
        },
      );

      String? orgId;
      String? orgSlug;
      if (rpcResult is Map) {
        orgId = rpcResult['organization_id']?.toString();
        orgSlug = rpcResult['slug']?.toString();
      }

      if (orgId == null || orgId.isEmpty) {
        throw Exception('Server failed to return an organization ID.');
      }

      final organization = Organization(
        id: orgId,
        name: companyName,
        slug: orgSlug ?? companyName.toLowerCase().replaceAll(' ', '-'),
        currency: currency,
        timezone: timezone,
        createdAt: DateTime.now(),
      );

      final updatedUser = currentState.user.copyWith(
        organizationId: orgId,
        organizationName: companyName,
        role: 'owner',
      );

      final newState = Authenticated(
        user: updatedUser,
        organization: organization,
        sessionToken: currentState.sessionToken,
      );

      _updateState(newState);
      return organization;
    } catch (e) {
      final humanMsg = _humanizeError(e);
      _updateState(AuthError(humanMsg, previousState: currentState));
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(_humanizeError(e));
    }
  }

  String _humanizeError(dynamic err) {
    if (err is sp.AuthException) {
      final msg = err.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials')) {
        return 'Invalid email or password. Please try again.';
      } else if (msg.contains('already registered') ||
          msg.contains('already exists')) {
        return 'An account with this email address already exists.';
      } else if (msg.contains('password should be at least')) {
        return 'Password must be at least 8 characters long.';
      } else if (msg.contains('rate limit')) {
        return 'Too many login attempts. Please wait a moment and try again.';
      }
      return err.message;
    }
    final str = err.toString();
    if (str.contains('SocketException') || str.contains('Failed host lookup')) {
      return 'Network connection error. Please check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  void dispose() {
    _authSubscription?.cancel();
    _controller.close();
  }
}
