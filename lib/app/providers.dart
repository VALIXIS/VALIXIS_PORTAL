import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top-level Riverpod providers that are not feature-specific.
///
/// Feature providers live within their respective feature directories.
/// Add global infrastructure providers here (e.g., theme mode, locale).

/// Current theme mode provider.
final themeModeProvider = StateProvider<ThemeMode>(
  (_) => ThemeMode.dark,
);
