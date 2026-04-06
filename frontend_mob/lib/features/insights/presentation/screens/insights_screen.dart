import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_event.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_state.dart';
import 'package:frontend_mob/shared/widgets/empty_state_widget.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:frontend_mob/shared/widgets/loading_shrimmer_list.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
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
        title: Text(
          'Insights',
          style: AppTextStyles.displaySmall(context).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
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
            final summary = state.summary;
            final fmt = NumberFormat('#,##0');
            // Calculate total spending from categoryTotals
            double totalSpending = 0;
            summary.categoryTotals.forEach(
              (_, amount) => totalSpending += amount,
            );

            if (totalSpending == 0) {
              return EmptyStateWidget(
                icon: Icons.pie_chart_outline,
                title: 'No insights available',
                subtitle:
                    'Add some transactions to see your spending breakdown',
                onAction: () =>
                    context.read<InsightsBloc>().add(LoadInsights()),
                actionLabel: 'Refresh',
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<InsightsBloc>().add(LoadInsights()),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Total Spending Hero Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Spending',
                                style: AppTextStyles.bodyMedium(context)
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.3,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${fmt.format(totalSpending)}',
                                style: AppTextStyles.balanceHero(context),
                              ),
                            ],
                          ),
                        ),

                        // Category Breakdown
                        Text(
                          'Category Breakdown',
                          style: AppTextStyles.sectionHeader(context),
                        ),
                        const SizedBox(height: 16),
                        ...summary.categoryTotals.entries.map((e) {
                          return _CategoryRow(
                            category: e.key,
                            amount: e.value,
                            total: totalSpending,
                            color: _getColorForCategory(e.key),
                          );
                        }),
                        const SizedBox(height: 32),

                        // Week Comparison
                        Text(
                          'Week to Week',
                          style: AppTextStyles.sectionHeader(context),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ComparisonRow(
                                label: 'This Week',
                                amount: summary.weekComparison.thisWeek,
                              ),
                              const Divider(height: 24),
                              _ComparisonRow(
                                label: 'Last Week',
                                amount: summary.weekComparison.lastWeek,
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getColorForCategory(String category) {
    // Pick from chartColors based on length so it's deterministic
    final idx = category.length % AppColors.chartColors.length;
    return AppColors.chartColors[idx];
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final Color color;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final percent = (total > 0) ? (amount / total) : 0.0;
    final pctStr = (percent * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: AppTextStyles.titleMedium(context)),
              Text(
                '\$${fmt.format(amount)}',
                style: AppTextStyles.titleMedium(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$pctStr% of total spend',
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final double amount;

  const _ComparisonRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            '\$${fmt.format(amount)}',
            style: AppTextStyles.titleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
