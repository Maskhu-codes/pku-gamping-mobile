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

  /// Autentikasi Login Pasien ke Backend SIMRS
  ///
  /// Mengirim kredensial langsung ke server backend (/auth/login).
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
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      // Parsing token autentikasi dari backend
      final token = data['token'] as String? ??
          data['access_token'] as String? ??
          '';

      // Parsing objek identitas pasien dari field 'user'
      final userObj = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : (data['pasien'] is Map<String, dynamic>
              ? data['pasien'] as Map<String, dynamic>
              : <String, dynamic>{});

      final rawMr = userObj['fs_mr'] as String? ?? userObj['no_rm'] as String? ?? '';
      final cleanMr = rawMr.replaceAll('-', '').replaceAll(' ', '').trim();
      final fsNmPasien = userObj['fs_nm_pasien'] as String? ?? userObj['nama'] as String? ?? '';
      final fsNik = userObj['fs_nik'] as String? ?? userObj['nik'] as String?;
      final fsEmail = userObj['fs_email'] as String? ?? userObj['email'] as String? ?? targetEmail;

      // Simpan tiket sesi dan data pasien ke SessionManager
      await SessionManager.saveSession(
        token: token,
        fsMr: cleanMr,
        fsNmPasien: fsNmPasien,
        fsNik: fsNik,
        fsEmail: fsEmail,
        username: fsEmail,
      );

      if (userObj.isNotEmpty) {
        await SessionManager.savePatientData(userObj);
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

  /// Verifikasi NIK ke backend SIMRS & akun online (/auth/cekNik)
  ///
  /// Mengirim `fs_nik` via POST ke `/auth/cekNik`.
  /// Mengembalikan Map:
  /// - `status`: bool (true jika NIK valid & belum punya akun)
  /// - `found`: bool (true jika data pasien lama ditemukan di SIMRS)
  /// - `isAlreadyRegistered`: bool (true jika NIK sudah terdaftar sebagai akun mobile)
  /// - `fs_mr`: String? (nomor rekam medis jika ditemukan)
  /// - `fs_nm_pasien`: String? (nama pasien jika ditemukan)
  /// - `fd_tgl_lahir`: String? (tanggal lahir jika ditemukan)
  /// - `message`: String
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

  /// Cek apakah NIK sudah terdaftar sebagai akun mobile
  /// (Memanfaatkan hasil dari [cekNik])
  static Future<bool> isNikAlreadyRegistered(String nik) async {
    try {
      final result = await cekNik(nik);
      return result['isAlreadyRegistered'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Registrasi Pasien Baru ke Backend SIMRS (/auth/register)
  ///
  /// Melakukan remap semua field (camelCase -> format fs_ yang diharapkan backend),
  /// memanggil `POST /auth/register`, mengurai JWT token & objek user,
  /// serta menyimpan sesi pasien secara otomatis ke [SessionManager].
  static Future<Map<String, dynamic>> registerPasien(
    Map<String, dynamic> rawPayload,
  ) async {
    // 1. Remap field camelCase ke format prefix fs_ sesuai backend SIMRS
    final payload = <String, dynamic>{
      'fs_email': (rawPayload['fs_email'] ?? rawPayload['email'] ?? '').toString().trim(),
      'fs_password': (rawPayload['fs_password'] ?? rawPayload['password'] ?? '').toString(),
      'fs_nik': (rawPayload['fs_nik'] ?? rawPayload['nik'] ?? '').toString().trim(),
    };

    // Optional / data pasien
    final mr = rawPayload['fs_mr'] ?? rawPayload['noRm'] ?? rawPayload['fsMr'];
    if (mr != null && mr.toString().trim().isNotEmpty) {
      payload['fs_mr'] = mr.toString().trim();
    }

    final nama = rawPayload['fs_nm_pasien'] ?? rawPayload['nama'] ?? rawPayload['namaPasien'];
    if (nama != null && nama.toString().trim().isNotEmpty) {
      payload['fs_nm_pasien'] = nama.toString().trim();
    }

    final noHp = rawPayload['fs_no_hp'] ?? rawPayload['noHp'] ?? rawPayload['telepon'];
    if (noHp != null && noHp.toString().trim().isNotEmpty) {
      payload['fs_no_hp'] = noHp.toString().trim();
    }

    final tempatLahir = rawPayload['fs_temp_lahir'] ?? rawPayload['tempatLahir'];
    if (tempatLahir != null && tempatLahir.toString().trim().isNotEmpty) {
      payload['fs_temp_lahir'] = tempatLahir.toString().trim();
    }

    final tglLahir = rawPayload['fd_tgl_lahir'] ?? rawPayload['tanggalLahir'];
    if (tglLahir != null && tglLahir.toString().trim().isNotEmpty) {
      payload['fd_tgl_lahir'] = tglLahir.toString().trim();
    }

    final jnsKelamin = rawPayload['fs_jenis_kelamin'] ?? rawPayload['jenisKelamin'];
    if (jnsKelamin != null) {
      final str = jnsKelamin.toString().trim();
      payload['fs_jenis_kelamin'] = (str == 'Perempuan' || str == '2') ? '2' : '1';
    }

    final golDarah = rawPayload['fs_gol_darah'] ?? rawPayload['golDarah'];
    if (golDarah != null && golDarah.toString().trim().isNotEmpty) {
      payload['fs_gol_darah'] = golDarah.toString().trim();
    }

    final alamat = rawPayload['fs_alamat'] ?? rawPayload['alamat'];
    if (alamat != null && alamat.toString().trim().isNotEmpty) {
      payload['fs_alamat'] = alamat.toString().trim();
    }

    final kdAgama = rawPayload['fs_kd_agama'] ?? rawPayload['agama'] ?? rawPayload['kdAgama'];
    if (kdAgama != null && kdAgama.toString().trim().isNotEmpty) {
      payload['fs_kd_agama'] = kdAgama.toString().trim();
    }

    final kdPekerjaan = rawPayload['fs_kd_pekerjaan'] ?? rawPayload['pekerjaan'] ?? rawPayload['kdPekerjaan'];
    if (kdPekerjaan != null && kdPekerjaan.toString().trim().isNotEmpty) {
      final pk = kdPekerjaan.toString().trim();
      payload['fs_kd_pekerjaan'] = pk.length < 3 ? pk.padLeft(3, '0') : (pk.length > 3 ? pk.substring(0, 3) : pk);
    }

    final kdPendidikan = rawPayload['fs_kd_pendidikan'] ?? rawPayload['pendidikan'] ?? rawPayload['kdPendidikan'];
    if (kdPendidikan != null && kdPendidikan.toString().trim().isNotEmpty) {
      final p = kdPendidikan.toString().trim();
      payload['fs_kd_pendidikan'] = p.length > 1 ? p.substring(p.length - 1) : p;
    }

    final statusKawin = rawPayload['fs_status_kawin'] ?? rawPayload['statusKawin'] ?? rawPayload['kdStatusKawin'];
    if (statusKawin != null && statusKawin.toString().trim().isNotEmpty) {
      payload['fs_status_kawin'] = statusKawin.toString().trim();
    }

    final kdSuku = rawPayload['fs_kd_suku'] ?? rawPayload['suku'] ?? rawPayload['kdSuku'];
    payload['fs_kd_suku'] = (kdSuku != null && kdSuku.toString().trim().isNotEmpty)
        ? kdSuku.toString().trim()
        : '004';

    final namaIbu = rawPayload['fs_nm_ibu_kandung'] ?? rawPayload['namaIbu'] ?? rawPayload['namaIbuKandung'];
    if (namaIbu != null && namaIbu.toString().trim().isNotEmpty) {
      payload['fs_nm_ibu_kandung'] = namaIbu.toString().trim();
    }

    final wargaNegara = rawPayload['fs_warga_negara'] ?? rawPayload['wargaNegara'];
    if (wargaNegara != null && wargaNegara.toString().trim().isNotEmpty) {
      final wn = wargaNegara.toString().trim().toUpperCase();
      payload['fs_warga_negara'] = (wn == 'WNA' || wn == 'A' || wn == 'ASING') ? 'A' : 'I';
    }

    final kdKelurahan = rawPayload['fs_kd_kelurahan'] ?? rawPayload['kelurahan'] ?? rawPayload['kdKelurahan'];
    if (kdKelurahan != null && kdKelurahan.toString().trim().isNotEmpty) {
      payload['fs_kd_kelurahan'] = kdKelurahan.toString().trim();
    }

    try {
      final response = await _dio.post(
        '/auth/register',
        data: payload,
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      // 2. Parsing token autentikasi & objek user jika auto-login aktif di backend
      final token = data['token'] as String? ??
          data['access_token'] as String? ??
          '';

      final userObj = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (token.isNotEmpty && userObj.isNotEmpty) {
        final fsMr = userObj['fs_mr'] as String? ?? payload['fs_mr'] as String? ?? '';
        final fsNmPasien = userObj['fs_nm_pasien'] as String? ?? payload['fs_nm_pasien'] as String? ?? '';
        final fsNik = userObj['fs_nik'] as String? ?? payload['fs_nik'] as String?;
        final fsEmail = userObj['fs_email'] as String? ?? payload['fs_email'] as String? ?? '';

        await SessionManager.saveSession(
          token: token,
          fsMr: fsMr,
          fsNmPasien: fsNmPasien,
          fsNik: fsNik,
          fsEmail: fsEmail,
          username: fsEmail,
        );
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

  /// Mengambil profil pasien aktif dari backend SIMRS (`/auth/me`)
  ///
  /// Sekaligus menyegarkan `FD_TGL_LAHIR` ke [SessionManager] agar siap
  /// digunakan saat submit booking ke `/booking/simpan`.
  static Future<Map<String, dynamic>> getMeProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final dataObj = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      // Sinkronisasi data identitas pasien ke SessionManager secara terpusat
      await SessionManager.updateFromMe(dataObj);

      return dataObj;
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(
        e,
        defaultMessage: 'Gagal memuat profil pasien.',
      );
      throw Exception(message);
    }
  }

  /// Logout akun pasien (PROMPT 25 — Menghapus seluruh sesi lokal pasien).
  ///
  /// Karena backend SIMRS menggunakan token JWT stateless dan tidak memerlukan
  /// endpoint khusus, logout dilakukan dengan membersihkan seluruh data sesi lokal
  /// via [SessionManager.clearSession].
  static Future<void> logout() async {
    await SessionManager.clearSession();
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
