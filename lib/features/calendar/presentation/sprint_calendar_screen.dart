import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/realtime_sync_service.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_shimmer.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/models/task.dart';
import '../../auth/domain/role_service.dart';
import '../../auth/presentation/providers/role_provider.dart';
import '../../tasks/domain/models/sprint_models.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
import '../../tasks/presentation/widgets/task_card.dart';

/// Interactive Operations & Sprint Calendar View.
/// Displays daily task schedules, date-based filtering, multi-app distributions, and real-time updates.
class SprintCalendarScreen extends ConsumerStatefulWidget {
  const SprintCalendarScreen({super.key});

  @override
  ConsumerState<SprintCalendarScreen> createState() => _SprintCalendarScreenState();
}

class _SprintCalendarScreenState extends ConsumerState<SprintCalendarScreen> {
  static const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _fullWeekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  DateTime? _selectedDateFilter; // null means 'All Scheduled Tasks'
  SprintApp _selectedApp = SprintApp.all;

  String _formatWeekdayShort(DateTime dt) => _weekdayNames[dt.weekday - 1];
  String _formatWeekdayFull(DateTime dt) => _fullWeekdayNames[dt.weekday - 1];
  String _formatDayMonth(DateTime dt) => '${dt.day} ${_shortMonthNames[dt.month - 1]}';
  String _formatFullDate(DateTime dt) =>
      '${_formatWeekdayFull(dt)}, ${_monthNames[dt.month - 1]} ${dt.day}, ${dt.year}';

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Dynamically extracts all active calendar dates from tasks + current 14-day window.
  List<DateTime> _getAvailableDates(List<Task> tasks) {
    final dateSet = <DateTime>{};
    
    // Add current week dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    dateSet.add(today);

    // Add dates from task deadlines and creation dates
    for (final t in tasks) {
      dateSet.add(DateTime(t.deadline.year, t.deadline.month, t.deadline.day));
      if (t.createdAt != null) {
        dateSet.add(DateTime(t.createdAt!.year, t.createdAt!.month, t.createdAt!.day));
      }
    }

    final sorted = dateSet.toList()..sort((a, b) => a.compareTo(b));
    return sorted;
  }

  List<Task> _getFilteredTasks(List<Task> allTasks) {
    return allTasks.where((task) {
      if (_selectedApp != SprintApp.all) {
        final app = SprintApp.fromTask(task);
        if (app != _selectedApp) return false;
      }

      if (_selectedDateFilter == null) return true;

      final target = _selectedDateFilter!;
      final isDeadline = _isSameDay(task.deadline, target);
      final isCreated = task.createdAt != null && _isSameDay(task.createdAt!, target);

      return isDeadline || isCreated;
    }).toList();
  }

  int _getTaskCountForDate(List<Task> allTasks, DateTime targetDate) {
    return allTasks.where((task) {
      if (_selectedApp != SprintApp.all) {
        final app = SprintApp.fromTask(task);
        if (app != _selectedApp) return false;
      }
      final isDeadline = _isSameDay(task.deadline, targetDate);
      final isCreated = task.createdAt != null && _isSameDay(task.createdAt!, targetDate);
      return isDeadline || isCreated;
    }).length;
  }

  Map<SprintApp, int> _getAppCounts(List<Task> filteredTasks) {
    final counts = <SprintApp, int>{};
    for (final app in SprintApp.values) {
      if (app != SprintApp.all) counts[app] = 0;
    }
    for (final task in filteredTasks) {
      final app = SprintApp.fromTask(task);
      if (app != SprintApp.all) {
        counts[app] = (counts[app] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.brandCyan,
              onPrimary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _selectToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDateFilter = DateTime(now.year, now.month, now.day);
    });
  }

  void _selectAllTasks() {
    setState(() {
      _selectedDateFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final role = ref.watch(roleProvider).valueOrNull ?? UserRole.employee;
    final isManager = role.isManager;
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.brandCyan,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          ref.read(realtimeSyncProvider.notifier).forceRefresh();
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppSpacing.xl : AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(isDesktop, isManager),
                  const SizedBox(height: AppSpacing.lg),

                  // Telemetry & Task Loading
                  tasksAsync.when(
                    loading: () => const _CalendarShimmerView(),
                    error: (err, stack) => Center(
                      child: EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Unable to load operations calendar',
                        description: err.toString(),
                        action: AppButton(
                          label: 'Retry',
                          prefixIcon: Icons.refresh_rounded,
                          onPressed: () => ref.invalidate(tasksProvider),
                        ),
                      ),
                    ),
                    data: (allTasks) {
                      final availableDates = _getAvailableDates(allTasks);
                      final filteredTasks = _getFilteredTasks(allTasks);
                      final appCounts = _getAppCounts(filteredTasks);
                      final completedCount = filteredTasks.where((t) => t.status == TaskStatus.approved).length;
                      final inProgressCount = filteredTasks.where((t) => t.status == TaskStatus.inProgress).length;
                      final underReviewCount = filteredTasks.where((t) => t.status == TaskStatus.submitted).length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dynamic Date Strip with All Tasks chip
                          _buildDateSelectorStrip(availableDates, allTasks),
                          const SizedBox(height: AppSpacing.lg),

                          // Daily / Overview Summary Metrics Card
                          _buildDailySummaryMetrics(
                            filteredTasks: filteredTasks,
                            appCounts: appCounts,
                            completedCount: completedCount,
                            inProgressCount: inProgressCount,
                            underReviewCount: underReviewCount,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // App Isolation Filter Chips
                          _buildAppFilterChips(appCounts, allTasks),
                          const SizedBox(height: AppSpacing.md),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDateFilter == null
                                    ? 'All Scheduled Tasks (${filteredTasks.length})'
                                    : 'Tasks Scheduled for ${_formatDayMonth(_selectedDateFilter!)} (${filteredTasks.length})',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (_selectedDateFilter != null && _isSameDay(_selectedDateFilter!, DateTime.now()))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandCyan.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.brandCyan.withValues(alpha: 0.4),
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
                                      const Text(
                                        'LIVE TODAY',
                                        style: TextStyle(
                                          color: AppColors.brandCyan,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Day Tasks Grid / List
                          if (filteredTasks.isEmpty)
                            GlassCard(
                              padding: const EdgeInsets.all(AppSpacing.xl2),
                              child: Center(
                                child: EmptyState(
                                  icon: Icons.event_available_rounded,
                                  title: 'No Tasks Scheduled',
                                  description: _selectedDateFilter != null
                                      ? 'No operations or updates are slated for ${_formatDayMonth(_selectedDateFilter!)}.'
                                      : 'No tasks found matching the selected filters.',
                                  action: AppButton(
                                    label: 'Show All Tasks',
                                    prefixIcon: Icons.format_list_bulleted_rounded,
                                    variant: AppButtonVariant.secondary,
                                    onPressed: _selectAllTasks,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredTasks.length,
                              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return TaskCard(task: task);
                              },
                            ),
                          const SizedBox(height: AppSpacing.xl2),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, bool isManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.brandCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'VALIXIS PORTAL • ${isManager ? 'MANAGER PORTAL' : 'EMPLOYEE PORTAL'}',
                      style: AppTypography.telemetryHeader(
                        size: 9,
                        color: AppColors.brandCyan,
                        spacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Operations Calendar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track daily tasks, multi-app releases, and developer assignments across real calendar dates.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'All Tasks',
              prefixIcon: Icons.format_list_bulleted_rounded,
              variant: _selectedDateFilter == null ? AppButtonVariant.primary : AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: _selectAllTasks,
            ),
            const SizedBox(width: AppSpacing.xs),
            AppButton(
              label: 'Today',
              prefixIcon: Icons.today_rounded,
              variant: (_selectedDateFilter != null && _isSameDay(_selectedDateFilter!, DateTime.now()))
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: _selectToday,
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Icon(Icons.date_range_rounded, size: 18, color: AppColors.brandCyan),
              ),
              tooltip: 'Choose specific calendar date',
              onPressed: _pickCustomDate,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelectorStrip(List<DateTime> availableDates, List<Task> allTasks) {
    final now = DateTime.now();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // 'All Tasks' Chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: _selectAllTasks,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedDateFilter == null
                      ? AppColors.brandCyan.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDateFilter == null ? AppColors.brandCyan : AppColors.glassBorder,
                    width: _selectedDateFilter == null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ALL',
                      style: TextStyle(
                        color: AppColors.brandCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'All Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${allTasks.length} total',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Real Date Chips
          ...availableDates.map((date) {
            final isSelected = _selectedDateFilter != null && _isSameDay(_selectedDateFilter!, date);
            final isToday = _isSameDay(date, now);
            final count = _getTaskCountForDate(allTasks, date);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = date;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brandCyan.withValues(alpha: 0.2)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandCyan
                          : (isToday ? AppColors.brandCyan.withValues(alpha: 0.5) : AppColors.glassBorder),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.brandCyan.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatWeekdayShort(date).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? AppColors.brandCyan : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.brandCyan,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDayMonth(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$count ${count == 1 ? 'task' : 'tasks'}',
                        style: TextStyle(
                          color: count > 0
                              ? (isSelected ? AppColors.brandCyan : AppColors.brandBlue)
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailySummaryMetrics({
    required List<Task> filteredTasks,
    required Map<SprintApp, int> appCounts,
    required int completedCount,
    required int inProgressCount,
    required int underReviewCount,
    required bool isDesktop,
  }) {
    final activeApps = appCounts.entries.where((e) => e.value > 0).toList();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppColors.brandCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedDateFilter == null
                                ? 'All Scheduled Operations Overview'
                                : _formatFullDate(_selectedDateFilter!),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_selectedDateFilter != null && _isSameDay(_selectedDateFilter!, DateTime.now())) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.brandCyan,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${filteredTasks.length} ${filteredTasks.length == 1 ? 'task' : 'tasks'} across ${activeApps.length} ${activeApps.length == 1 ? 'app' : 'apps'}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MetricChip(label: 'Done', count: completedCount, color: AppColors.success),
                    const SizedBox(width: 8),
                    _MetricChip(label: 'In Progress', count: inProgressCount, color: AppColors.warning),
                    const SizedBox(width: 8),
                    _MetricChip(label: 'Review', count: underReviewCount, color: const Color(0xFF6366F1)),
                  ],
                ),
              ),
            ],
          ),
          if (activeApps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: activeApps.map((entry) {
                final app = entry.key;
                final count = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: app.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: app.color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(app.icon, size: 13, color: app.color),
                      const SizedBox(width: 6),
                      Text(
                        '${app.displayName}: $count ${count == 1 ? 'task' : 'tasks'}',
                        style: TextStyle(
                          color: app.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppFilterChips(Map<SprintApp, int> appCounts, List<Task> allTasks) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: SprintApp.values.map((app) {
          final isSelected = _selectedApp == app;
          final count = app == SprintApp.all
              ? appCounts.values.fold(0, (a, b) => a + b)
              : (appCounts[app] ?? 0);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedApp = app),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? app.color.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? app.color : AppColors.glassBorder,
                    width: isSelected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      app.icon,
                      size: 14,
                      color: isSelected ? app.color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${app.displayName} ($count)',
                      style: TextStyle(
                        color: isSelected ? app.color : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: $count',
          style: TextStyle(
            color: count > 0 ? Colors.white : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CalendarShimmerView extends StatelessWidget {
  const _CalendarShimmerView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AppShimmer(width: double.infinity, height: 110, borderRadius: 16),
        SizedBox(height: AppSpacing.md),
        AppShimmer(width: double.infinity, height: 140, borderRadius: 16),
        SizedBox(height: AppSpacing.md),
        AppShimmer(width: double.infinity, height: 140, borderRadius: 16),
      ],
    );
  }
}
