import 'package:flutter/material.dart';
import '../../../core/theme/pulse_theme.dart';

class ChurnRadarWidget extends StatelessWidget {
  final Map<String, dynamic> churnData;

  const ChurnRadarWidget({
    super.key,
    required this.churnData,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> accounts = churnData['at_risk_accounts'] ?? [];
    final double overallRisk =
        (churnData['overall_churn_risk_pct'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PulseColors.cardObsidian.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PulseColors.cardGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, color: PulseColors.coralRedAlert, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'CUSTOMER CHURN RISK RADAR',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: PulseColors.textSecondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PulseColors.coralRedAlert.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: PulseColors.coralRedAlert, width: 1),
                ),
                child: Text(
                  'AGGREGATE CHURN RISK: ${overallRisk.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PulseColors.coralRedAlert,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No high-risk customer churn signals detected.',
                style: TextStyle(color: PulseColors.textMuted),
              ),
            )
          else
            Column(
              children: accounts.map((acc) {
                final company = acc['company_name'] ?? 'Target Account';
                final arrExposure =
                    (acc['arr_exposure'] as num?)?.toDouble() ?? 0.0;
                final probability =
                    (acc['churn_probability'] as num?)?.toDouble() ?? 0.0;
                final List<dynamic> factors = acc['risk_factors'] ?? [];
                final playbook = acc['recommended_playbook'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PulseColors.surfaceObsidian,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PulseColors.cardGlassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 6,
                        spacing: 8,
                        children: [
                          Text(
                            company,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: PulseColors.textPrimary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${(arrExposure / 1000).toStringAsFixed(0)}k ARR',
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 12,
                                  color: PulseColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: PulseColors.coralRedAlert
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${probability.toStringAsFixed(0)}% CHURN RISK',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: PulseColors.coralRedAlert,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Risk Factors: ${factors.join(" • ")}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: PulseColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: PulseColors.emeraldGrowth, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Playbook: $playbook',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: PulseColors.emeraldGrowth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
