import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../invoices/presentation/providers/invoices_provider.dart';
import '../../../leads/presentation/providers/leads_provider.dart';
import '../../../operations/presentation/providers/operations_provider.dart';
import '../providers/dashboard_kpi_providers.dart';
import '../widgets/activity_feed_widget.dart';
import '../widgets/conversion_funnel_widget.dart';
import '../widgets/kpi_cards_grid.dart';
import '../widgets/monthly_revenue_chart.dart';

/// Executive Dashboard view with real-time KPI cards, revenue charts, and audit activity.
class ExecutiveDashboardScreen extends ConsumerWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiData = ref.watch(executiveKpiProvider);
    final revenueTrend = ref.watch(monthlyRevenueTrendProvider);
    final funnelData = ref.watch(conversionFunnelProvider);
    final activityLogsState = ref.watch(activityLogsProvider);

    return AppPage(
      title: 'Executive Dashboard',
      subtitle:
          'Real-time overview of business operations, revenue, and pipeline status.',
      trailing: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Executive summary exported successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export Brief'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.go(RoutePaths.invoiceBuilder);
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New Invoice'),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(invoicesListProvider.notifier).loadInvoices(refresh: true),
            ref.read(leadsNotifierProvider.notifier).fetchLeads(),
            ref.read(tasksProvider.notifier).loadTasks(refresh: true),
            ref.read(activityLogsProvider.notifier).loadLogs(refresh: true),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Four Real-Time KPI Summary Cards
              KpiCardsGrid(
                kpiData: kpiData,
                onRetry: () {
                  ref
                      .read(invoicesListProvider.notifier)
                      .loadInvoices(refresh: true);
                  ref.read(leadsNotifierProvider.notifier).fetchLeads();
                  ref.read(tasksProvider.notifier).loadTasks(refresh: true);
                },
              ),
              const SizedBox(height: 24),

              // 2. Charts & Analytics Grid (Revenue Trend + Funnel)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;

                  if (!isWide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MonthlyRevenueChart(trendData: revenueTrend),
                        const SizedBox(height: 20),
                        ConversionFunnelWidget(funnelData: funnelData),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: MonthlyRevenueChart(trendData: revenueTrend),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: ConversionFunnelWidget(funnelData: funnelData),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Real-Time Audit Activity Feed
              ActivityFeedWidget(
                state: activityLogsState,
                onRefresh: () {
                  ref
                      .read(activityLogsProvider.notifier)
                      .loadLogs(refresh: true);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
