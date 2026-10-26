import 'package:dio/dio.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/hasil_pemeriksaan_model.dart';
import 'package:pku_gamping_app/models/riwayat_pemeriksaan_model.dart';

/// Layanan integrasi rekam medis penunjang & riwayat pemeriksaan SIMRS PKU Gamping.
///
/// Menyediakan isolasi data (Dual-Mode: Online API & Offline Mock Fallback)
/// agar komponen UI tidak meng-hardcode data medis di tombol navigasi.
class PemeriksaanPenunjangService {
  PemeriksaanPenunjangService._();

  static Dio get _dio => ApiClient.dio;

  static String? _riwayatCacheToken;
  static bool _hasRiwayatCache = false;
  static List<RiwayatPemeriksaan>? _riwayatCache;
  static String? _riwayatRequestToken;
  static Future<List<RiwayatPemeriksaan>>? _riwayatRequest;

  /// Mengambil daftar hasil laboratorium pasien
  static Future<List<LabResult>> getHasilLab() async {
    try {
      final response = await _dio.get('/pasien/hasil-lab');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => LabResult.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return defaultHasilLab;
    } on DioException catch (_) {
      return defaultHasilLab;
    } catch (_) {
      return defaultHasilLab;
    }
  }

  /// Mengambil daftar hasil radiologi pasien
  static Future<List<RadiologyResult>> getHasilRadiologi() async {
    try {
      final response = await _dio.get('/pasien/hasil-radiologi');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => RadiologyResult.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return defaultHasilRadiologi;
    } on DioException catch (_) {
      return defaultHasilRadiologi;
    } catch (_) {
      return defaultHasilRadiologi;
    }
  }

  /// Mengambil riwayat pemeriksaan dokter rawat jalan
  static Future<List<RiwayatPemeriksaan>> getRiwayatPemeriksaan() {
    final token = SessionManager.token;
    if (_hasRiwayatCache && _riwayatCacheToken == token) {
      return Future.value(_riwayatCache!);
    }
    if (_riwayatRequest != null && _riwayatRequestToken == token) {
      return _riwayatRequest!;
    }

    _riwayatRequestToken = token;
    final request = _fetchRiwayatPemeriksaan(token);
    _riwayatRequest = request;
    return request;
  }

  static Future<List<RiwayatPemeriksaan>> _fetchRiwayatPemeriksaan(
    String? token,
  ) async {
    late final List<RiwayatPemeriksaan> riwayat;
    try {
      final response = await _dio.get('/pasien/riwayat-pemeriksaan');
      if (response.data is List) {
        riwayat = (response.data as List)
            .map((json) =>
                RiwayatPemeriksaan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        riwayat = defaultRiwayat;
      }
    } on DioException catch (_) {
      riwayat = defaultRiwayat;
    } catch (_) {
      riwayat = defaultRiwayat;
    }

    final result = List<RiwayatPemeriksaan>.unmodifiable(riwayat);
    if (SessionManager.token == token) {
      _riwayatCacheToken = token;
      _riwayatCache = result;
      _hasRiwayatCache = true;
    }
    if (_riwayatRequestToken == token) {
      _riwayatRequest = null;
    }
    return result;
  }

  // ─── Default Mock Data untuk Fallback Offline ───

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

  static const List<RiwayatPemeriksaan> defaultRiwayat = [
    RiwayatPemeriksaan(
      tanggal: '20 Oktober 2026',
      namaPemeriksaan: 'Pemeriksaan Umum',
      poli: 'Poli Penyakit Dalam',
      dokter: 'dr. Hendra Wicaksono, Sp.PD',
    ),
  ];
}
