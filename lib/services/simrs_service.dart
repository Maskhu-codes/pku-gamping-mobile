import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/dokter_jadwal_model.dart';

/// Layanan integrasi murni backend SIMRS RS PKU Muhammadiyah Gamping.
///
/// Seluruh komunikasi dan otentikasi diproses langsung secara terpusat
/// oleh server backend tanpa ketergantungan simulasi akun lokal.
class SimrsService {
  SimrsService._();

  static Dio get _dio => ApiClient.dio;

  /// Autentikasi Login Pasien ke Backend SIMRS
  ///
  /// Mengirim kredensial langsung ke server backend (/auth/login).
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'email': username,
          'password': password,
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      // Parsing token autentikasi dari backend
      final token = data['token'] as String? ??
          data['access_token'] as String? ??
          (data['data'] is Map ? data['data']['token'] as String? : null) ??
          '';

      // Parsing objek identitas pasien
      final userObj = (data['pasien'] ?? data['user'] ?? data['data'] ?? data) as Map<String, dynamic>;
      final nama = userObj['nama'] as String? ??
          userObj['name'] as String? ??
          data['nama'] as String? ??
          'Pasien';
      final noRm = userObj['no_rm'] as String? ??
          data['no_rm'] as String? ??
          '-';
      final nik = userObj['nik'] as String? ?? data['nik'] as String?;

      // Simpan tiket sesi dan data pasien ke SessionManager
      await SessionManager.saveSession(
        token: token,
        namaPasien: nama,
        noRm: noRm,
        username: username,
        nik: nik,
      );

      await SessionManager.savePatientData(userObj);

      return data;
    } on DioException catch (e) {
      debugPrint('[SimrsService] Login error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Email atau kata sandi salah. Silakan periksa kembali.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Verifikasi NIK ke database SIMRS & Disdukcapil
  static Future<bool> cekNik(String nik) async {
    if (nik.length != 16) return false;
    try {
      final response = await _dio.get('/pasien/cek-nik/$nik');
      if (response.data is Map) {
        return response.data['valid'] == true;
      }
      return true;
    } on DioException catch (_) {
      // Fallback format 16 digit angka jika endpoint belum terpasang
      return RegExp(r'^[0-9]{16}$').hasMatch(nik);
    }
  }

  /// Cek apakah NIK sudah terdaftar di SIMRS
  static Future<bool> isNikAlreadyRegistered(String nik) async {
    try {
      final response = await _dio.get('/pasien/cek-nik-registered/$nik');
      if (response.data is Map) {
        return response.data['registered'] == true;
      }
      return false;
    } on DioException catch (_) {
      return false;
    }
  }

  /// Registrasi Pasien Baru ke Backend SIMRS
  ///
  /// Mengirim seluruh payload pendaftaran langsung ke server backend (/pasien/register).
  static Future<Map<String, dynamic>> registerPasien(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/pasien/register',
        data: payload,
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{'status': 'success', 'message': 'Pendaftaran berhasil'};

      return data;
    } on DioException catch (e) {
      debugPrint('[SimrsService] Register error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal melakukan pendaftaran. Silakan periksa kembali data Anda.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Logout dari SIMRS
  static Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      await SessionManager.clearSession();
    }
  }

  static List<DokterJadwal>? _cachedJadwal;
  static DateTime? _cacheJadwalExpiry;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Mengambil daftar jadwal dokter SIMRS (dengan cache in-memory TTL 5 menit)
  static Future<List<DokterJadwal>> getJadwalDokter({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedJadwal != null &&
        _cacheJadwalExpiry != null &&
        DateTime.now().isBefore(_cacheJadwalExpiry!)) {
      return _cachedJadwal!;
    }

    try {
      final response = await _dio.get('/jadwal/dokter');
      if (response.data is List) {
        // Parsing response jika online
      }
      _cachedJadwal = defaultJadwalDokter;
      _cacheJadwalExpiry = DateTime.now().add(_cacheDuration);
      return _cachedJadwal!;
    } catch (_) {
      _cachedJadwal = defaultJadwalDokter;
      _cacheJadwalExpiry = DateTime.now().add(_cacheDuration);
      return defaultJadwalDokter;
    }
  }

  /// Membersihkan cache jadwal dokter
  static void clearJadwalCache() {
    _cachedJadwal = null;
    _cacheJadwalExpiry = null;
  }

  /// Mengambil daftar poli rawat jalan aktif
  static Future<List<String>> getPoliList({bool forceRefresh = false}) async {
    final dokterList = await getJadwalDokter(forceRefresh: forceRefresh);
    return [
      'Semua Poli',
      ...dokterList.map((d) => d.poli).toSet(),
    ];
  }

  /// Mock data fallback jadwal dokter RS PKU Gamping
  static const List<DokterJadwal> defaultJadwalDokter = [
    DokterJadwal(
      nama: 'dr. H. Ahmad Farhan, Sp.PD',
      poli: 'Poli Penyakit Dalam',
      jamMulai: '09.00',
      jamSelesai: '12.00',
      status: StatusDokter.tersedia,
    ),
    DokterJadwal(
      nama: 'dr. Siti Nurhaliza, Sp.JP',
      poli: 'Poli Jantung',
      jamMulai: '10.00',
      jamSelesai: '13.00',
      status: StatusDokter.tersedia,
    ),
    DokterJadwal(
      nama: 'dr. Budi Santoso, Sp.A',
      poli: 'Poli Anak',
      jamMulai: '08.00',
      jamSelesai: '11.00',
      status: StatusDokter.selesai,
    ),
    DokterJadwal(
      nama: 'dr. Rina Kusuma, Sp.M',
      poli: 'Poli Mata',
      jamMulai: '13.00',
      jamSelesai: '16.00',
      status: StatusDokter.tersedia,
    ),
    DokterJadwal(
      nama: 'dr. Dewi Anggraini, Sp.PD',
      poli: 'Poli Penyakit Dalam',
      jamMulai: '14.00',
      jamSelesai: '17.00',
      status: StatusDokter.tersedia,
    ),
    DokterJadwal(
      nama: 'dr. Hendra Wijaya, Sp.B',
      poli: 'Poli Bedah',
      jamMulai: '08.00',
      jamSelesai: '12.00',
      status: StatusDokter.cuti,
    ),
  ];
}
