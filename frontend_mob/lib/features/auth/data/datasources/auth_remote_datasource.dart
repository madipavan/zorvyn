import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mob/core/network/api_enpoints.dart';
import 'package:frontend_mob/features/auth/data/model/auth_user_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';

abstract class IAuthRemoteDatasource {
  Future<AuthUserModel> login(String email, String password, String deviceId);
  Future<AuthUserModel> register(String name, String email, String password);
  Future<void> logout();
}

@LazySingleton(as: IAuthRemoteDatasource)
class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRemoteDatasource(this._client, this._storage);

  @override
  Future<AuthUserModel> login(
    String email,
    String password,
    String deviceId,
  ) async {
    try {
      final res = await _client.dio.post(
        ApiEnpoints.login,
        data: {'email': email, 'password': password, "deviceId": deviceId},
      );
      final model = AuthUserModel.fromJson(res.data['data']);
      await _storage.write(key: 'access_token', value: model.accessToken);
      await _storage.write(key: 'refresh_token', value: model.refreshToken);
      await _storage.write(key: 'device_id', value: deviceId);
      return model;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AuthUserModel> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final res = await _client.dio.post(
        ApiEnpoints.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      final model = AuthUserModel.fromJson(res.data['data']);
      await _storage.write(key: 'access_token', value: model.accessToken);
      await _storage.write(key: 'refresh_token', value: model.refreshToken);
      return model;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEnpoints.logout);
    } catch (_) {
    } finally {
      await _storage.deleteAll();
    }
  }
}
