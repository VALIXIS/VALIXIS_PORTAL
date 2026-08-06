import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPreferences {
  const UserPreferences({
    this.isCompactMode = false,
    this.enableAnimations = true,
    this.notificationsEnabled = true,
    this.highContrastMode = false,
  });

  final bool isCompactMode;
  final bool enableAnimations;
  final bool notificationsEnabled;
  final bool highContrastMode;

  UserPreferences copyWith({
    bool? isCompactMode,
    bool? enableAnimations,
    bool? notificationsEnabled,
    bool? highContrastMode,
  }) {
    return UserPreferences(
      isCompactMode: isCompactMode ?? this.isCompactMode,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(const UserPreferences());

  void toggleCompactMode() {
    state = state.copyWith(isCompactMode: !state.isCompactMode);
  }

  void toggleAnimations() {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void toggleHighContrast() {
    state = state.copyWith(highContrastMode: !state.highContrastMode);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});
