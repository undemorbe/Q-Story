import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.example.com'; // Placeholder
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    
    // Auth Interceptor Placeholder
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token here
        return handler.next(options);
      },
    ));
  }

  Dio get client => _dio;
}
