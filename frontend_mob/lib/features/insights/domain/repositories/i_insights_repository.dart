import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/insights_summary.dart';

abstract class IInsightsRepository {
  Future<Either<Failure, InsightsSummary>> getInsights();
}
