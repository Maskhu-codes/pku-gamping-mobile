import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/dokter_jadwal_model.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';

/// Layanan integrasi murni backend SIMRS RS PKU Muhammadiyah Gamping.
///
/// Seluruh komunikasi dan otentikasi diproses langsung secara terpusat
/// oleh server backend tanpa ketergantungan simulasi akun lokal.
class SimrsService {
  SimrsService._();

  static Dio get _dio => ApiClient.dio;

  /// Autentikasi Login Pasien ke Backend SIMRS (/auth/login)
  static Future<Map<String, dynamic>> login({
    String? email,
    String? username,
    required String password,
  }) async {
    final targetEmail = (email ?? username ?? '').trim();
    final targetPassword = password.trim();
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'fs_email': targetEmail,
          'fs_password': targetPassword,
          'username': targetEmail,
          'email': targetEmail,
          'password': targetPassword,
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
          '';

      if (token.isEmpty) {
        throw Exception('Token autentikasi tidak ditemukan dari respon server backend.');
      }

      // 3. Parsing objek identitas pasien dari respon login awal
      final userObj = (data['user'] ?? data['pasien'] ?? data['data'] ?? data) is Map<String, dynamic>
          ? Map<String, dynamic>.from((data['user'] ?? data['pasien'] ?? data['data'] ?? data) as Map)
          : <String, dynamic>{};

      final simrsObj = userObj['simrs'] as Map<String, dynamic>?;
      final rawMr = userObj['fs_mr'] as String? ??
          simrsObj?['FS_MR'] as String? ??
          userObj['no_rm'] as String? ??
          data['no_rm'] as String? ??
          '';
      final cleanMr = rawMr.replaceAll('-', '').replaceAll(' ', '').trim();
      final fsNmPasien = simrsObj?['FS_NM_PASIEN']?.toString() ??
          userObj['fs_nm_pasien']?.toString() ??
          userObj['nama']?.toString() ??
          userObj['name']?.toString() ??
          data['nama']?.toString() ??
          'Pasien';
      final fsNik = userObj['fs_nik']?.toString() ??
          simrsObj?['FS_KD_IDENTITAS']?.toString() ??
          userObj['nik']?.toString() ??
          data['nik']?.toString();
      final fsEmail = userObj['fs_email'] as String? ??
          userObj['email'] as String? ??
          targetEmail;

      // 4. Simpan tiket sesi awal ke SessionManager
      await SessionManager.saveSession(
        token: token,
        fsMr: cleanMr,
        fsNmPasien: fsNmPasien,
        fsNik: fsNik,
        fsEmail: fsEmail,
        username: fsEmail,
      );

      if (fsNik != null && fsNik.isNotEmpty) {
        final cachedNikProfile = SessionManager.getProfileByNik(fsNik);
        if (cachedNikProfile != null) {
          userObj.addAll(cachedNikProfile);
        }
      }

      if (userObj.isNotEmpty) {
        await SessionManager.savePatientData(userObj);
      }

      // 5. Alur Pengiriman Balik Token ke Backend (/auth/me):
      // Sinkronisasi data profil SIMRS lengkap via /auth/me
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
          if (nik != null && nik.isNotEmpty) {
            final cachedNikProfile = SessionManager.getProfileByNik(nik);
            if (cachedNikProfile != null) {
              userData.addAll(cachedNikProfile);
            }
          }

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

  /// Alias getMeProfile untuk kompatibilitas
  static Future<Map<String, dynamic>?> getMeProfile() => checkSession();

  /// Verifikasi NIK ke backend SIMRS & akun online (/auth/cekNik)
  static Future<Map<String, dynamic>> cekNik(String nik) async {
    final cleanNik = nik.trim();
    if (cleanNik.length != 16) {
      throw Exception('Nomor NIK harus terdiri dari 16 digit angka.');
    }

    try {
      final response = await _dio.post(
        '/auth/cekNik',
        data: {'fs_nik': cleanNik},
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final status = data['status'] == true;
      final message = data['message'] as String? ?? '';

      // Kasus 1: NIK sudah terdaftar sebagai akun mobile (status == false)
      if (!status) {
        return {
          'status': false,
          'isAlreadyRegistered': true,
          'found': false,
          'fs_mr': null,
          'fs_nm_pasien': null,
          'fd_tgl_lahir': null,
          'message': message,
        };
      }

      // Kasus 2: NIK belum punya akun online, dicek ke database SIMRS
      final found = data['found'] == true;
      return {
        'status': true,
        'isAlreadyRegistered': false,
        'found': found,
        'fs_mr': data['fs_mr'] as String?,
        'fs_nm_pasien': data['fs_nm_pasien'] as String?,
        'fd_tgl_lahir': data['fd_tgl_lahir'] as String?,
        'message': message,
      };
    } on DioException catch (e) {
      debugPrint('[SimrsService] cekNik error: ${e.response?.statusCode} - ${e.message}');
      final errorMessage = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memeriksa NIK. Silakan periksa koneksi Anda.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Alias verifyNik untuk kompatibilitas
  static Future<Map<String, dynamic>> verifyNik(String nik) => cekNik(nik);

  /// Cek apakah NIK sudah terdaftar di SIMRS
  static Future<bool> isNikAlreadyRegistered(String nik) async {
    try {
      final res = await verifyNik(nik);
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
        defaultMessage: 'Gagal melakukan pendaftaran akun. Silakan periksa kembali data Anda.',
      );
      throw Exception(errorMessage);
    }
  }

  /// Logout dari SIMRS (/auth/logout)
  static Future<void> logout() async {
    await SessionManager.clearSession();
  }

  // ── Master Data Referensi SIMRS (Pekerjaan, Pendidikan, Status Kawin, Agama) ──

  /// Ambil daftar master pekerjaan dari SIMRS (GET /master/pekerjaan)
  static Future<List<Map<String, dynamic>>> getMasterPekerjaan() async {
    try {
      final res = await _dio.get('/master/pekerjaan');
      if (res.data is Map<String, dynamic> && res.data['data'] is List) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (e) {
      debugPrint('[SimrsService] getMasterPekerjaan error: $e');
    }
    return [];
  }

  /// Ambil daftar master pendidikan dari SIMRS (GET /master/pendidikan)
  static Future<List<Map<String, dynamic>>> getMasterPendidikan() async {
    try {
      final res = await _dio.get('/master/pendidikan');
      if (res.data is Map<String, dynamic> && res.data['data'] is List) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (e) {
      debugPrint('[SimrsService] getMasterPendidikan error: $e');
    }
    return [];
  }

  /// Ambil daftar master status kawin dari SIMRS (GET /master/status_kawin)
  static Future<List<Map<String, dynamic>>> getMasterStatusKawin() async {
    try {
      final res = await _dio.get('/master/status_kawin');
      if (res.data is Map<String, dynamic> && res.data['data'] is List) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (e) {
      debugPrint('[SimrsService] getMasterStatusKawin error: $e');
    }
    return [];
  }

  /// Ambil daftar master agama dari SIMRS (GET /master/agama)
  static Future<List<Map<String, dynamic>>> getMasterAgama() async {
    try {
      final res = await _dio.get('/master/agama');
      if (res.data is Map<String, dynamic> && res.data['data'] is List) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (e) {
      debugPrint('[SimrsService] getMasterAgama error: $e');
    }
    return [];
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

  /// Mengambil daftar jadwal dokter SIMRS untuk 45 hari ke depan
  ///
  /// Endpoint: GET /jadwal/list?fs_kd_layanan=X&fs_kd_petugas_medis=Y
  /// Mem-parse can_book, is_full, is_closed, dan status per tanggal
  static Future<List<JadwalSlotModel>> getJadwalDokter({
    String? fsKdLayanan,
    String? fsKdPetugasMedis,
    String? kdLayanan,
    String? kdDokter,
    bool forceRefresh = false,
  }) async {
    final layanan = (fsKdLayanan ?? kdLayanan ?? '').trim();
    final dokter = (fsKdPetugasMedis ?? kdDokter ?? '').trim();

    if (layanan.isEmpty || dokter.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/jadwal/list',
        queryParameters: {
          'fs_kd_layanan': layanan,
          'fs_kd_petugas_medis': dokter,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawData = body['data'];
        if (rawData is List) {
          return rawData
              .map((json) => JadwalSlotModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.data is List) {
        return (response.data as List)
            .map((json) => JadwalSlotModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat jadwal dokter: $e');
    }
  }

  /// Mengambil daftar poli rawat jalan aktif
  static Future<List<String>> getPoliList({bool forceRefresh = false}) async {
    return [
      'Semua Poli',
      ...defaultJadwalDokter.map((d) => d.poli).toSet(),
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
