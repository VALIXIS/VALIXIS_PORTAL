/// In-memory stub implementation for non-web platforms (tests, CLI, mobile).
class AuthStorageHelper {
  static String? _memoryEmail;
  static bool _memoryRememberMe = true;

  static String? getRememberedEmail() => _memoryEmail;

  static void setRememberedEmail(String email) {
    _memoryEmail = email;
  }

  static void clearRememberedEmail() {
    _memoryEmail = null;
  }

  static bool getRememberMe() => _memoryRememberMe;

  static void setRememberMe(bool value) {
    _memoryRememberMe = value;
  }
}
