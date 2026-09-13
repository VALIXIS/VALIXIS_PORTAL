import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/components/valixis_command_core_3d.dart';

/// Executive Command Center Hero Banner featuring the 3D VALIXIS Core & Telemetry.
class ManagerHeroHeader extends StatelessWidget {
  const ManagerHeroHeader({super.key});

  String get _formattedDate {
    return DateFormatter.formatShortDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return GlassCard(
      showGlow: true,
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // System Status Pill & Role
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.brandCyan.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.brandCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'SYSTEM ONLINE',
                                style: AppTypography.telemetryHeader(
                                  size: 9,
                                  color: AppColors.brandCyan,
                                  spacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.brandPurple.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'MANAGER',
                            style: AppTypography.telemetryHeader(
                              size: 9,
                              color: AppColors.brandPurple,
                              spacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Title
                    Text(
                      'Manager Overview',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Timestamp & Description
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formattedDate,
                          style: AppTypography.mono(
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Text(
                            'Manage tasks, team activity, reviews, and project progress.',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3D Interactive VALIXIS Command Core
              if (isDesktop) ...[
                const SizedBox(width: AppSpacing.lg),
                const ValixisCommandCore3D(
                  size: 100,
                  systemState: CoreSystemState.nominal,
                  enableParallax: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

