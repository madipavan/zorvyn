import 'package:equatable/equatable.dart';

class InsightsSummary extends Equatable {
  final Map<String, double> categoryTotals;
  final List<MonthlyTrend> monthlyTrend;
  final WeekComparison weekComparison;
  final String topSpendingCategory;
  final double averageDailyExpense;

  const InsightsSummary({
    required this.categoryTotals,
    required this.monthlyTrend,
    required this.weekComparison,
    required this.topSpendingCategory,
    required this.averageDailyExpense,
  });

  @override
  List<Object?> get props => [categoryTotals, monthlyTrend, weekComparison, topSpendingCategory, averageDailyExpense];
}

class MonthlyTrend extends Equatable {
  final String month;
  final double income;
  final double expense;

  const MonthlyTrend({required this.month, required this.income, required this.expense});

  @override
  List<Object?> get props => [month, income, expense];
}

class WeekComparison extends Equatable {
  final double thisWeek;
  final double lastWeek;

  const WeekComparison({required this.thisWeek, required this.lastWeek});

  double get changePercent => lastWeek > 0 ? ((thisWeek - lastWeek) / lastWeek) * 100 : 0;
  bool get isImprovement => thisWeek <= lastWeek;

  @override
  List<Object?> get props => [thisWeek, lastWeek];
}
