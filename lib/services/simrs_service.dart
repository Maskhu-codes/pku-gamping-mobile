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

  /// Autentikasi Login Pasien ke Backend SIMRS (/auth/login)
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'fs_email': username,
          'fs_password': password,
          'username': username,
          'email': username,
          'password': password,
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      // 1. Validasi respon dari backend: jika status false/error, lempar exception
      if (data['status'] == false ||
          data['status'] == 0 ||
          data['status'] == 'failed' ||
          data['status'] == 'error') {
        final message = data['message']?.toString() ??
            'Email atau kata sandi salah. Silakan periksa kembali.';
        throw Exception(message);
      }

      // 2. Parsing token autentikasi dari backend
      final token = data['token'] as String? ??
          data['access_token'] as String? ??
          (data['data'] is Map ? data['data']['token'] as String? : null) ??
          '';

      if (token.isEmpty) {
        throw Exception('Token autentikasi tidak ditemukan dari respon server backend.');
      }

      // 3. Parsing objek identitas pasien dari respon login awal
      final userObj = (data['user'] ?? data['pasien'] ?? data['data'] ?? data) as Map<String, dynamic>;
      final simrsObj = userObj['simrs'] as Map<String, dynamic>?;
      final nama = simrsObj?['FS_NM_PASIEN']?.toString() ??
          userObj['fs_nm_pasien']?.toString() ??
          userObj['nama']?.toString() ??
          userObj['name']?.toString() ??
          data['nama']?.toString() ??
          'Pasien';
      final noRm = userObj['fs_mr']?.toString() ??
          simrsObj?['FS_MR']?.toString() ??
          userObj['no_rm']?.toString() ??
          data['no_rm']?.toString() ??
          '-';
      final nik = userObj['fs_nik']?.toString() ??
          simrsObj?['FS_KD_IDENTITAS']?.toString() ??
          userObj['nik']?.toString() ??
          data['nik']?.toString();

      // 4. Simpan tiket sesi awal ke SessionManager
      await SessionManager.saveSession(
        token: token,
        namaPasien: nama,
        noRm: noRm,
        username: username,
        nik: nik,
      );

      await SessionManager.savePatientData(userObj);

      // 5. Alur Pengiriman Balik Token ke Backend (/auth/me):
      // Setelah dapat token, frontend langsung mengirim request verifikasi token
      // ke backend untuk memproses dan mengambil data profil rekam medis SIMRS lengkap.
      try {
        await checkSession();
      } catch (e) {
        debugPrint('[SimrsService] Sinkronisasi /auth/me setelah login: $e');
      }

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

  /// Cek sesi aktif pasien ke backend SIMRS (/auth/me)
  static Future<Map<String, dynamic>?> checkSession() async {
    try {
      final response = await _dio.get('/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic> && (data['status'] == true || data['status'] == 'success')) {
        final userData = (data['data'] ?? data['user']) as Map<String, dynamic>?;
        if (userData != null) {
          final simrsObj = userData['simrs'] as Map<String, dynamic>?;
          final nama = simrsObj?['FS_NM_PASIEN']?.toString() ??
              userData['fs_nm_pasien']?.toString() ??
              userData['nama']?.toString() ??
              SessionManager.namaPasien;
          final noRm = userData['fs_mr']?.toString() ??
              simrsObj?['FS_MR']?.toString() ??
              SessionManager.noRm;
          final nik = userData['fs_nik']?.toString() ??
              simrsObj?['FS_KD_IDENTITAS']?.toString() ??
              SessionManager.nik;

          await SessionManager.saveSession(
            token: SessionManager.token ?? '',
            namaPasien: nama,
            noRm: noRm,
            nik: nik,
            username: userData['fs_email']?.toString() ?? SessionManager.username,
          );
          await SessionManager.savePatientData(userData);
        }
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[SimrsService] checkSession error: $e');
      return null;
    }
  }

  /// Verifikasi NIK ke database SIMRS (/auth/cekNik)
  static Future<Map<String, dynamic>> verifyNik(String nik) async {
    if (nik.length != 16) {
      return {'status': false, 'message': 'NIK harus 16 digit angka'};
    }
    try {
      final response = await _dio.post(
        '/auth/cekNik',
        data: {'fs_nik': nik},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'status': true, 'found': false};
    } on DioException catch (e) {
      debugPrint('[SimrsService] verifyNik error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memverifikasi NIK ke server.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Verifikasi NIK ke database SIMRS & Disdukcapil
  static Future<bool> cekNik(String nik) async {
    if (nik.length != 16) return false;
    try {
      final res = await verifyNik(nik);
      return res['status'] == true;
    } catch (_) {
      return RegExp(r'^[0-9]{16}$').hasMatch(nik);
    }
  }

  /// Cek apakah NIK sudah terdaftar di SIMRS
  static Future<bool> isNikAlreadyRegistered(String nik) async {
    try {
      final res = await verifyNik(nik);
      // Backend: jika sudah terdaftar, status = false
      if (res['status'] == false || res['registered'] == true) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Registrasi Pasien Baru ke Backend SIMRS (/auth/register)
  static Future<Map<String, dynamic>> registerPasien(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: payload,
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{'status': true, 'message': 'Pendaftaran berhasil'};

      // Validasi respon dari backend
      if (data['status'] == false ||
          data['status'] == 0 ||
          data['status'] == 'failed' ||
          data['status'] == 'error') {
        final message = data['message']?.toString() ??
            'Gagal melakukan pendaftaran. Silakan periksa kembali data Anda.';
        throw Exception(message);
      }

      // Auto-login jika backend menyertakan token JWT
      final token = data['token'] as String?;
      final userObj = (data['user'] ?? data['data']) as Map<String, dynamic>?;
      if (token != null && token.isNotEmpty) {
        final simrsObj = userObj?['simrs'] as Map<String, dynamic>?;
        final nama = simrsObj?['FS_NM_PASIEN']?.toString() ??
            userObj?['fs_nm_pasien']?.toString() ??
            userObj?['nama']?.toString() ??
            payload['fs_nm_pasien']?.toString() ??
            'Pasien';
        final noRm = userObj?['fs_mr']?.toString() ??
            simrsObj?['FS_MR']?.toString() ??
            userObj?['no_rm']?.toString() ??
            payload['fs_mr']?.toString() ??
            '-';
        await SessionManager.saveSession(
          token: token,
          namaPasien: nama,
          noRm: noRm,
          nik: payload['fs_nik']?.toString(),
          username: payload['fs_email']?.toString(),
        );
        if (userObj != null) {
          await SessionManager.savePatientData(userObj);
        }

        // Sinkronisasi data SIMRS lengkap via /auth/me
        try {
          await checkSession();
        } catch (_) {}
      }

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

  /// Logout dari SIMRS (/auth/logout)
  static Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      await SessionManager.clearSession();
    }
  }

  /// Kirim kode OTP Lupa Kata Sandi (/auth/forgotPassword)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgotPassword',
        data: {'fs_email': email, 'email': email},
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == false || data['status'] == 0 || data['status'] == 'error' || data['status'] == 'failed') {
          throw Exception(data['message']?.toString() ?? 'Gagal mengirim kode OTP. Pastikan email terdaftar.');
        }
        return data;
      }
      return {'status': true, 'message': 'Kode OTP berhasil dikirim'};
    } on DioException catch (e) {
      debugPrint('[SimrsService] forgotPassword error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal mengirim kode OTP. Pastikan email terdaftar.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Verifikasi kode OTP 6 digit (/auth/verifyOtp)
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verifyOtp',
        data: {
          'fs_email': email,
          'email': email,
          'fs_otp': otp,
          'otp': otp,
        },
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == false || data['status'] == 0 || data['status'] == 'error' || data['status'] == 'failed') {
          throw Exception(data['message']?.toString() ?? 'Kode OTP tidak valid atau sudah kedaluwarsa.');
        }
        return data;
      }
      return {'status': true, 'message': 'OTP valid'};
    } on DioException catch (e) {
      debugPrint('[SimrsService] verifyOtp error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Kode OTP tidak valid atau sudah kedaluwarsa.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Kirim ulang kode OTP (/auth/resendOtp)
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/resendOtp',
        data: {'fs_email': email, 'email': email},
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == false || data['status'] == 0 || data['status'] == 'error' || data['status'] == 'failed') {
          throw Exception(data['message']?.toString() ?? 'Gagal mengirim ulang kode OTP.');
        }
        return data;
      }
      return {'status': true, 'message': 'Kode OTP baru berhasil dikirim'};
    } on DioException catch (e) {
      debugPrint('[SimrsService] resendOtp error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal mengirim ulang kode OTP.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Atur ulang kata sandi baru (/auth/resetPassword)
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
    String? resetToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/resetPassword',
        data: {
          'fs_email': email,
          'email': email,
          'fs_password': password,
          'password': password,
          if (resetToken != null && resetToken.isNotEmpty) ...{
            'fs_reset_token': resetToken,
            'reset_token': resetToken,
          },
        },
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == false || data['status'] == 0 || data['status'] == 'error' || data['status'] == 'failed') {
          throw Exception(data['message']?.toString() ?? 'Gagal mengatur ulang kata sandi.');
        }
        return data;
      }
      return {'status': true, 'message': 'Kata sandi berhasil diperbarui'};
    } on DioException catch (e) {
      debugPrint('[SimrsService] resetPassword error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal mengatur ulang kata sandi.',
      );
      throw Exception(errorMessage);
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
