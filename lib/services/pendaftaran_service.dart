import 'package:dio/dio.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/models/pasien_model.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';
import 'package:pku_gamping_app/services/mock/pendaftaran_mock_data.dart';

/// Service Terpusat Alur Pendaftaran Rawat Jalan RS PKU Gamping.
///
/// Menyediakan abstraksi data terpadu (Dual-Mode: Online REST API & Offline Mock Fallback)
/// sehingga komponen UI tidak terikat langsung (*decoupled*) dengan data dummy statis.
class PendaftaranService {
  PendaftaranService._();

  static Dio get _dio => ApiClient.dio;

  /// Mengambil daftar seluruh poli rawat jalan
  static Future<List<PoliModel>> getListPoli() async {
    try {
      final response = await _dio.get('/pendaftaran/poli');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => PoliModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return PendaftaranDummyData.listPoli;
    } on DioException catch (_) {
      return PendaftaranDummyData.listPoli;
    } catch (_) {
      return PendaftaranDummyData.listPoli;
    }
  }

  /// Mengambil daftar dokter, dengan filter opsional berdasarkan [poliId]
  static Future<List<DokterPendaftaranModel>> getListDokter({String? poliId}) async {
    try {
      final response = await _dio.get(
        '/pendaftaran/dokter',
        queryParameters: poliId != null ? {'poli_id': poliId} : null,
      );
      if (response.data is List) {
        final list = (response.data as List)
            .map((json) =>
                DokterPendaftaranModel.fromJson(json as Map<String, dynamic>))
            .toList();
        if (poliId != null) {
          return list.where((d) => d.poliId == poliId).toList();
        }
        return list;
      }
      return _filterMockDokter(poliId);
    } on DioException catch (_) {
      return _filterMockDokter(poliId);
    } catch (_) {
      return _filterMockDokter(poliId);
    }
  }

  /// Mengambil daftar profil pasien yang tersimpan dalam akun
  static Future<List<PasienModel>> getListPasienTersimpan() async {
    try {
      final response = await _dio.get('/pasien/tersimpan');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => PasienModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return PendaftaranDummyData.listPasienTersimpan;
    } on DioException catch (_) {
      return PendaftaranDummyData.listPasienTersimpan;
    } catch (_) {
      return PendaftaranDummyData.listPasienTersimpan;
    }
  }

  static List<DokterPendaftaranModel> _filterMockDokter(String? poliId) {
    if (poliId == null) {
      return PendaftaranDummyData.listDokter;
    }
    return PendaftaranDummyData.listDokter
        .where((d) => d.poliId == poliId)
        .toList();
  }
}
