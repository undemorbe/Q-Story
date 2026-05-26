import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiClient {
  final Dio _dio;

  /// API base URL. Override at build time:
  /// `flutter run --dart-define=API_URL=https://api.example.com`
  static final String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: dotenv.env['MAP_API_URL_BACKEND'] ?? 'https://api.q-story.app',
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
