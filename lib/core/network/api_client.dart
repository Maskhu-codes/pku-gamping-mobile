import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';

/// Client HTTP terpusat berbasis [Dio] untuk komunikasi dengan backend SIMRS RS PKU Gamping.
class ApiClient {
  ApiClient._();

  static const String baseUrl = 'https://simrs.pkugamping.com/api/v1';
  static Dio? _dioInstance;

  /// Singleton instance Dio
  static Dio get dio {
    _dioInstance ??= _createDio();
    return _dioInstance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-App-Platform': 'Flutter-Mobile',
          'X-Hospital-Id': 'RS-PKU-GAMPING',
        },
      ),
    );

    // 1. Auth Interceptor: otomatis sertakan token jika user sudah login
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SessionManager.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Tangani sesi kedaluwarsa (401 Unauthorized)
          if (error.response?.statusCode == 401) {
            debugPrint('[SIMRS API] Sesi kedaluwarsa, memicu popup Sesi Berakhir...');
            await AppFeedback.showSessionExpired();
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Logging Interceptor (aktif pada mode debug)
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[SIMRS-DIO] $obj'),
        ),
      );
    }

    return dio;
  }
}

/// Custom Exception untuk response error SIMRS
class SimrsApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const SimrsApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'SimrsApiException: $message (Status: $statusCode)';
}
