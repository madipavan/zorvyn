import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';

abstract class IDashboardRepository {
  Future<Either<Failure, DashboardSummary>> getDashboardSummary();
}
