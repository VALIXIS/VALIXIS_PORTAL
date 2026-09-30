// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation utilizing browser `window.sessionStorage`.
/// `sessionStorage` automatically persists across page reloads/refreshes within the same tab,
/// but is cleared immediately when the tab or browser window is closed.
class SessionStorageHelper {
  static const String _key = 'valixis_session_active';

  static bool isSessionActive() {
    try {
      return html.window.sessionStorage[_key] == 'true';
    } catch (_) {
      return false;
    }
  }

  static void setSessionActive() {
    try {
      html.window.sessionStorage[_key] = 'true';
    } catch (_) {}
  }

  static void clearSessionActive() {
    try {
      html.window.sessionStorage.remove(_key);
    } catch (_) {}
  }
}
