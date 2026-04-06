import 'package:flutter/material.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';

class SavingsCard extends StatelessWidget {
  const SavingsCard({super.key});

  static const double _spent = 1875;
  static const double _budget = 2500;

  @override
  Widget build(BuildContext context) {
    final progress = (_spent / _budget).clamp(0.0, 1.0);
    final pct = (progress * 100).toStringAsFixed(0);
    final color = Theme.of(context).colorScheme.primary;

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
              Text('Spending Goal', style: AppTextStyles.sectionHeader(context)),
              Text(
                '$pct%',
                style: AppTextStyles.labelLarge(context).copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_spent.toInt()} of \$${_budget.toInt()}',
            style: AppTextStyles.bodySmall(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
