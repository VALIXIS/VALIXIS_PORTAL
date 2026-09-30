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

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }

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
