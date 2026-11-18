import 'package:dio/dio.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/pasien_model.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/services/mock/pendaftaran_mock_data.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';

/// Service Terpusat Alur Pendaftaran Rawat Jalan RS PKU Gamping.
///
/// Menyediakan abstraksi data terpadu (Dual-Mode: Online REST API & Offline Mock Fallback)
/// sehingga komponen UI tidak terikat langsung (*decoupled*) dengan data dummy statis.
class PendaftaranService {
  PendaftaranService._();

  static Dio get _dio => ApiClient.dio;

  /// Mengambil daftar seluruh poli rawat jalan dari SIMRS
  static Future<List<PoliModel>> getListPoli() async {
    try {
      final response = await _dio.get('/layanan/list');
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawData = body['data'];
        if (rawData is List) {
          return rawData
              .map((json) => PoliModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.data is List) {
        return (response.data as List)
            .map((json) => PoliModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat daftar poli: $e');
    }
  }

  /// Mengambil daftar dokter dari backend SIMRS berdasarkan poli ([poliId] / `fs_kd_layanan`)
  static Future<List<DokterPendaftaranModel>> getListDokter({String? poliId}) async {
    if (poliId == null || poliId.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/dokter/list',
        queryParameters: {'fs_kd_layanan': poliId.trim()},
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawData = body['data'];
        if (rawData is List) {
          return rawData
              .map((json) => DokterPendaftaranModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.data is List) {
        return (response.data as List)
            .map((json) => DokterPendaftaranModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat daftar dokter: $e');
    }
  }

  /// Mengambil daftar jadwal dokter SIMRS untuk rentang 45 hari ke depan
  static Future<List<JadwalSlotModel>> getJadwalDokter({
    required String poliId,
    required String dokterId,
  }) =>
      SimrsService.getJadwalDokter(
        fsKdLayanan: poliId,
        fsKdPetugasMedis: dokterId,
      );

  /// Mengirim booking pendaftaran rawat jalan ke backend (`POST /booking/simpan`).
  ///
  /// Mengembalikan map ternormalisasi berisi `fn_no_urut`, `fs_kd_antrian`,
  /// `no_booking`, dan `message`, sekaligus menyimpan `fs_kd_antrian` ke [SessionManager].
  static Future<Map<String, dynamic>> simpanBooking({
    required String fsMr,
    required String fdTglLahir,
    required String fsKdLayanan,
    required String fsKdPetugasMedis,
    required String fnHari,
    required String fdTglAntrian,
    required String fsKdSesionPoli,
    required String fsJamMulai,
  }) async {
    final payload = {
      'fs_mr': fsMr.trim(),
      'fd_tgl_lahir': fdTglLahir.trim(),
      'fs_kd_layanan': fsKdLayanan.trim(),
      'fs_kd_petugas_medis': fsKdPetugasMedis.trim(),
      'fn_hari': fnHari.trim(),
      'fd_tgl_antrian': fdTglAntrian.trim(),
      'fs_kd_sesion_poli': fsKdSesionPoli.trim(),
      'fs_jam_mulai': fsJamMulai.trim(),
    };

    try {
      final response = await _dio.post('/booking/simpan', data: payload);
      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      if (body['status'] == false) {
        throw Exception(
          body['message']?.toString() ?? 'Booking gagal diproses oleh server.',
        );
      }

      final dataObj = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      final noUrutRaw =
          dataObj['fn_no_urut'] ?? dataObj['no_urut'] ?? body['fn_no_urut'] ?? body['no_urut'];
      final fnNoUrut = noUrutRaw != null ? noUrutRaw.toString().trim() : '';

      final fsKdAntrian = (dataObj['fs_kd_antrian'] ??
              dataObj['no_antrian'] ??
              body['fs_kd_antrian'] ??
              body['no_antrian'] ??
              '')
          .toString()
          .trim();

      final noBooking = (dataObj['no_booking'] ??
              dataObj['fs_kd_trs'] ??
              body['no_booking'] ??
              '')
          .toString()
          .trim();

      if (fsKdAntrian.isNotEmpty) {
        await SessionManager.setActiveBooking(
          fsKdAntrian: fsKdAntrian,
          noBooking: noBooking,
          noUrut: fnNoUrut,
        );
      }

      return {
        'status': body['status'] ?? true,
        'message': body['message']?.toString() ?? 'Booking berhasil',
        'fn_no_urut': fnNoUrut,
        'no_urut': noUrutRaw,
        'fs_kd_antrian': fsKdAntrian,
        'no_booking': noBooking,
        'raw': body,
      };
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal menyimpan booking pendaftaran. Silakan coba lagi.',
      );
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal menyimpan booking: $e');
    }
  }

  /// [DEPRECATED] Registrasi BPJS dinonaktifkan karena aplikasi ini
  /// murni untuk pendaftaran online pasien mandiri (Non-BPJS).
  ///
  /// Alur pendaftaran mandiri langsung tuntas pada [simpanBooking] (`POST /booking/simpan`).
  @Deprecated('Aplikasi PKU Gamping Mobile murni untuk pasien mandiri (Non-BPJS).')
  static Future<Map<String, dynamic>> registrasiBpjs({
    required String fsKdTrs,
    required String fsMr,
    required String fsNoHp,
    required String fsKdIdentitas,
    required String fsKdReff,
  }) async {
    return {
      'status': true,
      'message': 'Registrasi BPJS dinonaktifkan (Pasien Mandiri)',
    };
  }

  /// Mengambil data pendaftaran / booking aktif dari SIMRS (`GET /booking/aktif`)
  static Future<AntreanAktifModel?> getBookingAktif() =>
      AntreanService.getBookingAktif();

  /// Mengambil status antrean poli real-time dari SIMRS (`GET /antrean/status`)
  static Future<Map<String, dynamic>?> getStatusAntrean({
    required String fsKdLayanan,
    required String fsKdPetugasMedis,
    String? fsKdAntrian,
    String? fsMr,
    String? tanggal,
  }) =>
      AntreanService.getStatusAntrean(
        fsKdLayanan: fsKdLayanan,
        fsKdPetugasMedis: fsKdPetugasMedis,
        fsKdAntrian: fsKdAntrian,
        fsMr: fsMr,
        tanggal: tanggal,
      );

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
}
