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
      return _handleBadResponse(e.response);

    case DioExceptionType.cancel:
      return const ServerFailure('Request was cancelled');

    default:
      return const ServerFailure('Something went wrong. Please try again.');
  }
}

Failure _handleBadResponse(Response? response) {
  final status = response?.statusCode ?? 0;
  final data = response?.data;

  final message = data?['message'] as String? ?? 'Server error occurred';

  final rawErrors = data?['errors'];
  final errors = (rawErrors is List && rawErrors.isNotEmpty)
      ? rawErrors.map((e) => e.toString()).toList()
      : <String>[];

  switch (status) {
    case 400:
      final detail = errors.isNotEmpty ? errors.first : message;
      return ServerFailure(detail);

    case 401:
      return AuthFailure(message);

    case 403:
      return const AuthFailure('You do not have permission to do this');

    case 404:
      return ServerFailure(message.isNotEmpty ? message : 'Resource not found');

    case 422:
      final detail = errors.isNotEmpty ? errors.join(', ') : message;
      return ValidationFailure(detail, errors);

    case 429:
      return const ServerFailure('Too many requests. Please slow down.');

    case >= 500:
      return const ServerFailure('Server error. Please try again later.');

    default:
      return ServerFailure(message);
  }
}
