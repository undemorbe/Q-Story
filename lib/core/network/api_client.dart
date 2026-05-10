import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  static const String baseUrl = 'https://2839bc9a-d491-41f2-94d8-c3c98ffedc32.tunnel4.com/api';

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
   

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
