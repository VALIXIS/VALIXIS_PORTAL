// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web implementation using window.sessionStorage.
String? getSessionItem(String key) {
  try {
    return html.window.sessionStorage[key];
  } catch (_) {
    return null;
  }
}

void setSessionItem(String key, String value) {
  try {
    html.window.sessionStorage[key] = value;
  } catch (_) {}
}

void removeSessionItem(String key) {
  try {
    html.window.sessionStorage.remove(key);
  } catch (_) {}
}
