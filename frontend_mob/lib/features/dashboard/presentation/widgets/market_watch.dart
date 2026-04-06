import 'package:flutter/material.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';

class MarketWatch extends StatelessWidget {
  const MarketWatch({super.key});

  static const _items = [
    _MarketItem(ticker: 'S&P 500', change: '+1.2%', isPositive: true),
    _MarketItem(ticker: 'NASDAQ', change: '+0.8%', isPositive: true),
    _MarketItem(ticker: 'Gold', change: '-0.3%', isPositive: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Market Watch', style: AppTextStyles.sectionHeader(context)),
          const SizedBox(height: 16),
          ..._items.map((item) => _MarketRow(item: item)),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  final _MarketItem item;
  const _MarketRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isPositive ? AppColors.income : AppColors.expense;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.ticker,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.change,
              style: AppTextStyles.labelLarge(context).copyWith(
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketItem {
  final String ticker;
  final String change;
  final bool isPositive;
  const _MarketItem({required this.ticker, required this.change, required this.isPositive});
}
