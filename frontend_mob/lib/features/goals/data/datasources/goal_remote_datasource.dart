import 'package:dio/dio.dart';
import 'package:frontend_mob/core/network/api_enpoints.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/goal.dart';

abstract class IGoalRemoteDatasource {
  Future<List<Goal>> getGoals();
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
}

@LazySingleton(as: IGoalRemoteDatasource)
class GoalRemoteDatasource implements IGoalRemoteDatasource {
  final DioClient _client;

  GoalRemoteDatasource(this._client);

  Goal _fromJson(Map<String, dynamic> j) => Goal(
    id: j['id'] as String,
    title: j['title'] as String,
    type: GoalType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => GoalType.savings,
    ),
    targetAmount: (j['targetAmount'] as num).toDouble(),
    currentAmount: (j['currentAmount'] as num).toDouble(),
    startDate: DateTime.parse(j['startDate'] as String),
    endDate: DateTime.parse(j['endDate'] as String),
    isActive: j['isActive'] as bool,
    streakDays: (j['streakDays'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> _toJson(Goal g) => {
    'id': g.id,
    'title': g.title,
    'type': g.type.name,
    'targetAmount': g.targetAmount,
    'currentAmount': g.currentAmount,
    'startDate': g.startDate.toIso8601String(),
    'endDate': g.endDate.toIso8601String(),
    'isActive': g.isActive,
    'streakDays': g.streakDays,
  };

  @override
  Future<List<Goal>> getGoals() async {
    try {
      final res = await _client.dio.get(ApiEnpoints.goals);
      return (res.data['data'] as List)
          .map((j) => _fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    try {
      final res = await _client.dio.post(
        ApiEnpoints.goals,
        data: _toJson(goal),
      );
      return _fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    try {
      final res = await _client.dio.put(
        ApiEnpoints.updateGoal(goal.id),
        data: _toJson(goal),
      );
      return _fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _client.dio.delete(ApiEnpoints.deleteGoal(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
