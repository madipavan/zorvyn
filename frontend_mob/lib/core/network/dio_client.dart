import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mob/core/network/api_enpoints.dart';
import 'package:frontend_mob/core/network/auth_event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@singleton
class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  DioClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEnpoints.productionBaseUrl,
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(_storage, dio),
      PrettyDioLogger(requestBody: true, responseBody: true),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final opts = err.requestOptions;
        final token = await _storage.read(key: 'access_token');
        opts.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } else {
        await _storage.deleteAll();
        AuthEventBus.instance.add(AuthEvent.sessionExpired);
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: 'refresh_token');
      if (refresh == null) return false;
      final res = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      await _storage.write(
        key: 'access_token',
        value: res.data['access_token'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
