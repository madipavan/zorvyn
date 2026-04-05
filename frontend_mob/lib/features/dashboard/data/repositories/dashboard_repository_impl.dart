import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

@LazySingleton(as: IDashboardRepository)
class DashboardRepositoryImpl implements IDashboardRepository {
  final IDashboardRemoteDatasource _remote;

  DashboardRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary() async {
    try {
      final summary = await _remote.getDashboardSummary();
      return Right(summary);
    } on Failure catch (f) {
      return Left(f);
    }
  }
}
