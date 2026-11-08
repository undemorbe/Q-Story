import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_info.dart';
import '../errors/failures.dart';

/// Builds a [Dio] instance configured for talking to public, key-less
/// open-data APIs (Wikipedia, Wikidata, OpenStreetMap, PastVu).
///
/// Every request carries an identifying User-Agent, as required by the
/// Wikimedia and OSM usage policies.
Dio createHttpClient({Duration timeout = const Duration(seconds: 20)}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {'User-Agent': AppInfo.userAgent, 'Accept': 'application/json'},
    ),
  );
  if (kDebugMode) {
    // Log only request lines and status codes, never bodies.
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }
  return dio;
}

/// Converts any error thrown by the network layer into a typed [Failure].
Failure toFailure(Object error) {
  if (error is Failure) return error;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure('Timeout');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return const NotFoundFailure();
        return ServerFailure('HTTP ${code ?? '?'}', statusCode: code);
      case DioExceptionType.cancel:
        return const UnknownFailure('Cancelled');
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        return UnknownFailure(error.message ?? 'Unknown error', error);
    }
  }
  if (error is FormatException || error is TypeError) {
    return ServerFailure('Unexpected response format: $error');
  }
  return UnknownFailure(error.toString(), error);
}
