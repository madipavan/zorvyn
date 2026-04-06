import 'package:dartz/dartz.dart';
import 'package:frontend_mob/core/services/device_info_service.dart';
import 'package:frontend_mob/features/auth/data/datasources/local_auth_datasource.dart';
import 'package:frontend_mob/features/auth/data/datasources/local_auth_storage_data_source.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDatasource _remote;
  final DeviceInfoService _deviceInfoService;
  final LocalAuthDataSource authDataSource;
  final LocalAuthStorageDataSource storage;

  AuthRepositoryImpl(
    this._remote,
    this._deviceInfoService,
    this.authDataSource,
    this.storage,
  );

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final deviceId = await _deviceInfoService.getDeviceId();
      final model = await _remote.login(email, password, deviceId);
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

  @override
  Future<bool> authenticate() {
    return authDataSource.authenticate();
  }

  @override
  Future<bool> isBiometricEnabled() {
    return storage.isBiometricEnabled();
  }

  @override
  Future<void> setBiometricEnabled(bool value) {
    return storage.setBiometricEnabled(value);
  }

  @override
  Future<bool> isDeviceSupported() {
    return authDataSource.isDeviceSupported();
  }
}
