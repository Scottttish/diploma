import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/analytics/analytics_bloc.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsBloc()..add(const AnalyticsLoadRequested()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AppBar(),
          BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state is AnalyticsLoading || state is AnalyticsInitial) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is AnalyticsError) {
                return SliverFillRemaining(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<AnalyticsBloc>()
                        .add(const AnalyticsLoadRequested()),
                  ),
                );
              }
              if (state is AnalyticsLoaded) {
                return _LoadedSliver(state: state);
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy').format(DateTime.now());
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.operationalBlue,
      foregroundColor: Colors.white,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.myPerformance ?? 'My Performance',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'IBMPlexSans',
              ),
            ),
            Text(
              month,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontFamily: 'IBMPlexSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedSliver extends StatelessWidget {
  final AnalyticsLoaded state;
  const _LoadedSliver({required this.state});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 16),
        _KpiGrid(state: state),
        const SizedBox(height: 16),
        _WeeklyChart(counts: state.weeklyCounts),
        const SizedBox(height: 16),
        _PerformanceCard(state: state),
        const SizedBox(height: 16),
        _HistoryButton(),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final AnalyticsLoaded state;
  const _KpiGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final avgMins = state.avgCompletionMinutes;
    final avgLabel = avgMins < 60
        ? '${avgMins.round()} min'
        : '${(avgMins / 60).toStringAsFixed(1)} h';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _StatCard(
              label: l.jobsThisMonth,
              value: '${state.completedThisMonth}',
              icon: Icons.check_circle_outline,
              accent: AppColors.operationalBlue,
            );
          }),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _StatCard(
              label: l.completedToday,
              value: '${state.completedToday}',
              icon: Icons.today_outlined,
              accent: AppColors.priorityCompleted,
            );
          }),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _StatCard(
              label: l.avgCompletion,
              value: avgLabel,
              icon: Icons.timer_outlined,
              accent: AppColors.safetyOrange,
            );
          }),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _StatCard(
              label: l.slaCompliance,
              value: '${state.slaCompliancePercent.round()}%',
              icon: Icons.shield_outlined,
              accent: state.slaCompliancePercent >= 90
                  ? AppColors.priorityCompleted
                  : AppColors.priorityHigh,
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  fontFamily: 'IBMPlexSans',
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withOpacity(0.6),
                  fontFamily: 'IBMPlexSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<int> counts;
  const _WeeklyChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxY = counts.isEmpty
        ? 1.0
        : (counts.reduce((a, b) => a > b ? a : b)).toDouble() + 1;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.weeklyProductivity ?? 'Weekly Productivity',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexSans',
              color: scheme.onSurface,
            ),
          ),
          Text(
            AppLocalizations.of(context)?.weeklyProductivitySub ?? 'Jobs completed — last 7 days',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withOpacity(0.6),
              fontFamily: 'IBMPlexSans',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurface.withOpacity(0.6),
                          fontFamily: 'IBMPlexSans',
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withOpacity(0.6),
                            fontFamily: 'IBMPlexSans',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(counts.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: counts[i].toDouble(),
                        color: AppColors.operationalBlue,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final AnalyticsLoaded state;
  const _PerformanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final score = ((state.slaCompliancePercent * 0.6) +
            ((state.completedThisMonth / 20).clamp(0, 1) * 100 * 0.4))
        .round();
    final color = score >= 80
        ? AppColors.priorityCompleted
        : score >= 60
            ? AppColors.safetyOrange
            : AppColors.priorityCritical;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.performanceScore ?? 'Performance Score',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'IBMPlexSans',
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.performanceScoreSub ?? 'Based on SLA compliance and job volume',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withOpacity(0.6),
                    fontFamily: 'IBMPlexSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'IBMPlexSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => context.push('/analytics/history'),
        icon: const Icon(Icons.history_rounded),
        label: Text(AppLocalizations.of(context)?.viewCompletedJobs ?? 'View Completed Jobs'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 48, color: AppColors.onSurfaceMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
