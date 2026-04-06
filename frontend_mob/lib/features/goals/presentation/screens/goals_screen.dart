import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_event.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_state.dart';
import 'package:frontend_mob/shared/widgets/empty_state_widget.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:frontend_mob/shared/widgets/loading_shrimmer_list.dart';
import 'package:frontend_mob/features/goals/presentation/widgets/goal_card.dart';
import 'package:frontend_mob/features/goals/presentation/widgets/create_goal_sheet.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/goal_bloc.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GoalBloc>()..add(LoadGoals()),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Goals',
          style: AppTextStyles.displaySmall(context).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCreateGoalSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is GoalActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.income,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GoalLoading) {
            return const LoadingShimmerList(itemCount: 3);
          }
          if (state is GoalError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<GoalBloc>().add(LoadGoals()),
            );
          }
          if (state is GoalLoaded) {
            if (state.goals.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.flag_outlined,
                title: 'No goals yet',
                subtitle: 'Create a savings goal or challenge to stay on track',
                actionLabel: 'Create Goal',
                onAction: () => _showCreateGoalSheet(context),
              );
            }

            // Calculate totals for the hero section
            double totalSaved = 0;
            double totalTarget = 0;
            for (var g in state.goals) {
              totalSaved += g.currentAmount;
              totalTarget += g.targetAmount;
            }

            final fmt = NumberFormat('#,##0');

            return RefreshIndicator(
              onRefresh: () async => context.read<GoalBloc>().add(LoadGoals()),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Hero Totals Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Saved',
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${fmt.format(totalSaved)}',
                                style: AppTextStyles.balanceHero(context),
                              ),
                              const SizedBox(height: 24),
                              
                              Text(
                                'Total Target',
                                style: AppTextStyles.bodySmall(context).copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${fmt.format(totalTarget)}',
                                style: AppTextStyles.headlineMedium(context).copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                        ),

                        // Goal list
                        ...state.goals.map((goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GoalCard(
                            goal: goal,
                            onDelete: () => context.read<GoalBloc>().add(DeleteGoalEvent(goal.id)),
                          ),
                        )),

                        // Investment CTA Card
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invest your savings',
                                    style: AppTextStyles.titleMedium(context).copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Grow your funds 4.5% APY',
                                    style: AppTextStyles.bodyMedium(context).copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.trending_up, 
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.4),
                                size: 40,
                              ),
                            ],
                          ),
                        )
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

  void _showCreateGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<GoalBloc>(),
        child: const CreateGoalSheet(),
      ),
    );
  }
}
