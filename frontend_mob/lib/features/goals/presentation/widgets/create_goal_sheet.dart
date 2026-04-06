import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';
import 'package:frontend_mob/core/widgets/app_button.dart';
import 'package:frontend_mob/features/goals/domain/entities/goal.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_event.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateGoalSheet extends StatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  State<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<CreateGoalSheet> {
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
    return SafeArea(
      child: Padding(
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
                    style: AppTextStyles.heading(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              Text(
                'Type',
                style: AppTextStyles.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
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
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
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
              AppButton(
                text: 'Create Goal',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
