import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_event.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_state.dart';
import 'package:frontend_mob/shared/widgets/app_card.dart';
import 'package:frontend_mob/shared/widgets/empty_state_widget.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:frontend_mob/shared/widgets/loading_shrimmer_list.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/goal.dart';
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
        title: Text('Goals & Challenges', style: AppTextStyles.heading(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCreateGoalSheet(context),
          ),
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
            return RefreshIndicator(
              onRefresh: () async => context.read<GoalBloc>().add(LoadGoals()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _GoalCard(
                  goal: state.goals[i],
                  onDelete: () => ctx.read<GoalBloc>().add(
                    DeleteGoalEvent(state.goals[i].id),
                  ),
                ),
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
        child: const _CreateGoalSheet(),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onDelete;

  const _GoalCard({required this.goal, required this.onDelete});

  IconData get _icon {
    switch (goal.type) {
      case GoalType.savings:
        return Icons.savings_outlined;
      case GoalType.noSpend:
        return Icons.block_outlined;
      case GoalType.budgetLimit:
        return Icons.account_balance_wallet_outlined;
      case GoalType.streak:
        return Icons.local_fire_department_outlined;
    }
  }

  Color get _color {
    switch (goal.type) {
      case GoalType.savings:
        return AppColors.income;
      case GoalType.noSpend:
        return AppColors.warning;
      case GoalType.budgetLimit:
        return AppColors.primary;
      case GoalType.streak:
        return Colors.deepOrange;
    }
  }

  String get _typeLabel {
    switch (goal.type) {
      case GoalType.savings:
        return 'Savings Goal';
      case GoalType.noSpend:
        return 'No Spend Challenge';
      case GoalType.budgetLimit:
        return 'Budget Limit';
      case GoalType.streak:
        return 'Streak Challenge';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverBudget =
        goal.type == GoalType.budgetLimit &&
        goal.currentAmount >= goal.targetAmount;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTextStyles.heading(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _typeLabel,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 12,
                        color: _color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (goal.type == GoalType.streak)
                Row(
                  children: [
                    Text('🔥', style: AppTextStyles.heading(context).copyWith(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.streakDays}d',
                      style: AppTextStyles.subHeading(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Theme.of(context).colorScheme.outline,
                  onPressed: onDelete,
                ),
            ],
          ),
          if (goal.type != GoalType.streak) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${NumberFormat('#,##,###').format(goal.currentAmount)}',
                  style: AppTextStyles.subHeading(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: isOverBudget ? AppColors.expense : _color,
                  ),
                ),
                Text(
                  'of ₹${NumberFormat('#,##,###').format(goal.targetAmount)}',
                  style: AppTextStyles.body(context).copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: _color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget ? AppColors.expense : _color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.isCompleted
                      ? '✅ Completed!'
                      : '${(goal.progress * 100).toStringAsFixed(0)}% done',
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: goal.isCompleted
                        ? AppColors.income
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(
                  '${goal.daysLeft} days left',
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'Keep it up! No spending for ${goal.streakDays} days straight.',
              style: AppTextStyles.body(context).copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${goal.daysLeft} days left in challenge',
              style: AppTextStyles.body(context).copyWith(
                fontSize: 12,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet();

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  GoalType _type = GoalType.savings;
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Goal',
                  style: AppTextStyles.heading(context).copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Goal Title'),
              validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            Text(
              'Type',
              style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GoalType.values.map((t) {
                final labels = {
                  GoalType.savings: 'Savings',
                  GoalType.noSpend: 'No Spend',
                  GoalType.budgetLimit: 'Budget Limit',
                  GoalType.streak: 'Streak',
                };
                return ChoiceChip(
                  label: Text(labels[t]!),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  labelStyle: AppTextStyles.body(context).copyWith(
                    color: _type == t ? AppColors.primary : null,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (_type != GoalType.streak)
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Target Amount (₹)',
                  prefixText: '₹ ',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  if (double.tryParse(v) == null) return 'Enter valid amount';
                  return null;
                },
              ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      'End Date: ${DateFormat('dd MMM yyyy').format(_endDate)}',
                      style: AppTextStyles.body(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final goal = Goal(
                      id: const Uuid().v4(),
                      title: _titleCtrl.text.trim(),
                      type: _type,
                      targetAmount: double.tryParse(_amountCtrl.text) ?? 0,
                      currentAmount: 0,
                      startDate: DateTime.now(),
                      endDate: _endDate,
                      isActive: true,
                    );
                    context.read<GoalBloc>().add(CreateGoalEvent(goal));
                    Navigator.pop(context);
                  }
                },
                child: Text('Create Goal', style: AppTextStyles.button(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
