import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flow_analytics_model.dart';

class AnalyticsState {
  final FlowAnalytics analytics;
  final bool isLoading;
  final String? errorMessage;
  final int selectedDays;

  const AnalyticsState({
    required this.analytics,
    this.isLoading = false,
    this.errorMessage,
    this.selectedDays = 7,
  });

  AnalyticsState copyWith({
    FlowAnalytics? analytics,
    bool? isLoading,
    String? errorMessage,
    int? selectedDays,
  }) {
    return AnalyticsState(
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier()
      : super(
          AnalyticsState(
            analytics: FlowAnalytics.empty(),
          ),
        );

  Future<void> setDays(int days) async {
    state = state.copyWith(isLoading: true, selectedDays: days);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = state.copyWith(
      isLoading: false,
      analytics: FlowAnalytics.empty(),
    );
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
