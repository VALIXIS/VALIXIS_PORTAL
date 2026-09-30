import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import '../../../invoices/presentation/providers/invoices_provider.dart';
import '../../../leads/presentation/providers/leads_provider.dart';
import '../../../operations/presentation/providers/operations_provider.dart';
import '../../data/repositories/dev_activity_logs_repository.dart';
import '../../data/repositories/supabase_activity_logs_repository.dart';
import '../../domain/entities/activity_log_item.dart';
import '../../domain/repositories/activity_logs_repository.dart';

export '../../domain/entities/activity_log_item.dart';
export '../../domain/repositories/activity_logs_repository.dart';

// ============================================================================
// 1. REPOSITORY PROVIDER
// ============================================================================

final activityLogsRepositoryProvider = Provider<ActivityLogsRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      return DevActivityLogsRepository();
    }
    return SupabaseActivityLogsRepository(client);
  } catch (e) {
    debugPrint('Supabase unavailable for ActivityLogs, using Dev fallback: $e');
    return DevActivityLogsRepository();
  }
});

// ============================================================================
// 2. ACTIVITY LOGS STATE & NOTIFIER
// ============================================================================

@immutable
class ActivityLogsState {
  final List<ActivityLogItem> logs;
  final bool isLoading;
  final String? error;

  const ActivityLogsState({
    this.logs = const [],
    this.isLoading = false,
    this.error,
  });

  ActivityLogsState copyWith({
    List<ActivityLogItem>? logs,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ActivityLogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ActivityLogsNotifier extends StateNotifier<ActivityLogsState> {
  final ActivityLogsRepository _repository;
  final Ref _ref;
  StreamSubscription<ActivityLogItem>? _subscription;

  ActivityLogsNotifier(this._repository, this._ref)
      : super(const ActivityLogsState(isLoading: true)) {
    loadLogs();
  }

  String get _currentOrgId {
    final org = _ref.read(currentOrganizationProvider);
    if (org != null && org.id.isNotEmpty) return org.id;
    final user = _ref.read(currentUserProvider);
    if (user != null &&
        user.organizationId != null &&
        user.organizationId!.isNotEmpty) {
      return user.organizationId!;
    }
    return 'org_dev_001';
  }

  Future<void> loadLogs({bool refresh = false}) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getActivityLogs(_currentOrgId);
      if (!mounted) return;
      state = state.copyWith(logs: list, isLoading: false, clearError: true);
      _setupSubscription();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load activity logs: ${e.toString()}',
      );
    }
  }

  void _setupSubscription() {
    _subscription?.cancel();
    _subscription = _repository.subscribeToActivityLogs(_currentOrgId).listen(
      (newLog) {
        if (!mounted) return;
        final updated = List<ActivityLogItem>.from(state.logs);
        // Avoid duplicate
        if (!updated.any((l) => l.id == newLog.id)) {
          updated.insert(0, newLog);
          state = state.copyWith(logs: updated);
        }
      },
      onError: (err) {
        debugPrint('Activity logs subscription error: $err');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final activityLogsProvider =
    StateNotifierProvider<ActivityLogsNotifier, ActivityLogsState>((ref) {
  final repo = ref.watch(activityLogsRepositoryProvider);
  return ActivityLogsNotifier(repo, ref);
});

// ============================================================================
// 3. EXECUTIVE KPI DATA MODEL & PROVIDER
// ============================================================================

@immutable
class ExecutiveKpiData {
  final double totalRevenue;
  final double pendingReceivables;
  final int totalLeads;
  final int wonLeads;
  final int activeLeads;
  final double leadWinRate;
  final int totalTasks;
  final int completedTasks;
  final double taskCompletionRate;
  final bool isLoading;
  final String? error;

  const ExecutiveKpiData({
    this.totalRevenue = 0.0,
    this.pendingReceivables = 0.0,
    this.totalLeads = 0,
    this.wonLeads = 0,
    this.activeLeads = 0,
    this.leadWinRate = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.taskCompletionRate = 0.0,
    this.isLoading = false,
    this.error,
  });

  String get formattedRevenue => AppUtils.formatCurrency(totalRevenue);
  String get formattedReceivables => AppUtils.formatCurrency(pendingReceivables);
  String get formattedTaskCompletionRate =>
      '${taskCompletionRate.toStringAsFixed(1)}%';
  String get formattedWinRate => '${leadWinRate.toStringAsFixed(1)}%';
}

final executiveKpiProvider = Provider<ExecutiveKpiData>((ref) {
  final invoicesState = ref.watch(invoicesListProvider);
  final leadsState = ref.watch(leadsNotifierProvider);
  final tasksState = ref.watch(tasksProvider);

  final isLoading =
      invoicesState.isLoading || leadsState.isLoading || tasksState.isLoading;
  final error = invoicesState.error ?? leadsState.errorMessage ?? tasksState.error;

  // 1. Revenue: Realized revenue from invoices where inv.isPaid || status == 'paid'
  double revenue = 0.0;
  // 2. Receivables: Outstanding receivables from unpaid invoices where !inv.isPaid && status != 'cancelled'
  double receivables = 0.0;

  for (final inv in invoicesState.invoices) {
    if (inv.isPaid || inv.status.toLowerCase() == 'paid') {
      revenue += inv.totalAmount;
    } else if (!inv.isCancelled && inv.status.toLowerCase() != 'cancelled') {
      receivables += inv.totalAmount;
    }
  }

  // 3. Leads metrics
  final allLeads = leadsState.leads;
  final totalLeads = allLeads.length;
  final wonLeads = allLeads.where((l) => l.stage == LeadStage.won).length;
  final activeLeads = allLeads.where((l) => l.stage != LeadStage.won).length;
  final leadWinRate =
      totalLeads > 0 ? (wonLeads / totalLeads) * 100.0 : 0.0;

  // 4. Tasks metrics
  final allTasks = tasksState.tasks;
  final totalTasks = allTasks.length;
  final completedTasks =
      allTasks.where((t) => t.isDone || t.status.toLowerCase() == 'done').length;
  final taskCompletionRate =
      totalTasks > 0 ? (completedTasks / totalTasks) * 100.0 : 0.0;

  return ExecutiveKpiData(
    totalRevenue: revenue,
    pendingReceivables: receivables,
    totalLeads: totalLeads,
    wonLeads: wonLeads,
    activeLeads: activeLeads,
    leadWinRate: leadWinRate,
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    taskCompletionRate: taskCompletionRate,
    isLoading: isLoading,
    error: error,
  );
});

// ============================================================================
// 4. MONTHLY REVENUE TREND DATA MODEL & PROVIDER (FOR FL_CHART)
// ============================================================================

@immutable
class MonthlyRevenuePoint {
  final int monthIndex; // 1-12
  final String monthLabel; // 'Jan', 'Feb', etc.
  final int year;
  final double revenue;
  final int invoiceCount;

  const MonthlyRevenuePoint({
    required this.monthIndex,
    required this.monthLabel,
    required this.year,
    required this.revenue,
    this.invoiceCount = 0,
  });
}

@immutable
class MonthlyRevenueTrendData {
  final List<MonthlyRevenuePoint> points;
  final double maxRevenue;
  final double minRevenue;
  final double totalRevenue;
  final bool hasData;

  const MonthlyRevenueTrendData({
    required this.points,
    required this.maxRevenue,
    required this.minRevenue,
    required this.totalRevenue,
    required this.hasData,
  });

  const MonthlyRevenueTrendData.empty()
      : points = const [],
        maxRevenue = 0.0,
        minRevenue = 0.0,
        totalRevenue = 0.0,
        hasData = false;
}

final monthlyRevenueTrendProvider = Provider<MonthlyRevenueTrendData>((ref) {
  final invoicesState = ref.watch(invoicesListProvider);
  final now = DateTime.now();

  const monthLabels = [
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
    'Dec',
  ];

  // Build the trailing 6 months (or current year trailing 6 months)
  final List<MonthlyRevenuePoint> points = [];
  final Map<String, double> revenueByMonth = {};
  final Map<String, int> countByMonth = {};

  // Aggregate paid invoices
  for (final inv in invoicesState.invoices) {
    if (inv.isPaid || inv.status.toLowerCase() == 'paid') {
      final date = inv.issueDate;
      final key = '${date.year}-${date.month}';
      revenueByMonth[key] = (revenueByMonth[key] ?? 0.0) + inv.totalAmount;
      countByMonth[key] = (countByMonth[key] ?? 0) + 1;
    }
  }

  // Generate 6 trailing months leading up to current month
  for (int i = 5; i >= 0; i--) {
    final targetDate = DateTime(now.year, now.month - i, 1);
    final key = '${targetDate.year}-${targetDate.month}';
    final rev = revenueByMonth[key] ?? 0.0;
    final cnt = countByMonth[key] ?? 0;

    points.add(
      MonthlyRevenuePoint(
        monthIndex: targetDate.month,
        monthLabel: monthLabels[targetDate.month - 1],
        year: targetDate.year,
        revenue: rev,
        invoiceCount: cnt,
      ),
    );
  }

  double maxRev = 0.0;
  double minRev = double.infinity;
  double totalRev = 0.0;
  bool anyNonZero = false;

  for (final p in points) {
    if (p.revenue > maxRev) maxRev = p.revenue;
    if (p.revenue < minRev) minRev = p.revenue;
    totalRev += p.revenue;
    if (p.revenue > 0) anyNonZero = true;
  }

  if (minRev == double.infinity) minRev = 0.0;

  return MonthlyRevenueTrendData(
    points: points,
    maxRevenue: maxRev,
    minRevenue: minRev,
    totalRevenue: totalRev,
    hasData: anyNonZero,
  );
});

// ============================================================================
// 5. CONVERSION FUNNEL DATA MODEL & PROVIDER
// ============================================================================

@immutable
class FunnelStageItem {
  final LeadStage stage;
  final int count;
  final double percentageOfTotal;
  final double stageConversionRate;

  const FunnelStageItem({
    required this.stage,
    required this.count,
    required this.percentageOfTotal,
    required this.stageConversionRate,
  });
}

@immutable
class ConversionFunnelData {
  final List<FunnelStageItem> stages;
  final int totalLeads;
  final int wonLeads;
  final double overallWinRate;

  const ConversionFunnelData({
    required this.stages,
    required this.totalLeads,
    required this.wonLeads,
    required this.overallWinRate,
  });

  const ConversionFunnelData.empty()
      : stages = const [],
        totalLeads = 0,
        wonLeads = 0,
        overallWinRate = 0.0;
}

final conversionFunnelProvider = Provider<ConversionFunnelData>((ref) {
  final leadsState = ref.watch(leadsNotifierProvider);
  final leads = leadsState.leads;
  final totalLeads = leads.length;

  final stageCounts = <LeadStage, int>{
    for (final s in LeadStage.values) s: 0,
  };

  for (final lead in leads) {
    stageCounts[lead.stage] = (stageCounts[lead.stage] ?? 0) + 1;
  }

  final wonCount = stageCounts[LeadStage.won] ?? 0;
  final overallWinRate =
      totalLeads > 0 ? (wonCount / totalLeads) * 100.0 : 0.0;

  final List<FunnelStageItem> funnelStages = [];
  int previousStageCount = totalLeads;

  for (final stage in LeadStage.values) {
    final count = stageCounts[stage] ?? 0;
    final pctOfTotal = totalLeads > 0 ? (count / totalLeads) * 100.0 : 0.0;
    final convFromPrev = previousStageCount > 0
        ? (count / previousStageCount) * 100.0
        : 0.0;

    funnelStages.add(
      FunnelStageItem(
        stage: stage,
        count: count,
        percentageOfTotal: pctOfTotal,
        stageConversionRate: convFromPrev,
      ),
    );
    previousStageCount = count;
  }

  return ConversionFunnelData(
    stages: funnelStages,
    totalLeads: totalLeads,
    wonLeads: wonCount,
    overallWinRate: overallWinRate,
  );
});
