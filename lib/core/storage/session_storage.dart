import 'session_storage_stub.dart'
    if (dart.library.html) 'session_storage_web.dart';

/// Service managing tab-scoped session state for distinguishing page reloads from browser/tab closure.
class SessionStorageService {
  static bool isSessionActive() => SessionStorageHelper.isSessionActive();
  static void setSessionActive() => SessionStorageHelper.setSessionActive();
  static void clearSessionActive() => SessionStorageHelper.clearSessionActive();
}
