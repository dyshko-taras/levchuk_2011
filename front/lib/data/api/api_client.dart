import 'package:dio/dio.dart';
import 'package:ice_line_tracker/core/endpoints.dart';
import 'package:ice_line_tracker/core/env.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.nhlWebApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: <String, Object?>{
          'Accept': 'application/json',
        },
      ),
    );

    if (!Env.isProd) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
        ),
      );
    }

    return dio;
  }
}
