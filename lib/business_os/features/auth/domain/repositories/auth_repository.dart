import '../../../../shared/models/app_user.dart';
import '../entities/organization.dart';

/// Strongly typed authentication states for VALIXIS BUSINESS OS.
sealed class AuthState {
  const AuthState();

  bool get isLoading => this is AuthLoading;
  bool get isAuthenticated => this is Authenticated;
  bool get isUnauthenticated => this is Unauthenticated;
  bool get isError => this is AuthError;
}

/// Active session restoration or async operation loading state.
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthLoading && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

/// Explicit unauthenticated state.
class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unauthenticated && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

/// Fully authenticated user state.
class Authenticated extends AuthState {
  final AppUser user;
  final Organization? organization;
  final String? sessionToken;

  const Authenticated({
    required this.user,
    this.organization,
    this.sessionToken,
  });

  /// Determines whether the user must complete organization onboarding.
  bool get needsOnboarding => !user.hasOrganization;

  Authenticated copyWith({
    AppUser? user,
    Organization? organization,
    String? sessionToken,
  }) {
    return Authenticated(
      user: user ?? this.user,
      organization: organization ?? this.organization,
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authenticated &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          organization == other.organization &&
          sessionToken == other.sessionToken;

  @override
  int get hashCode =>
      user.hashCode ^ organization.hashCode ^ sessionToken.hashCode;
}

/// Explicit error state with user-facing message and optional prior state.
class AuthError extends AuthState {
  final String message;
  final AuthState? previousState;

  const AuthError(this.message, {this.previousState});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

/// Abstract contract for authentication and tenant repository layer.
abstract class AuthRepository {
  AuthState get currentState;
  Stream<AuthState> get authStateChanges;
  Future<AuthState> getInitialState();
  Future<void> restoreSession();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<Organization> createOrganization({
    required String companyName,
    required String currency,
    required String timezone,
  });
  Future<void> resetPassword(String email);
}
