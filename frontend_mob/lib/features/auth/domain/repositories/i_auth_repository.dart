import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthUser>> login(String email, String password);
  Future<Either<Failure, AuthUser>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, AuthUser>> getCurrentUser();
  Future<bool> authenticate();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool value);
  Future<bool> isDeviceSupported();
}
