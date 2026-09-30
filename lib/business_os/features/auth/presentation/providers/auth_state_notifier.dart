import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../../shared/models/app_user.dart';
import '../../data/repositories/dev_auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/auth_repository.dart';

export '../../data/repositories/dev_auth_repository.dart';
export '../../data/repositories/supabase_auth_repository.dart';
export '../../domain/entities/organization.dart';
export '../../domain/repositories/auth_repository.dart';

/// Provider for the active AuthRepository (Supabase or Dev fallback).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      final repo = DevAuthRepository();
      ref.onDispose(() => repo.dispose());
      return repo;
    }
    final repo = SupabaseAuthRepository(client);
    ref.onDispose(() => repo.dispose());
    return repo;
  } catch (e) {
    debugPrint(
      'Supabase client unavailable, using DevAuthRepository fallback: $e',
    );
    final repo = DevAuthRepository();
    ref.onDispose(() => repo.dispose());
    return repo;
  }
});

/// Riverpod 2.x Primary Authentication & Tenant State Notifier.
class AuthStateNotifier extends ChangeNotifier {
  final AuthRepository _repository;
  AuthState _state;
  StreamSubscription<AuthState>? _subscription;

  AuthStateNotifier(this._repository) : _state = _repository.currentState {
    _subscription = _repository.authStateChanges.listen((newState) {
      _state = newState;
      notifyListeners();
    });
    if (_state is AuthLoading) {
      _init();
    }
  }

  AuthState get state => _state;

  AppUser? get currentUser {
    final s = _state;
    if (s is Authenticated) return s.user;
    return null;
  }

  Organization? get currentOrganization {
    final s = _state;
    if (s is Authenticated) return s.organization;
    return null;
  }

  bool get isAuthenticated => _state is Authenticated;

  bool get needsOnboarding {
    final s = _state;
    if (s is Authenticated) {
      return s.needsOnboarding;
    }
    return false;
  }

  Future<void> _init() async {
    final initial = await _repository.getInitialState();
    if (_state is AuthLoading) {
      _state = initial;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    try {
      await _repository.restoreSession();
    } finally {
      _state = _repository.currentState;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _repository.signIn(email: email, password: password);
    } finally {
      _state = _repository.currentState;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    } finally {
      _state = _repository.currentState;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _repository.signOut();
    } finally {
      _state = _repository.currentState;
      notifyListeners();
    }
  }

  Future<void> signOut() => logout();
  Future<void> signIn({required String email, required String password}) =>
      login(email: email, password: password);

  Future<Organization> createOrganization({
    required String companyName,
    required String currency,
    required String timezone,
  }) async {
    try {
      final org = await _repository.createOrganization(
        companyName: companyName,
        currency: currency,
        timezone: timezone,
      );
      return org;
    } finally {
      _state = _repository.currentState;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  // Alias for backward compatibility
  Future<void> signInWithDemo({bool hasOrganization = true}) async {
    final repo = _repository;
    if (repo is DevAuthRepository) {
      await repo.signIn(
        email: hasOrganization ? 'admin@valixis.io' : 'newuser@valixis.io',
        password: 'password123',
      );
    } else {
      try {
        await _repository.signIn(
          email: 'admin@valixis.io',
          password: 'password123',
        );
      } catch (_) {
        _state = Authenticated(
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
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider exposing the AuthStateNotifier.
final authNotifierProvider = ChangeNotifierProvider<AuthStateNotifier>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});

/// Provider exposing the current immutable AuthState.
final authStateProvider = Provider<AuthState>((ref) {
  final notifier = ref.watch(authNotifierProvider);
  return notifier.state;
});

/// Provider exposing the current authenticated AppUser or null.
final currentUserProvider = Provider<AppUser?>((ref) {
  final notifier = ref.watch(authNotifierProvider);
  return notifier.currentUser;
});

/// Provider exposing the current active Organization or null.
final currentOrganizationProvider = Provider<Organization?>((ref) {
  final notifier = ref.watch(authNotifierProvider);
  return notifier.currentOrganization;
});
