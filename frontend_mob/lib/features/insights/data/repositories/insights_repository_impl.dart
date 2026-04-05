import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/insights_summary.dart';
import '../../domain/repositories/i_insights_repository.dart';
import '../datasources/insights_remote_datasource.dart';

@LazySingleton(as: IInsightsRepository)
class InsightsRepositoryImpl implements IInsightsRepository {
  final IInsightsRemoteDatasource _remote;

  InsightsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, InsightsSummary>> getInsights() async {
    try {
      final summary = await _remote.getInsights();
      return Right(summary);
    } on Failure catch (f) {
      return Left(f);
    }
  }
}
