import 'package:flutter/material.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';
import 'package:frontend_mob/features/goals/domain/entities/goal.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onDelete;

  const GoalCard({super.key, required this.goal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress;
    final pct = (progress * 100).toStringAsFixed(0);
    final isComplete = progress >= 1.0;

    return Container(
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
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTextStyles.titleMedium(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Theme.of(context).colorScheme.error,
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            NumberFormat.currency(symbol: '\$').format(goal.currentAmount),
            style: AppTextStyles.heading(context),
          ),
          Text(
            'of ${NumberFormat.currency(symbol: '\$').format(goal.targetAmount)}',
            style: AppTextStyles.body(context).copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete ? 'Goal Reached!' : 'Progress',
                style: AppTextStyles.labelLarge(context).copyWith(
                  color: isComplete ? AppColors.income : Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$pct%',
                style: AppTextStyles.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.income : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
