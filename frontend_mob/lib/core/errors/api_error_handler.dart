import 'package:dio/dio.dart';

import 'failures.dart';

Failure handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      if (status == 401) return const AuthFailure();
      final msg =
          e.response?.data?['message'] as String? ?? 'Server error occurred';
      return ServerFailure(msg);
    case DioExceptionType.cancel:
      return const ServerFailure('Request was cancelled');
    default:
      return const ServerFailure('Something went wrong. Please try again.');
  }
}
