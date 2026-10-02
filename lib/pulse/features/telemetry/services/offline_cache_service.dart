import 'dart:convert';
import '../models/dashboard_cache_payload.dart';

class OfflineCacheService {
  String? _inMemoryCacheJson;
  DashboardCachePayload? _cachedPayload;

  /// Caches the active dashboard payload in local storage.
  Future<bool> saveDashboardCache(DashboardCachePayload payload) async {
    try {
      _cachedPayload = payload;
      _inMemoryCacheJson = jsonEncode(payload.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the cached dashboard state.
  Future<DashboardCachePayload?> getDashboardCache() async {
    if (_cachedPayload != null) {
      return _cachedPayload;
    }

    if (_inMemoryCacheJson != null) {
      try {
        final decoded = jsonDecode(_inMemoryCacheJson!) as Map<String, dynamic>;
        _cachedPayload = DashboardCachePayload.fromJson(decoded);
        return _cachedPayload;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Clears the local fallback cache.
  Future<void> clearCache() async {
    _cachedPayload = null;
    _inMemoryCacheJson = null;
  }
}
