import 'package:dio/dio.dart';

enum ApiExceptionKind {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badCertificate,
  connectionError,
  badResponse,
  cancel,
  unknown,
}

class ApiException implements Exception {
  ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiException.fromDioException(DioException exception) {
    final kind = switch (exception.type) {
      DioExceptionType.connectionTimeout => ApiExceptionKind.connectionTimeout,
      DioExceptionType.sendTimeout => ApiExceptionKind.sendTimeout,
      DioExceptionType.receiveTimeout => ApiExceptionKind.receiveTimeout,
      DioExceptionType.badCertificate => ApiExceptionKind.badCertificate,
      DioExceptionType.badResponse => ApiExceptionKind.badResponse,
      DioExceptionType.cancel => ApiExceptionKind.cancel,
      DioExceptionType.connectionError => ApiExceptionKind.connectionError,
      DioExceptionType.unknown => ApiExceptionKind.unknown,
    };

    final statusCode = exception.response?.statusCode;

    return ApiException(
      kind: kind,
      statusCode: statusCode,
      message: exception.message ?? 'Request failed',
      originalError: exception.error,
    );
  }

  final ApiExceptionKind kind;
  final String message;
  final int? statusCode;
  final Object? originalError;

  @override
  String toString() {
    return 'ApiException(kind: $kind, '
        'statusCode: $statusCode, '
        'message: $message)';
  }
}
