import 'package:flutter/material.dart';

enum SimulationScenarioType {
  normalDay('normal_day', 'Normal Operational Day'),
  blackFridaySurge('black_friday_surge', 'Black Friday Traffic Surge'),
  stripeOutage('stripe_outage', 'Stripe Payment Gateway Outage'),
  conversionCrash('conversion_crash', 'CRM Conversion Rate Crash');

  final String code;
  final String label;

  const SimulationScenarioType(this.code, this.label);

  static SimulationScenarioType fromCode(String code) {
    return SimulationScenarioType.values.firstWhere(
      (s) => s.code == code,
      orElse: () => SimulationScenarioType.normalDay,
    );
  }
}

class SimulationScenario {
  final SimulationScenarioType type;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final double targetArrUsd;
  final int targetActiveUsers;
  final double targetChurnRisk;
  final int targetLatencyMs;
  final double targetConversionRate;
  final String statusHealth;
  final String? anomalyTitle;
  final String? anomalySeverity;
  final String? anomalySource;
  final int defaultEventRate; // events per second

  const SimulationScenario({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.targetArrUsd,
    required this.targetActiveUsers,
    required this.targetChurnRisk,
    required this.targetLatencyMs,
    required this.targetConversionRate,
    required this.statusHealth,
    this.anomalyTitle,
    this.anomalySeverity,
    this.anomalySource,
    this.defaultEventRate = 100,
  });

  static const SimulationScenario normalDay = SimulationScenario(
    type: SimulationScenarioType.normalDay,
    title: 'Normal Operational Day',
    description: 'Steady baseline traffic across CRM, VALIXIS Flow, and payment webhooks.',
    icon: Icons.check_circle_outline_rounded,
    accentColor: Color(0xFF00E676), // Emerald
    targetArrUsd: 1250000.0,
    targetActiveUsers: 4850,
    targetChurnRisk: 3.2,
    targetLatencyMs: 18,
    targetConversionRate: 28.4,
    statusHealth: 'optimal',
    defaultEventRate: 50,
  );

  static const SimulationScenario blackFridaySurge = SimulationScenario(
    type: SimulationScenarioType.blackFridaySurge,
    title: 'Black Friday Traffic Surge',
    description: 'Massive +450% surge in checkout automations and concurrent telemetry events.',
    icon: Icons.bolt_rounded,
    accentColor: Color(0xFF00E5FF), // Electric Cyan
    targetArrUsd: 5850000.0,
    targetActiveUsers: 28400,
    targetChurnRisk: 1.8,
    targetLatencyMs: 42,
    targetConversionRate: 41.2,
    statusHealth: 'growth',
    defaultEventRate: 500,
  );

  static const SimulationScenario stripeOutage = SimulationScenario(
    type: SimulationScenarioType.stripeOutage,
    title: 'Stripe Payment Gateway Outage',
    description: 'Stripe API webhook timeouts (98% failure rate) and sudden revenue stall.',
    icon: Icons.credit_card_off_rounded,
    accentColor: Color(0xFFFF5252), // Coral Red
    targetArrUsd: 1250000.0,
    targetActiveUsers: 3100,
    targetChurnRisk: 18.5,
    targetLatencyMs: 480,
    targetConversionRate: 4.2,
    statusHealth: 'critical',
    anomalyTitle: 'Stripe Payment Gateway Webhook Timeout (98.4% Failures)',
    anomalySeverity: 'critical',
    anomalySource: 'Stripe Gateway',
    defaultEventRate: 250,
  );

  static const SimulationScenario conversionCrash = SimulationScenario(
    type: SimulationScenarioType.conversionCrash,
    title: 'CRM Conversion Rate Crash',
    description: 'Sudden conversion dropoff due to broken checkout funnel script.',
    icon: Icons.trending_down_rounded,
    accentColor: Color(0xFFFFB74D), // Amber Warning
    targetArrUsd: 980000.0,
    targetActiveUsers: 2400,
    targetChurnRisk: 12.4,
    targetLatencyMs: 85,
    targetConversionRate: 2.1,
    statusHealth: 'critical',
    anomalyTitle: 'CRM Checkout Funnel Abandonment Spike (Conversion Crash to 2.1%)',
    anomalySeverity: 'high',
    anomalySource: 'VALIXIS CRM',
    defaultEventRate: 150,
  );

  static List<SimulationScenario> get allScenarios => [
        normalDay,
        blackFridaySurge,
        stripeOutage,
        conversionCrash,
      ];
}
