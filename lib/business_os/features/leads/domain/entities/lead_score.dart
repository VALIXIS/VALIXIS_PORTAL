import 'package:flutter/foundation.dart';

/// Purchase intent classification determined by the Gemini Lead Quality Scoring Engine.
enum LeadIntent {
  high('high', 'HIGH'),
  med('med', 'MED'),
  low('low', 'LOW');

  final String value;
  final String label;

  const LeadIntent(this.value, this.label);

  /// Safe deserializer accepting standard values and common casing variations.
  static LeadIntent fromString(String? value) {
    if (value == null) return LeadIntent.low;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'high') return LeadIntent.high;
    if (normalized == 'med' || normalized == 'medium') return LeadIntent.med;
    return LeadIntent.low;
  }
}

/// Strongly typed result container for AI lead scoring output.
@immutable
class LeadScore {
  final int score;
  final LeadIntent intent;
  final String action;

  const LeadScore({
    required this.score,
    required this.intent,
    required this.action,
  });

  /// Factory parser for structured JSON output from `ai-lead-scorer`.
  factory LeadScore.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'];
    final int parsedScore;
    if (rawScore is num) {
      parsedScore = rawScore.toInt().clamp(0, 100);
    } else {
      parsedScore =
          int.tryParse(rawScore?.toString() ?? '0')?.clamp(0, 100) ?? 0;
    }

    final rawIntent = json['intent']?.toString();
    final intent = LeadIntent.fromString(rawIntent);

    final action = json['action']?.toString().trim() ?? '';
    if (action.isEmpty) {
      throw const FormatException('Missing or empty action recommendation');
    }

    return LeadScore(score: parsedScore, intent: intent, action: action);
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'intent': intent.value,
    'action': action,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadScore &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          intent == other.intent &&
          action == other.action;

  @override
  int get hashCode => score.hashCode ^ intent.hashCode ^ action.hashCode;

  @override
  String toString() =>
      'LeadScore(score: $score, intent: ${intent.label}, action: $action)';
}
