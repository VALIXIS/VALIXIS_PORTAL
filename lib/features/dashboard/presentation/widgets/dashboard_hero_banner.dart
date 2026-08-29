import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/employee.dart';

/// Motivational quotes array for developer inspiration.
const _motivationalQuotes = [
  '“Clean code always looks like it was written by someone who cares.” — Robert C. Martin',
  '“Simplicity is prerequisite for reliability.” — Edsger W. Dijkstra',
  '“First, solve the problem. Then, write the code.” — John Johnson',
  '“Small daily commits lead to massive product breakthroughs.” — VALIXIS Engineering',
  '“Make it work, make it right, make it fast.” — Kent Beck',
];

/// Hero header widget displaying dynamic greeting, motivational mindset quote, and developer badges.
class DashboardHeroBanner extends StatelessWidget {
  const DashboardHeroBanner({super.key, required this.employee});

  final Employee employee;

  String get _greetingData {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ⚡';
    return 'Good evening 🌙';
  }

  String get _subGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Ready to build the future today?';
    if (hour < 17) return 'You are on a roll!';
    return 'Finishing strong today.';
  }

  String get _formattedDate {
    final now = DateTime.now();
    return DateFormatter.formatShortDate(now);
  }

  String get _dailyQuote {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _motivationalQuotes[dayOfYear % _motivationalQuotes.length];
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Text(
                    employee.fullName.isNotEmpty
                        ? employee.fullName[0].toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$_greetingData, ',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            employee.fullName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subGreeting,
                      style: const TextStyle(
                        color: AppColors.brandCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formattedDate,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (employee.department != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandBlue.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.brandBlue.withAlpha(60),
                              ),
                            ),
                            child: Text(
                              employee.department!,
                              style: const TextStyle(
                                color: AppColors.brandCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withAlpha(60),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt_rounded, size: 12, color: AppColors.success),
                              SizedBox(width: 2),
                              Text(
                                'Active Streak',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote_rounded, color: AppColors.brandPurple, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dailyQuote,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
