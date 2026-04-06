import 'package:dio/dio.dart';
import 'package:frontend_mob/core/network/api_enpoints.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/dashboard_summary.dart';

abstract class IDashboardRemoteDatasource {
  Future<DashboardSummary> getDashboardSummary();
}

@LazySingleton(as: IDashboardRemoteDatasource)
class DashboardRemoteDatasource implements IDashboardRemoteDatasource {
  final DioClient _client;

  DashboardRemoteDatasource(this._client);

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final res = await _client.dio.get(ApiEnpoints.dashboardSummary);
      final data = res.data['data'] as Map<String, dynamic>;

      final weekly = (data['weekly_data'] as List)
          .map(
            (w) => WeeklyData(
              day: w['day'] as String,
              income: (w['income'] as num).toDouble(),
              expense: (w['expense'] as num).toDouble(),
            ),
          )
          .toList();

      final categories = (data['category_breakdown'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));

      final recent = (data['recent_transactions'] as List)
          .map(
            (t) => RecentTransaction(
              id: t['id'] as String,
              category: t['category'] as String,
              amount: (t['amount'] as num).toDouble(),
              isIncome: t['type'] == 'income',
              date: DateTime.parse(t['date'] as String),
              note: t['note'] as String?,
            ),
          )
          .toList();

      return DashboardSummary(
        totalBalance: (data['total_balance'] as num).toDouble(),
        totalIncome: (data['total_income'] as num).toDouble(),
        totalExpense: (data['total_expense'] as num).toDouble(),
        weeklyData: weekly,
        categoryBreakdown: categories,
        recentTransactions: recent,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
