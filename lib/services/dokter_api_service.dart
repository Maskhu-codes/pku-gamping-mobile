
import 'package:dio/dio.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/models/dokter_model.dart';

class DokterApiService {
  static Future<List<DokterModel>> getDaftarDokter({
    required String kodeLayanan,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'dokter/list',
        queryParameters: {
          'fs_kd_layanan': kodeLayanan,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic> || data['status'] != true) {
        throw const SimrsApiException(
          message: 'Gagal mengambil daftar dokter.',
        );
      }

      final daftarDokter = data['data'];

      if (daftarDokter is! List) {
        throw const SimrsApiException(
          message: 'Format daftar dokter tidak valid.',
        );
      }

      return daftarDokter
          .whereType<Map<String, dynamic>>()
          .map((json) => DokterModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw SimrsApiException(
        message: ApiClient.extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
