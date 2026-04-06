import 'package:flutter/material.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final double size;

  const CategoryBadge({super.key, required this.category, this.size = 46});

  static const _icons = {
    'Food': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Bills': '📄',
    'Entertainment': '🎬',
    'Health': '🏥',
    'Education': '📚',
    'Travel': '✈️',
    'Salary': '💼',
    'Freelance': '💻',
    'Investment': '📈',
    'Gift': '🎁',
    'Rental': '🏠',
    'Other': '💰',
    'Income': '💵',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurfaceContainerHighest 
            : AppColors.lightSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Center(
        child: Text(
          _icons[category] ?? '💰',
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }
}
