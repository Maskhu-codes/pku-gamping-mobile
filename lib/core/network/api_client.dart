import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';

/// Client HTTP terpusat berbasis [Dio] untuk komunikasi dengan backend SIMRS RS PKU Gamping.
class ApiClient {
  ApiClient._();

  /// URL aktif yang digunakan oleh aplikasi, mengacu ke konfigurasi terpusat di [AppConfig.baseUrl].
  static String baseUrl = AppConfig.baseUrl;

  static Dio? _dioInstance;

  /// Singleton instance Dio
  static Dio get dio {
    _dioInstance ??= _createDio();
    return _dioInstance!;
  }

  /// Memperbarui Base URL secara dinamis saat runtime jika diperlukan
  static void setBaseUrl(String newUrl) {
    baseUrl = newUrl;
    if (_dioInstance != null) {
      _dioInstance!.options.baseUrl = newUrl;
    }
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-App-Platform': 'Flutter-Mobile',
          'X-Hospital-Id': 'RS-PKU-GAMPING',
        },
      ),
    );

    // 1. Auth Interceptor: otomatis sertakan Bearer token jika user sudah login
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SessionManager.token;
          if (!SessionManager.isGuestMode && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Tangani sesi kedaluwarsa (401 Unauthorized) hanya jika sebelumnya sudah login
          // dan bukan sedang mencoba login di layar login atau mode tamu
          final isLoginEndpoint = error.requestOptions.path.contains('/auth/login');
          if (error.response?.statusCode == 401 &&
              SessionManager.isLoggedIn &&
              !SessionManager.isGuestMode &&
              !isLoginEndpoint) {
            debugPrint('[SIMRS API] Sesi aktif kedaluwarsa (401), memicu popup Sesi Berakhir...');
            await AppFeedback.showSessionExpired();
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Logging Interceptor (aktif pada mode debug untuk kemudahan tracing)
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

  /// Ekstraktor pesan error yang ramah pengguna dari respon DioException
  static String extractErrorMessage(DioException error, {String defaultMessage = 'Terjadi kesalahan pada server.'}) {
    // 1. Cek respon dari backend (format JSON: { message: "...", error: "..." })
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
        if (data['error'] != null && data['error'].toString().isNotEmpty) {
          return data['error'].toString();
        }
        if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map) {
            return errors.values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
          }
        }
      } else if (data is String && data.isNotEmpty) {
        if (data.contains('<html') || data.contains('<!DOCTYPE') || data.contains('<div') || data.contains('<body')) {
          final containerMatch = RegExp(r'<div id="container">([\s\S]*?)<\/div>', caseSensitive: false).firstMatch(data);
          String rawHtml = containerMatch != null ? containerMatch.group(1)! : data;
          String cleanText = rawHtml
              .replaceAll(RegExp(r'<style[\s\S]*?<\/style>', caseSensitive: false), '')
              .replaceAll(RegExp(r'<script[\s\S]*?<\/script>', caseSensitive: false), '')
              .replaceAll(RegExp(r'<[^>]*>'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          if (cleanText.isNotEmpty) {
            if (cleanText.toLowerCase().contains('unable to connect to your database server')) {
              return 'Database Error: Backend gagal terhubung ke basis data SIMRS (192.168.20.x). Pastikan jaringan RS / VPN aktif.';
            }
            return cleanText.length > 250 ? cleanText.substring(0, 250) : cleanText;
          }
          return 'Terjadi kesalahan basis data pada server backend SIMRS.';
        }
        return data;
      }
    }

    // 2. Cek status HTTP standar jika tidak ada body JSON
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return 'Email atau kata sandi salah. Silakan periksa kembali.';
    } else if (statusCode == 403) {
      return 'Akses ditolak oleh server.';
    } else if (statusCode == 404) {
      return 'Layanan API tidak ditemukan (404). Periksa rute endpoint backend.';
    } else if (statusCode != null && statusCode >= 500) {
      return 'Terjadi gangguan internal pada server SIMRS ($statusCode).';
    }

    // 3. Masalah jaringan / koneksi ke backend
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Waktu koneksi ke server habis (Timeout). Pastikan backend aktif.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke backend di $baseUrl.\nPastikan server backend sudah berjalan dan dapat diakses.';
    }

    return error.message ?? defaultMessage;
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
  String toString() => message;
}
