import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/hasil_pemeriksaan_model.dart';
import 'package:pku_gamping_app/models/riwayat_pemeriksaan_model.dart';

export 'package:pku_gamping_app/models/hasil_pemeriksaan_model.dart';
export 'package:pku_gamping_app/models/riwayat_pemeriksaan_model.dart';

/// Layanan integrasi rekam medis penunjang & riwayat pemeriksaan SIMRS PKU Gamping.
class PemeriksaanPenunjangService {
  PemeriksaanPenunjangService._();

  static Dio get _dio => ApiClient.dio;

  /// Mengambil daftar riwayat pemeriksaan laboratorium pasien dari SIMRS
  /// (`GET /penunjang/laboratorium?fs_mr=<dari_session>&page=N`).
  static Future<List<LabResult>> getHasilLab({
    String? fsMr,
    int page = 1,
  }) async {
    final mr = (fsMr != null && fsMr.trim().isNotEmpty)
        ? fsMr.trim()
        : (SessionManager.fsMr.isNotEmpty
            ? SessionManager.fsMr
            : SessionManager.noRm);

    if (mr.isEmpty) {
      throw Exception('Nomor Rekam Medis (MR) tidak ditemukan.');
    }

    try {
      final response = await _dio.get(
        '/penunjang/laboratorium',
        queryParameters: {
          'fs_mr': mr,
          'page': page,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawList = body['data'];
        if (body['status'] == true && rawList is List) {
          return rawList
              .map((json) => LabResult.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (body['status'] == false) {
          final msg =
              body['message']?.toString() ?? 'Gagal memuat hasil laboratorium.';
          throw Exception(msg);
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[PemeriksaanPenunjangService] getHasilLab error: ${e.response?.statusCode} - ${e.message}');
      final msg = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat hasil laboratorium.',
      );
      throw Exception(msg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat hasil laboratorium: $e');
    }
  }

  /// Mengambil rincian detail parameter pemeriksaan laboratorium dari SIMRS
  /// (`GET /penunjang/laboratorium_detail?fs_kd_trs=X`).
  ///
  /// Mengembalikan daftar [LabParameterDetail] yang memuat parameter pemeriksaan,
  /// nilai hasil, satuan, rentang nilai rujukan, dan flag indikator (H/L/N).
  static Future<List<LabParameterDetail>> getLaboratoriumDetail(
    String fsKdTrs,
  ) async {
    final trs = fsKdTrs.trim();
    if (trs.isEmpty) {
      throw Exception('ID Transaksi laboratorium tidak boleh kosong.');
    }

    try {
      final response = await _dio.get(
        '/penunjang/laboratorium_detail',
        queryParameters: {'fs_kd_trs': trs},
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawList = body['data'];
        if (body['status'] == true && rawList is List) {
          return rawList
              .map((json) =>
                  LabParameterDetail.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (body['status'] == false) {
          final msg =
              body['message']?.toString() ?? 'Gagal memuat detail laboratorium.';
          throw Exception(msg);
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[PemeriksaanPenunjangService] getLaboratoriumDetail error: ${e.response?.statusCode} - ${e.message}');
      final msg = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat detail laboratorium.',
      );
      throw Exception(msg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat detail laboratorium: $e');
    }
  }

  /// Mengambil daftar hasil pemeriksaan radiologi pasien dari SIMRS
  /// (`GET /penunjang/radiologi?fs_mr=<dari_session>`).
  static Future<List<RadiologyResult>> getHasilRadiologi({String? fsMr}) async {
    final String mr;
    if (fsMr != null) {
      mr = fsMr.trim();
    } else {
      mr = SessionManager.fsMr.isNotEmpty
          ? SessionManager.fsMr
          : SessionManager.noRm;
    }

    if (mr.isEmpty) {
      throw Exception('Nomor Rekam Medis (MR) tidak ditemukan.');
    }

    try {
      final response = await _dio.get(
        '/penunjang/radiologi',
        queryParameters: {
          'fs_mr': mr,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawList = body['data'];
        if (body['status'] == true && rawList is List) {
          return rawList
              .map((json) =>
                  RadiologyResult.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (body['status'] == false) {
          final msg =
              body['message']?.toString() ?? 'Gagal memuat hasil radiologi.';
          throw Exception(msg);
        }
      } else if (response.data is List) {
        return (response.data as List)
            .map((json) =>
                RadiologyResult.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[PemeriksaanPenunjangService] getHasilRadiologi error: ${e.response?.statusCode} - ${e.message}');
      final msg = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat hasil radiologi.',
      );
      throw Exception(msg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat hasil radiologi: $e');
    }
  }

  /// Mengambil data riwayat pemeriksaan pasien dengan paginasi / lazy loading
  /// dari backend SIMRS (`GET /riwayat/list?fs_mr=<dari_session>&page=N`).
  ///
  /// Mengembalikan [RiwayatPaginationModel] berisi:
  /// - `items`: daftar [RiwayatPemeriksaan] (maksimal 10 item per halaman)
  /// - `currentPage`: nomor halaman saat ini
  /// - `totalPages`: total halaman tersedia
  /// - `totalItems`: total riwayat tercatat di SIMRS
  /// - `hasNext`: `true` jika masih terdapat halaman berikutnya
  static Future<RiwayatPaginationModel> getRiwayatPemeriksaanPaged({
    String? fsMr,
    int page = 1,
  }) async {
    final mr = (fsMr != null && fsMr.trim().isNotEmpty)
        ? fsMr.trim()
        : (SessionManager.fsMr.isNotEmpty
            ? SessionManager.fsMr
            : SessionManager.noRm);

    if (mr.isEmpty) {
      throw Exception('Nomor Rekam Medis (MR) tidak ditemukan.');
    }

    try {
      final response = await _dio.get(
        '/riwayat/list',
        queryParameters: {
          'fs_mr': mr,
          'page': page,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        if (body['status'] == true) {
          return RiwayatPaginationModel.fromJson(body);
        } else {
          final msg = body['message']?.toString() ??
              'Gagal memuat riwayat pemeriksaan.';
          throw Exception(msg);
        }
      }
      return const RiwayatPaginationModel();
    } on DioException catch (e) {
      final msg = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat riwayat pemeriksaan.',
      );
      throw Exception(msg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat riwayat pemeriksaan: $e');
    }
  }

  /// Mengambil daftar riwayat pemeriksaan (halaman 1 secara default atau halaman spesifik).
  static Future<List<RiwayatPemeriksaan>> getRiwayatPemeriksaan({
    String? fsMr,
    int page = 1,
  }) async {
    final pagination = await getRiwayatPemeriksaanPaged(
      fsMr: fsMr,
      page: page,
    );
    return pagination.items;
  }

  // ─── Default Mock Data untuk Fallback Offline Penunjang ───

  static const List<LabResult> defaultHasilLab = [
    LabResult(
      title: 'Pemeriksaan Hemoglobin',
      date: '19 Oktober 2026',
      time: '09:30 WIB',
    ),
    LabResult(
      title: 'Pemeriksaan Leukosit',
      date: '19 Oktober 2026',
      time: '10:00 WIB',
    ),
  ];

  static const List<RadiologyResult> defaultHasilRadiologi = [
    RadiologyResult(
      title: 'Pemeriksaan Rontgen Thorax',
      date: '18 Oktober 2026',
      time: '11:00 WIB',
    ),
    RadiologyResult(
      title: 'Pemeriksaan USG Abdomen',
      date: '17 Oktober 2026',
      time: '08:30 WIB',
    ),
  ];
}
