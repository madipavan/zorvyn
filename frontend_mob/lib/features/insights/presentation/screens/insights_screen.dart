import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_event.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_state.dart';
import 'package:frontend_mob/shared/widgets/app_card.dart';
import 'package:frontend_mob/shared/widgets/category_badge.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:frontend_mob/shared/widgets/loading_shrimmer_list.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/insights_summary.dart';
import '../bloc/insights_bloc.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InsightsBloc>()..add(LoadInsights()),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insights', style: AppTextStyles.heading(context)),
      ),
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (context, state) {
          if (state is InsightsLoading) {
            return const LoadingShimmerList();
          }
          if (state is InsightsError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<InsightsBloc>().add(LoadInsights()),
            );
          }
          if (state is InsightsLoaded) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<InsightsBloc>().add(LoadInsights()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TopCategoryCard(summary: state.summary),
                  const SizedBox(height: 16),
                  _WeekComparisonCard(comparison: state.summary.weekComparison),
                  const SizedBox(height: 16),
                  _CategoryPieChart(
                    categoryTotals: state.summary.categoryTotals,
                  ),
                  const SizedBox(height: 16),
                  _MonthlyTrendChart(trend: state.summary.monthlyTrend),
                  const SizedBox(height: 16),
                  _DailyAverageCard(average: state.summary.averageDailyExpense),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  final InsightsSummary summary;
  const _TopCategoryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.expense.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.expense,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Highest Spending',
                  style: AppTextStyles.body(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 2),
                Text(
                  summary.topSpendingCategory,
                  style: AppTextStyles.heading(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'This month',
                  style: AppTextStyles.body(
                    context,
                  ).copyWith(fontSize: 12, color: AppColors.expense),
                ),
              ],
            ),
          ),
          CategoryBadge(category: summary.topSpendingCategory, size: 44),
        ],
      ),
    );
  }
}

class _WeekComparisonCard extends StatelessWidget {
  final WeekComparison comparison;
  const _WeekComparisonCard({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final improved = comparison.isImprovement;
    final pct = comparison.changePercent.abs();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week Over Week',
            style: AppTextStyles.heading(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WeekBox(
                  label: 'Last Week',
                  amount: comparison.lastWeek,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: improved
                      ? AppColors.income.withOpacity(0.1)
                      : AppColors.expense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      improved
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 14,
                      color: improved ? AppColors.income : AppColors.expense,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: improved ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeekBox(
                  label: 'This Week',
                  amount: comparison.thisWeek,
                  color: improved ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            improved
                ? 'Great job! You spent ${pct.toStringAsFixed(1)}% less than last week.'
                : 'You spent ${pct.toStringAsFixed(1)}% more than last week.',
            style: AppTextStyles.body(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _WeekBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _WeekBox({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body(context).copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat('#,##,###').format(amount)}',
            style: AppTextStyles.subHeading(
              context,
            ).copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatefulWidget {
  final Map<String, double> categoryTotals;
  const _CategoryPieChart({required this.categoryTotals});

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty) return const SizedBox.shrink();

    final total = widget.categoryTotals.values.fold(0.0, (a, b) => a + b);
    final entries = widget.categoryTotals.entries.toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: AppTextStyles.heading(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                sections: entries.asMap().entries.map((e) {
                  final isTouched = e.key == _touchedIndex;
                  final color = AppColors
                      .chartColors[e.key % AppColors.chartColors.length];
                  final pct = total > 0 ? (e.value.value / total * 100) : 0;
                  return PieChartSectionData(
                    value: e.value.value,
                    color: color,
                    radius: isTouched ? 90 : 75,
                    title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
                    titleStyle: AppTextStyles.body(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entries.asMap().entries.map((e) {
              final color =
                  AppColors.chartColors[e.key % AppColors.chartColors.length];
              final pct = total > 0 ? (e.value.value / total * 100) : 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${e.value.key} (${pct.toStringAsFixed(0)}%)',
                    style: AppTextStyles.body(context).copyWith(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTrend> trend;
  const _MonthlyTrendChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox.shrink();

    final maxY =
        trend
            .map((t) => [t.income, t.expense])
            .expand((e) => e)
            .fold(0.0, (a, b) => a > b ? a : b) *
        1.2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trend',
            style: AppTextStyles.heading(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < trend.length) {
                          return Text(
                            trend[idx].month,
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(fontSize: 12),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trend
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                        .toList(),
                    isCurved: true,
                    color: AppColors.income,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.income.withOpacity(0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: trend
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                        .toList(),
                    isCurved: true,
                    color: AppColors.expense,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.expense.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(color: AppColors.income, label: 'Income'),
              const SizedBox(width: 20),
              _ChartLegend(color: AppColors.expense, label: 'Expense'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.body(context).copyWith(fontSize: 12)),
      ],
    );
  }
}

class _DailyAverageCard extends StatelessWidget {
  final double average;
  const _DailyAverageCard({required this.average});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Average Spend',
                style: AppTextStyles.body(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${NumberFormat('#,##,###.##').format(average)}',
                style: AppTextStyles.heading(context).copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'per day this month',
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
