import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio _dio;

  /// API base URL. Override at build time:
  /// `flutter run --dart-define=API_URL=https://api.example.com`
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue:
        'https://2839bc9a-d491-41f2-94d8-c3c98ffedc32.tunnel4.com/api',
  );

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Only log payloads in debug builds — release builds must not leak
    // request/response bodies (may contain tokens, coordinates, PII).
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
  }

  Dio get client => _dio;
}
