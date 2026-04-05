import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDatasource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final model = await _remote.login(email, password);
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final model = await _remote.register(name, email, password);
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.logout();
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getCurrentUser() async {
    return const Left(ServerFailure('Not implemented'));
  }
}
