import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/features/dashboard/domain/entities/dashboard_summary.dart';

class BalanceCard extends StatelessWidget {
  final DashboardSummary summary;
  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0.00');
    final fmtShort = NumberFormat('#,##0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkPrimaryGradient
            : AppColors.lightPrimaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'Total Balance',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Hero balance number
          Text(
            '\$${fmt.format(summary.totalBalance)}',
            style: AppTextStyles.balanceHero(context).copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),

          // Income | Expenses side-by-side
          Row(
            children: [
              _StatChip(
                label: 'Income',
                value: '\$${fmtShort.format(summary.totalIncome)}',
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.income,
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _StatChip(
                label: 'Expenses',
                value: '\$${fmtShort.format(summary.totalExpense)}',
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall(context).copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleLarge(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
