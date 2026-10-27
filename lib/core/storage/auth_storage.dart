import 'auth_storage_stub.dart'
    if (dart.library.html) 'auth_storage_web.dart';

/// Cross-platform service managing remembered employee credentials and autofill state.
class AuthStorageService {
  /// Retrieves the last successfully authenticated employee work email.
  static String? getRememberedEmail() => AuthStorageHelper.getRememberedEmail();

  /// Persists the employee work email for 1-click autofill.
  static void setRememberedEmail(String email) =>
      AuthStorageHelper.setRememberedEmail(email);

  /// Clears the remembered email.
  static void clearRememberedEmail() =>
      AuthStorageHelper.clearRememberedEmail();

  /// Whether the "Remember Email" toggle is active.
  static bool getRememberMe() => AuthStorageHelper.getRememberMe();

  /// Saves the "Remember Email" toggle state.
  static void setRememberMe(bool value) =>
      AuthStorageHelper.setRememberMe(value);
}
