import 'package:dio/dio.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/models/antrean_model.dart';
import 'package:pku_gamping_app/data/status_antrean_model.dart';

class AntreanApiService {
  // Mengambil booking aktif pasien
  static Future<Map<String, dynamic>> getBookingAktif() async {
    try {
      final response = await ApiClient.dio.get('booking/aktif');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const SimrsApiException(
          message: 'Format respons booking tidak valid.',
        );
      }

      return data;
    } on DioException catch (e) {
      throw SimrsApiException(
        message: ApiClient.extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Mengambil status antrean terkini
  static Future<Map<String, dynamic>> getStatusAntrean({
    required String kodeLayanan,
    required String kodeDokter,
    String? nomorAntrean,
    String? tanggal,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'antrean/status',
        queryParameters: {
          'fs_kd_layanan': kodeLayanan,
          'fs_kd_petugas_medis': kodeDokter,
          if (nomorAntrean != null && nomorAntrean.isNotEmpty)
            'fs_kd_antrian': nomorAntrean,
          if (tanggal != null && tanggal.isNotEmpty)
            'tanggal': tanggal,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const SimrsApiException(
          message: 'Format respons antrean tidak valid.',
        );
      }

      return data;
    } on DioException catch (e) {
      throw SimrsApiException(
        message: ApiClient.extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  
static Future<AntreanAktifModel?> getBookingAktifModel() async {
  try {
    final response = await getBookingAktif();

    if (response['status'] != true) {
      throw const SimrsApiException(
        message: 'Gagal mengambil booking aktif.',
      );
    }

    final data = response['data'];

    if (data == null) {
      return null;
    }

    if (data is! Map<String, dynamic>) {
      throw const SimrsApiException(
        message: 'Format data booking tidak sesuai.',
      );
    }

    return AntreanAktifModel.fromBookingJson(data);
  } on SimrsApiException catch (e) {
    if (e.statusCode == 404 &&
        e.message == 'Tidak ada pendaftaran aktif') {
      return null;
    }

    rethrow;
  }
}


  static Future<StatusAntreanModel> getStatusAntreanModel({
    required String kodeLayanan,
    required String kodeDokter,
    String? nomorAntrean,
    String? tanggal,
  }) async {
    final response = await getStatusAntrean(
      kodeLayanan: kodeLayanan,
      kodeDokter: kodeDokter,
      nomorAntrean: nomorAntrean,
      tanggal: tanggal,
    );

    if (response['status'] != true) {
      throw const SimrsApiException(message: 'Gagal mengambil status antrean.');
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const SimrsApiException(
        message: 'Format data status antrean tidak sesuai.',
      );
    }

    return StatusAntreanModel.fromJson(data);
  }
}
