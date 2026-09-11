import 'package:dio/dio.dart';

/// Thin wrapper around Dio used for all outbound REST/AI API calls.
/// Centralizing this lets us add logging, retry logic, and interceptors
/// (e.g. auth headers) in exactly one place.
class ApiClient {
  final Dio dio;

  ApiClient({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? '',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(
        request: false,
        requestBody: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  Future<Response> post(String path, {Map<String, dynamic>? data, Map<String, dynamic>? headers}) {
    return dio.post(path, data: data, options: Options(headers: headers));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }
}
