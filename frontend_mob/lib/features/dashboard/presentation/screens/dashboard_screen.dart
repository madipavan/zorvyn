import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:frontend_mob/shared/widgets/amount_text.dart';
import 'package:frontend_mob/shared/widgets/app_card.dart';
import 'package:frontend_mob/shared/widgets/category_badge.dart';
import 'package:frontend_mob/shared/widgets/empty_state_widget.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<DashboardBloc>()..add(LoadDashboard()),
        ),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<DashboardBloc>().add(LoadDashboard()),
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                if (state is DashboardLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (state is DashboardError)
                  SliverFillRemaining(
                    child: ErrorStateWidget(
                      message: state.message,
                      onRetry: () =>
                          context.read<DashboardBloc>().add(LoadDashboard()),
                    ),
                  )
                else if (state is DashboardLoaded)
                  ..._buildContent(context, state.summary)
                else
                  const SliverFillRemaining(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Finance'),
        ],
      ),
      actions: [
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return IconButton(
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () => getIt<ThemeCubit>().toggle(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  List<Widget> _buildContent(BuildContext context, DashboardSummary summary) {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _BalanceCard(summary: summary),
            const SizedBox(height: 20),
            _SavingsCard(summary: summary),
            const SizedBox(height: 24),
            _WeeklyChart(weeklyData: summary.weeklyData),
            const SizedBox(height: 24),
            _CategoryBreakdown(data: summary.categoryBreakdown),
            const SizedBox(height: 24),
            _RecentTransactions(
              transactions: summary.recentTransactions,
              onSeeAll: () => context.go('/transactions'),
            ),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    ];
  }
}

class _BalanceCard extends StatelessWidget {
  final DashboardSummary summary;
  const _BalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs.${NumberFormat('#,##,###.##').format(summary.totalBalance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Income',
                  amount: summary.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.income,
                ),
              ),
              Expanded(
                child: _BalanceStat(
                  label: 'Expense',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Rs.${NumberFormat('#,##,###').format(amount)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final DashboardSummary summary;
  const _SavingsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final savings = summary.totalIncome - summary.totalExpense;
    final pct = summary.totalIncome > 0
        ? (savings / summary.totalIncome * 100).clamp(0.0, 100.0)
        : 0.0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Savings',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.income,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: AppColors.income.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.income),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            savings >= 0
                ? 'You saved Rs.${NumberFormat('#,##,###').format(savings)} this month'
                : 'You overspent by Rs.${NumberFormat('#,##,###').format(savings.abs())}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<WeeklyData> weeklyData;
  const _WeeklyChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: SizedBox(
            height: 180,
            child: weeklyData.isEmpty
                ? const Center(child: Text('No data available'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          weeklyData
                              .map((w) => [w.income, w.expense])
                              .expand((e) => e)
                              .fold(0.0, (a, b) => a > b ? a : b) *
                          1.3,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx >= 0 && idx < weeklyData.length)
                                return Text(
                                  weeklyData[idx].day,
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              return const SizedBox.shrink();
                            },
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
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: weeklyData
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.income,
                                  color: AppColors.income,
                                  width: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                BarChartRodData(
                                  toY: e.value.expense,
                                  color: AppColors.expense,
                                  width: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: AppColors.income, label: 'Income'),
            const SizedBox(width: 20),
            _Legend(color: AppColors.expense, label: 'Expense'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> data;
  const _CategoryBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: entries.take(5).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value.key;
              final amt = entry.value.value;
              final pct = total > 0 ? amt / total : 0.0;
              final color =
                  AppColors.chartColors[i % AppColors.chartColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CategoryBadge(category: cat, size: 32),
                            const SizedBox(width: 8),
                            Text(
                              cat,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Rs.${NumberFormat('#,##,###').format(amt)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<RecentTransaction> transactions;
  final VoidCallback onSeeAll;

  const _RecentTransactions({
    required this.transactions,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            subtitle: 'Start adding your income and expenses',
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: transactions.take(5).toList().asMap().entries.map((
                entry,
              ) {
                final t = entry.value;
                final isLast = entry.key == transactions.take(5).length - 1;
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: CategoryBadge(category: t.category),
                      title: Text(
                        t.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: t.note != null
                          ? Text(
                              t.note!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: AmountText(
                        amount: t.amount,
                        isIncome: t.isIncome,
                        fontSize: 14,
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        indent: 68,
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
