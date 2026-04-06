import 'package:dio/dio.dart';
import 'package:frontend_mob/core/network/api_enpoints.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';

abstract class ITransactionRemoteDatasource {
  Future<List<TransactionModel>> getTransactions({
    int page,
    String? category,
    String? type,
    String? search,
  });
  Future<TransactionModel> addTransaction(TransactionModel model);
  Future<TransactionModel> updateTransaction(TransactionModel model);
  Future<void> deleteTransaction(String id);
  Future<Map<String, double>> getCategoryTotals(String month);
}

@LazySingleton(as: ITransactionRemoteDatasource)
class TransactionRemoteDatasource implements ITransactionRemoteDatasource {
  final DioClient _client;

  TransactionRemoteDatasource(this._client);

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    String? category,
    String? type,
    String? search,
  }) async {
    try {
      final res = await _client.dio.get(
        ApiEnpoints.transactions,
        queryParameters: {
          'page': page,
          'limit': 20,
          'category': ?category,
          'type': ?type,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return (res.data['data'] as List)
          .map((j) => TransactionModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel model) async {
    try {
      final res = await _client.dio.post(
        ApiEnpoints.transactions,
        data: model.toJson(),
      );
      return TransactionModel.fromJson(
        res.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel model) async {
    try {
      final res = await _client.dio.put(
        ApiEnpoints.updateTransaction(model.id),
        data: model.toJson(),
      );
      return TransactionModel.fromJson(
        res.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _client.dio.delete(ApiEnpoints.deleteTransaction(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Map<String, double>> getCategoryTotals(String month) async {
    try {
      final res = await _client.dio.get(
        ApiEnpoints.categorySummary,
        queryParameters: {'month': month},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
