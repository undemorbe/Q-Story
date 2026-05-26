import 'package:dio/dio.dart';
import '../errors/failures.dart';

/// Converts a Dio exception/status into a typed [Failure].
Failure dioToFailure(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Превышено время ожидания');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return const NotFoundFailure();
        if (code != null && code >= 400 && code < 500) {
          return ValidationFailure('Ошибка запроса: $code');
        }
        return ServerFailure('Ошибка сервера: ${code ?? '?'}',
            statusCode: code);
      case DioExceptionType.cancel:
        return const UnknownFailure('Запрос отменён');
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        return UnknownFailure(error.message ?? 'Неизвестная ошибка', error);
    }
  }
  return UnknownFailure(error.toString(), error);
}
