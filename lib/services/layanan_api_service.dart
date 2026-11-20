
import 'package:dio/dio.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/models/layanan_model.dart';

class LayananApiService {
  static Future<List<LayananModel>> getDaftarLayanan() async {
    try {
      final response = await ApiClient.dio.get('layanan/list');

      final data = response.data;

      if (data is! Map<String, dynamic> || data['status'] != true) {
        throw const SimrsApiException(
          message: 'Gagal mengambil daftar layanan.',
        );
      }

      final daftarLayanan = data['data'];

      if (daftarLayanan is! List) {
        throw const SimrsApiException(
          message: 'Format daftar layanan tidak valid.',
        );
      }

      return daftarLayanan
        .whereType<Map<String, dynamic>>()
        .map((json) => LayananModel.fromJson(json))
        .toList();
    } on DioException catch (e) {
      throw SimrsApiException(
        message: ApiClient.extractErrorMessage(e),
        statusCode: e.response?.statusCode, 
      );
    }
  }
}
