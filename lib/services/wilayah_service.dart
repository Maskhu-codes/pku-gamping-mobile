import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';

/// Layanan master data wilayah berjenjang SIMRS RS PKU Gamping
/// (Provinsi -> Kabupaten/Kota -> Kecamatan -> Kelurahan -> Detail).
class WilayahService {
  WilayahService._();

  static Dio get _dio => ApiClient.dio;

  /// Mengambil seluruh daftar provinsi
  /// Endpoint: GET /wilayah/provinsi
  static Future<List<Map<String, dynamic>>> getProvinsi() async {
    return _fetchList('/wilayah/provinsi');
  }

  /// Mengambil daftar kabupaten/kota berdasarkan kode provinsi
  /// Endpoint: GET /wilayah/kabupaten?fs_kd_propinsi=X
  static Future<List<Map<String, dynamic>>> getKabupaten(String kdPropinsi) async {
    return _fetchList(
      '/wilayah/kabupaten',
      queryParameters: {'fs_kd_propinsi': kdPropinsi.trim()},
    );
  }

  /// Mengambil daftar kecamatan berdasarkan kode kabupaten
  /// Endpoint: GET /wilayah/kecamatan?fs_kd_kabupaten=X
  static Future<List<Map<String, dynamic>>> getKecamatan(String kdKabupaten) async {
    return _fetchList(
      '/wilayah/kecamatan',
      queryParameters: {'fs_kd_kabupaten': kdKabupaten.trim()},
    );
  }

  /// Mengambil daftar kelurahan berdasarkan kode kecamatan
  /// Endpoint: GET /wilayah/kelurahan?fs_kd_kecamatan=X
  static Future<List<Map<String, dynamic>>> getKelurahan(String kdKecamatan) async {
    return _fetchList(
      '/wilayah/kelurahan',
      queryParameters: {'fs_kd_kecamatan': kdKecamatan.trim()},
    );
  }

  /// Mengambil detail lengkap alamat (Kelurahan, Kecamatan, Kabupaten, Provinsi)
  /// berdasarkan kode kelurahan
  /// Endpoint: GET /wilayah/detail?fs_kd_kelurahan=X
  static Future<Map<String, dynamic>?> getDetailKelurahan(String kdKelurahan) async {
    try {
      final response = await _dio.get(
        '/wilayah/detail',
        queryParameters: {'fs_kd_kelurahan': kdKelurahan.trim()},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[WilayahService] Error getDetailKelurahan: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat detail kelurahan dari server.',
      );
      throw Exception(errorMessage);
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchList(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return <Map<String, dynamic>>[];
    } on DioException catch (e) {
      debugPrint('[WilayahService] Error fetching $endpoint: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat data wilayah dari server.',
      );
      throw Exception(errorMessage);
    }
  }
}

