import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<WeeklyData> weeklyData;
  final Map<String, double> categoryBreakdown;
  final List<RecentTransaction> recentTransactions;

  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.weeklyData,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        weeklyData,
        categoryBreakdown,
        recentTransactions,
      ];
}

class WeeklyData extends Equatable {
  final String day;
  final double income;
  final double expense;

  const WeeklyData({required this.day, required this.income, required this.expense});

  @override
  List<Object?> get props => [day, income, expense];
}

class RecentTransaction extends Equatable {
  final String id;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String? note;

  const RecentTransaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, category, amount, isIncome, date];
}
