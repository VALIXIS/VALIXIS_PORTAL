import 'dart:async';
import '../../../../shared/models/app_user.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory development repository for local verification and mock environments.
class DevAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthState>.broadcast();
  AuthState _current;

  DevAuthRepository({AuthState? initialState})
    : _current =
          initialState ??
          Authenticated(
            user: AppUser.devAdmin(),
            organization: const Organization(
              id: 'org_dev_001',
              name: 'VALIXIS Global Enterprise',
              slug: 'valixis-global',
              currency: 'USD',
              timezone: 'UTC',
            ),
            sessionToken: 'mock_jwt_token_123',
          );

  @override
  AuthState get currentState => _current;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Future<AuthState> getInitialState() async => _current;

  @override
  Future<void> restoreSession() async {
    final target = _current is AuthLoading ? const Unauthenticated() : _current;
    _updateState(const AuthLoading(message: 'Restoring session...'));
    await Future.delayed(const Duration(milliseconds: 50));
    _updateState(target);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _updateState(const AuthLoading(message: 'Signing in...'));
    await Future.delayed(const Duration(milliseconds: 150));

    if (email.contains('error')) {
      const err = AuthError(
        'Invalid email or password. Please try again.',
        previousState: Unauthenticated(),
      );
      _updateState(err);
      throw Exception('Invalid credentials');
    }

    final hasOrg = !email.contains('newuser');
    final user = AppUser(
      id: 'usr_dev_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first.toUpperCase(),
      role: 'owner',
      organizationId: hasOrg ? 'org_dev_001' : null,
      organizationName: hasOrg ? 'VALIXIS Global Enterprise' : '',
    );

    final org = hasOrg
        ? const Organization(
            id: 'org_dev_001',
            name: 'VALIXIS Global Enterprise',
            slug: 'valixis-global',
            currency: 'USD',
            timezone: 'UTC',
          )
        : null;

    final newState = Authenticated(
      user: user,
      organization: org,
      sessionToken: 'dev_token',
    );

    _updateState(newState);
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _updateState(const AuthLoading(message: 'Creating account...'));
    await Future.delayed(const Duration(milliseconds: 150));

    if (email.contains('taken')) {
      const err = AuthError(
        'An account with this email address already exists.',
        previousState: Unauthenticated(),
      );
      _updateState(err);
      throw Exception('Email already exists');
    }

    // New signups start without an organization -> triggering onboarding wizard
    final user = AppUser(
      id: 'usr_dev_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: fullName,
      role: 'owner',
      organizationId: null,
      organizationName: '',
    );

    final newState = Authenticated(
      user: user,
      organization: null,
      sessionToken: 'dev_token',
    );

    _updateState(newState);
  }

  @override
  Future<void> signOut() async {
    _updateState(const Unauthenticated());
  }

  @override
  Future<Organization> createOrganization({
    required String companyName,
    required String currency,
    required String timezone,
  }) async {
    final curr = _current;
    if (curr is! Authenticated) {
      throw Exception('Authentication required');
    }

    _updateState(const AuthLoading(message: 'Creating workspace...'));
    await Future.delayed(const Duration(milliseconds: 150));

    final org = Organization(
      id: 'org_${DateTime.now().millisecondsSinceEpoch}',
      name: companyName,
      slug: companyName.toLowerCase().replaceAll(' ', '-'),
      currency: currency,
      timezone: timezone,
      createdAt: DateTime.now(),
    );

    final updatedUser = curr.user.copyWith(
      organizationId: org.id,
      organizationName: org.name,
      role: 'owner',
    );

    final newState = Authenticated(
      user: updatedUser,
      organization: org,
      sessionToken: curr.sessionToken,
    );

    _updateState(newState);
    return org;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _updateState(AuthState state) {
    _current = state;
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  void dispose() {
    _controller.close();
  }
}
