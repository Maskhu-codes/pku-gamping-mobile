import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';

/// Layanan untuk mengambil data master SIMRS RS PKU Gamping
/// (Agama, Pekerjaan, Pendidikan, Status Pernikahan).
class MasterService {
  MasterService._();

  static Dio get _dio => ApiClient.dio;

  /// Mengambil daftar master agama dari SIMRS
  /// Endpoint: GET /master/agama
  static Future<List<Map<String, dynamic>>> getAgama() async {
    return _fetchMasterList('/master/agama');
  }

  /// Mengambil daftar master pekerjaan dari SIMRS
  /// Endpoint: GET /master/pekerjaan
  static Future<List<Map<String, dynamic>>> getPekerjaan() async {
    return _fetchMasterList('/master/pekerjaan');
  }

  /// Mengambil daftar master pendidikan dari SIMRS
  /// Endpoint: GET /master/pendidikan
  static Future<List<Map<String, dynamic>>> getPendidikan() async {
    return _fetchMasterList('/master/pendidikan');
  }

  /// Mengambil daftar master status perkawinan dari SIMRS
  /// Endpoint: GET /master/status_kawin
  static Future<List<Map<String, dynamic>>> getStatusKawin() async {
    return _fetchMasterList('/master/status_kawin');
  }

  static Future<List<Map<String, dynamic>>> _fetchMasterList(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return <Map<String, dynamic>>[];
    } on DioException catch (e) {
      debugPrint('[MasterService] Error fetching $endpoint: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat data master dari server.',
      );
      throw Exception(errorMessage);
    }
  }
}

