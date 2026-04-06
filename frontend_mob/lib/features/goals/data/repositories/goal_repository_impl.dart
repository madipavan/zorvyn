import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/i_goal_repository.dart';
import '../datasources/goal_remote_datasource.dart';

@LazySingleton(as: IGoalRepository)
class GoalRepositoryImpl implements IGoalRepository {
  final IGoalRemoteDatasource _remote;

  GoalRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final goals = await _remote.getGoals();
      return Right(goals);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) async {
    try {
      final result = await _remote.createGoal(goal);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      final result = await _remote.updateGoal(goal);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGoal(String id) async {
    try {
      await _remote.deleteGoal(id);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    }
  }
}
