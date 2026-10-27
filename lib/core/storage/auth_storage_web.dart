// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation utilizing browser `window.localStorage` to remember
/// the employee's work email and autofill preference across sessions and tab closures.
class AuthStorageHelper {
  static const String _emailKey = 'valixis_remembered_email';
  static const String _rememberMeKey = 'valixis_remember_me';

  static String? getRememberedEmail() {
    try {
      final email = html.window.localStorage[_emailKey];
      return (email != null && email.trim().isNotEmpty) ? email.trim() : null;
    } catch (_) {
      return null;
    }
  }

  static void setRememberedEmail(String email) {
    try {
      html.window.localStorage[_emailKey] = email.trim();
    } catch (_) {}
  }

  static void clearRememberedEmail() {
    try {
      html.window.localStorage.remove(_emailKey);
    } catch (_) {}
  }

  static bool getRememberMe() {
    try {
      final val = html.window.localStorage[_rememberMeKey];
      return val != 'false'; // Default to true for employee convenience
    } catch (_) {
      return true;
    }
  }

  static void setRememberMe(bool value) {
    try {
      html.window.localStorage[_rememberMeKey] = value.toString();
    } catch (_) {}
  }
}
