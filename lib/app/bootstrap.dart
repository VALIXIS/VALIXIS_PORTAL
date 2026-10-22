import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/domain/role_service.dart';
import 'app.dart';

/// Application bootstrap function.
///
/// Initializes dotenv & Supabase and enforces role-specific session persistence rules:
/// - Page Refresh: Retains active session for ALL users (Managers & Employees).
/// - Tab/Chrome Closure:
///   - Managers (Subhash & Joshna / Manager role): Persistent session (NEVER logged out).
///   - Employees: Logged out when tab/browser is closed and reopened.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Structured Error & Crash Telemetry Handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[Observability/FlutterError] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[Observability/PlatformDispatcher] Unhandled async error: $error\n$stack');
    return true;
  };

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('[Portal Bootstrap] Notice: .env file not found, falling back to runtime environment.');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder.supabase.co');
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'placeholder-anon-key');

  await Supabase.initialize(
    url: supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: supabaseAnonKey,
  );

  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    try {
      final roleService = RoleService(Supabase.instance.client);
      final role = await roleService.getUserRole(currentUser.id, currentUser.email);

      if (role.isManager) {
        // Managers are NEVER logged out on tab close, browser restart, or refresh.
        SessionStorageService.setSessionActive();
        debugPrint('[Portal Auth] Authenticated as Manager (${currentUser.email}). Retaining persistent session.');
      } else {
        // Employee: Check if this session was preserved across a page refresh within the active tab.
        final isPageRefresh = SessionStorageService.isSessionActive();
        if (isPageRefresh) {
          // Page refresh within tab -> Stay logged in
          debugPrint('[Portal Auth] Page refreshed for Employee (${currentUser.email}). Retaining active session.');
        } else {
          // Tab or Chrome was closed -> Require new login for employee
          debugPrint('[Portal Auth] Tab/Browser closed for Employee (${currentUser.email}). Executing logout.');
          await Supabase.instance.client.auth.signOut();
        }
      }
    } catch (e) {
      debugPrint('[Portal Auth] Error evaluating session retention: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: ValixisApp(),
    ),
  );
}
