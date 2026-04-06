import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';
import 'package:frontend_mob/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:frontend_mob/shared/widgets/category_badge.dart';
import 'package:frontend_mob/shared/widgets/empty_state_widget.dart';

class RecentTransactions extends StatelessWidget {
  final List<RecentTransaction> transactions;
  final VoidCallback onSeeAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: AppTextStyles.sectionHeader(context),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See all',
                style: AppTextStyles.labelLarge(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (transactions.isEmpty)
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            subtitle: 'Start adding your income and expenses',
          )
        else
          Column(
            children: transactions.take(5).map((t) {
              return _TransactionRow(transaction: t);
            }).toList(),
          ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final RecentTransaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+' : '-';
    final fmt = NumberFormat('#,##0.00');
    final timeStr = DateFormat('hh:mm a').format(transaction.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CategoryBadge(category: transaction.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note ?? transaction.category,
                  style: AppTextStyles.titleSmall(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} • $timeStr',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix\$${fmt.format(transaction.amount)}',
            style: AppTextStyles.titleSmall(context).copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
