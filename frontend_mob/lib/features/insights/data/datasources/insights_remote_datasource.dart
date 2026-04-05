import 'package:dio/dio.dart';
import 'package:frontend_mob/core/network/api_enpoints.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/insights_summary.dart';

abstract class IInsightsRemoteDatasource {
  Future<InsightsSummary> getInsights();
}

@LazySingleton(as: IInsightsRemoteDatasource)
class InsightsRemoteDatasource implements IInsightsRemoteDatasource {
  final DioClient _client;

  InsightsRemoteDatasource(this._client);

  @override
  Future<InsightsSummary> getInsights() async {
    try {
      final res = await _client.dio.get(ApiEnpoints.insights);
      final data = res.data['data'] as Map<String, dynamic>;

      final categories = (data['category_totals'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      );

      final monthly = (data['monthly_trend'] as List)
          .map(
            (m) => MonthlyTrend(
              month: m['month'] as String,
              income: (m['income'] as num).toDouble(),
              expense: (m['expense'] as num).toDouble(),
            ),
          )
          .toList();

      final wc = data['week_comparison'] as Map<String, dynamic>;

      return InsightsSummary(
        categoryTotals: categories,
        monthlyTrend: monthly,
        weekComparison: WeekComparison(
          thisWeek: (wc['this_week'] as num).toDouble(),
          lastWeek: (wc['last_week'] as num).toDouble(),
        ),
        topSpendingCategory: data['top_spending_category'] as String,
        averageDailyExpense: (data['average_daily_expense'] as num).toDouble(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
