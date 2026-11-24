import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manajer sesi lokal untuk autentikasi dan profil pasien RS PKU Gamping.
///
/// Menyimpan token autentikasi, status login, dan identitas pasien
/// menggunakan [SharedPreferences] secara aman dan persisten.
class SessionManager {
  SessionManager._();

  static SharedPreferences? _prefs;

  static const String _keyToken = 'pku_session_token';
  static const String _keyIsLoggedIn = 'pku_is_logged_in';
  static const String _keyNamaPasien = 'pku_nama_pasien';
  static const String _keyNoRm = 'pku_no_rm';
  static bool _isGuestMode = false;
  static const String _keyNik = 'pku_nik';
  static const String _keyEmail = 'pku_email';
  static const String _keyUsername = 'pku_username';
  static const String _keyPatientData = 'pku_patient_data';
  static const String _keyProfilePhotoPath = 'pku_profile_photo_path';
  static const String _keyNotificationEnabled = 'pku_notification_enabled';
  static const String _keyTglLahir = 'pku_tgl_lahir';
  static const String _keyNoHp = 'pku_no_hp';
  static const String _keyFsKdAntrian = 'pku_fs_kd_antrian';
  static const String _keyNoBooking = 'pku_no_booking';
  static const String _keyNoUrutAntrean = 'pku_no_urut_antrean';
  static const String _keyProfilePrefix = 'pku_profile_nik_';
  static const String _keyIsGuest = 'pku_is_guest';

  /// Notifier reaktif untuk foto profil pasien
  static final ValueNotifier<String?> profilePhotoNotifier =
      ValueNotifier<String?>(null);

  /// Inisialisasi SharedPreferences saat awal aplikasi berjalan
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    profilePhotoNotifier.value = _prefs?.getString(_keyProfilePhotoPath);
  }

  /// Memastikan _prefs telah terinisialisasi
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError(
        'SessionManager belum diinisialisasi. Panggil SessionManager.init() terlebih dahulu.',
      );
    }
    return _prefs!;
  }

  /// Cek status login pengguna
  static bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;

  /// Cek apakah pengguna saat ini masuk dalam Mode Tamu (Guest Mode)
  static bool get isGuest => _prefs?.getBool(_keyIsGuest) ?? false;

  /// Alias status Mode Tamu
  static bool get isGuestMode => isGuest;

  /// Atur status Mode Tamu (persisten)
  static Future<void> setGuestMode(bool value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    _isGuestMode = value;
    await p.setBool(_keyIsGuest, value);
  }

  /// Memvalidasi apakah sesi aktif dan memiliki token yang valid
  static bool hasValidSession() {
    final t = token;
    return isLoggedIn && t != null && t.trim().isNotEmpty;
  }

  /// Ambil JWT / Auth token
  static String? get token => _prefs?.getString(_keyToken);

  /// Ambil nomor rekam medis (fs_mr / noRm) yang bersih dari '-' dan spasi
  static String get fsMr {
    if (_isGuestMode) return '';
    return (_prefs?.getString(_keyNoRm) ?? '').replaceAll('-', '').replaceAll(' ', '').trim();
  }
  static String get noRm => fsMr;

  /// Ambil nama pasien (fs_nm_pasien)
  static String get fsNmPasien => _isGuestMode ? 'Tamu Pengunjung' : (_prefs?.getString(_keyNamaPasien) ?? '');
  static String get namaPasien {
    if (_isGuestMode) return 'Tamu Pengunjung';
    return _prefs?.getString(_keyNamaPasien) ?? 'Dahlan Muda';
  }

  /// Ambil NIK pasien (fs_nik)
  static String? get fsNik => _prefs?.getString(_keyNik);
  static String? get nik => _prefs?.getString(_keyNik);

  /// Ambil email pasien (fs_email)
  static String? get fsEmail => _prefs?.getString(_keyEmail);
  static String? get email => _prefs?.getString(_keyEmail);

  /// Ambil username
  static String? get username => _prefs?.getString(_keyUsername);

  /// Ambil tanggal lahir pasien (`FD_TGL_LAHIR`, format YYYY-MM-DD)
  static String? get fdTglLahir => _prefs?.getString(_keyTglLahir);

  /// Ambil nomor HP / telepon pasien (`FS_TLP_PASIEN` / `FS_NO_HP`)
  static String? get noHp => _prefs?.getString(_keyNoHp);

  /// Ambil kode antrean aktif dari backend (`fs_kd_antrian` / `no_antrian`)
  static String? get fsKdAntrian => _prefs?.getString(_keyFsKdAntrian);

  /// Ambil nomor booking aktif dari backend (`no_booking`)
  static String? get noBooking => _prefs?.getString(_keyNoBooking);

  /// Ambil nomor urut antrean aktif (`fn_no_urut` / `no_urut`)
  static String? get noUrutAntrean => _prefs?.getString(_keyNoUrutAntrean);

  /// Ambil data pasien lengkap
  static Map<String, dynamic>? get patientData {
    final jsonStr = _prefs?.getString(_keyPatientData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Ambil data SIMRS pasien (objek 'simrs' jika tersedia dari /auth/me)
  static Map<String, dynamic>? get simrsData {
    final data = patientData;
    if (data == null) return null;
    final simrs = data['simrs'];
    if (simrs is Map<String, dynamic>) return simrs;
    return null;
  }

  /// Ambil tanggal lahir pasien (dari SIMRS 'FD_TGL_LAHIR' atau fallback)
  static String? get tanggalLahir {
    return simrsData?['FD_TGL_LAHIR'] as String? ??
        simrsData?['fd_tgl_lahir'] as String? ??
        patientData?['fd_tgl_lahir'] as String? ??
        patientData?['tanggal_lahir'] as String?;
  }

  /// Ambil waktu pembuatan akun (dari 'fd_created_at')
  static String? get createdAt {
    return patientData?['fd_created_at'] as String?;
  }

  /// Simpan sesi baru setelah login / registrasi berhasil
  static Future<void> saveSession({
    required String token,
    String? namaPasien,
    String? fsNmPasien,
    String? noRm,
    String? fsMr,
    String? nik,
    String? fsNik,
    String? email,
    String? fsEmail,
    String? username,
  }) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;

    final resolvedNama = fsNmPasien ?? namaPasien ?? '';
    final resolvedMr = (fsMr ?? noRm ?? '').replaceAll('-', '').replaceAll(' ', '').trim();
    final resolvedNik = fsNik ?? nik;
    final resolvedEmail = fsEmail ?? email;

    _isGuestMode = false;
    await Future.wait([
      p.setString(_keyToken, token),
      p.setBool(_keyIsLoggedIn, true),
      p.setBool(_keyIsGuest, false),
      p.setString(_keyNamaPasien, resolvedNama),
      p.setString(_keyNoRm, resolvedMr),
      if (resolvedNik != null) p.setString(_keyNik, resolvedNik),
      if (resolvedEmail != null) p.setString(_keyEmail, resolvedEmail),
      if (username != null) p.setString(_keyUsername, username),
    ]);
  }

  /// Simpan profil lokal lengkap berdasarkan NIK (tersimpan persisten per NIK pasien)
  static Future<void> saveProfileByNik(String nik, Map<String, dynamic> data) async {
    if (nik.trim().isEmpty) return;
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    final cleanNik = nik.trim();
    final current = getProfileByNik(cleanNik) ?? {};
    final merged = {...current, ...data};
    // Sanitasi data sensitif
    merged.remove('password');
    merged.remove('kata_sandi');
    merged.remove('confirm_password');
    merged.remove('pin');
    await p.setString('$_keyProfilePrefix$cleanNik', jsonEncode(merged));
  }

  /// Ambil profil lokal lengkap berdasarkan NIK
  static Map<String, dynamic>? getProfileByNik(String nik) {
    if (nik.trim().isEmpty) return null;
    final p = _prefs;
    final cleanNik = nik.trim();
    final jsonStr = p?.getString('$_keyProfilePrefix$cleanNik');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Simpan data pasien lengkap ke session (dengan sanitasi kredensial keamanan)
  static Future<void> savePatientData(Map<String, dynamic> data) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    // Sanitasi: pastikan data sensitif seperti kata sandi tidak pernah tersimpan di lokal
    final safeData = Map<String, dynamic>.from(data)
      ..remove('password')
      ..remove('kata_sandi')
      ..remove('confirm_password')
      ..remove('pin');
    final simrsData = safeData['simrs'] is Map<String, dynamic>
        ? safeData['simrs'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawTglLahir = (safeData['fd_tgl_lahir'] ??
            safeData['FD_TGL_LAHIR'] ??
            simrsData['FD_TGL_LAHIR'] ??
            simrsData['fd_tgl_lahir'])
        ?.toString()
        .trim();
    if (rawTglLahir != null && rawTglLahir.isNotEmpty) {
      await p.setString(_keyTglLahir, rawTglLahir);
    }
    final rawNoHp = (safeData['fs_no_hp'] ??
            safeData['FS_NO_HP'] ??
            safeData['FS_TLP_PASIEN'] ??
            safeData['no_hp'] ??
            simrsData['FS_TLP_PASIEN'] ??
            simrsData['FS_NO_HP'])
        ?.toString()
        .trim();
    if (rawNoHp != null && rawNoHp.isNotEmpty) {
      await p.setString(_keyNoHp, rawNoHp);
    }

    // Merge dengan data pasien yang sudah tersimpan sebelumnya agar field tidak hilang
    final existingData = patientData ?? {};
    final mergedData = {...existingData, ...safeData};

    // Jika ada NIK, gabungkan juga dengan profil yang tersimpan untuk NIK ini
    final currentNik = nik ?? mergedData['fs_nik']?.toString() ?? mergedData['nik']?.toString();
    if (currentNik != null && currentNik.trim().isNotEmpty) {
      final cachedProfile = getProfileByNik(currentNik.trim());
      if (cachedProfile != null) {
        cachedProfile.forEach((key, val) {
          if (!mergedData.containsKey(key) || mergedData[key] == null || mergedData[key].toString().trim().isEmpty) {
            mergedData[key] = val;
          }
        });
      }
    }

    await p.setString(_keyPatientData, jsonEncode(mergedData));
  }

  /// Memperbarui identitas dan profil pasien dari data respons `GET /auth/me`.
  static Future<void> updateFromMe(Map<String, dynamic> data) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;

    final simrs = data['simrs'] is Map<String, dynamic>
        ? data['simrs'] as Map<String, dynamic>
        : <String, dynamic>{};

    final nama = (simrs['FS_NM_PASIEN'] ??
            simrs['fs_nm_pasien'] ??
            data['fs_nm_pasien'] ??
            data['nama'])
        ?.toString()
        .trim();
    if (nama != null && nama.isNotEmpty) {
      await p.setString(_keyNamaPasien, nama);
    }

    final mr = (simrs['FS_MR'] ??
            simrs['fs_mr'] ??
            data['fs_mr'] ??
            data['no_rm'])
        ?.toString()
        .trim();
    if (mr != null && mr.isNotEmpty) {
      final cleanMr = mr.replaceAll('-', '').replaceAll(' ', '').trim();
      await p.setString(_keyNoRm, cleanMr);
    }

    final nik = (data['fs_nik'] ??
            simrs['FS_KD_IDENTITAS'] ??
            simrs['fs_nik'] ??
            data['nik'])
        ?.toString()
        .trim();
    if (nik != null && nik.isNotEmpty) {
      await p.setString(_keyNik, nik);
    }

    final email = (data['fs_email'] ?? data['email'])?.toString().trim();
    if (email != null && email.isNotEmpty) {
      await p.setString(_keyEmail, email);
    }

    final tglLahir = (simrs['FD_TGL_LAHIR'] ??
            simrs['fd_tgl_lahir'] ??
            data['fd_tgl_lahir'])
        ?.toString()
        .trim();
    if (tglLahir != null && tglLahir.isNotEmpty) {
      await p.setString(_keyTglLahir, tglLahir);
    }

    final noHp = (simrs['FS_TLP_PASIEN'] ??
            simrs['FS_NO_HP'] ??
            simrs['fs_no_hp'] ??
            data['fs_no_hp'] ??
            data['no_hp'])
        ?.toString()
        .trim();
    if (noHp != null && noHp.isNotEmpty) {
      await p.setString(_keyNoHp, noHp);
    }

    await savePatientData(data);
  }

  /// Simpan tanggal lahir pasien (`FD_TGL_LAHIR`, format YYYY-MM-DD)
  static Future<void> setTglLahir(String? value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      await p.setString(_keyTglLahir, trimmed);
    } else {
      await p.remove(_keyTglLahir);
    }
  }

  /// Simpan nomor HP pasien (`FS_TLP_PASIEN` / `FS_NO_HP`)
  static Future<void> setNoHp(String? value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      await p.setString(_keyNoHp, trimmed);
    } else {
      await p.remove(_keyNoHp);
    }
  }

  /// Simpan kode antrean aktif hasil booking (`fs_kd_antrian` / `no_antrian`)
  static Future<void> setActiveBooking({
    required String fsKdAntrian,
    String? noBooking,
    String? noUrut,
  }) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    _isGuestMode = false;
    await Future.wait([
      if (fsKdAntrian.trim().isNotEmpty)
        p.setString(_keyFsKdAntrian, fsKdAntrian.trim()),
      if (noBooking != null && noBooking.trim().isNotEmpty)
        p.setString(_keyNoBooking, noBooking.trim()),
      if (noUrut != null && noUrut.trim().isNotEmpty)
        p.setString(_keyNoUrutAntrean, noUrut.trim()),
    ]);
  }

  /// Ambil path foto profil pasien
  static String? get profilePhotoPath =>
      _prefs?.getString(_keyProfilePhotoPath);

  /// Simpan atau hapus path foto profil
  static Future<void> setProfilePhotoPath(String? path) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    if (path != null && path.isNotEmpty) {
      await p.setString(_keyProfilePhotoPath, path);
    } else {
      await p.remove(_keyProfilePhotoPath);
    }
    profilePhotoNotifier.value = path;
  }

  /// Ambil status izin notifikasi pasien
  static bool get isNotificationEnabled =>
      _prefs?.getBool(_keyNotificationEnabled) ?? false;

  /// Simpan status izin notifikasi
  static Future<void> setNotificationEnabled(bool enabled) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setBool(_keyNotificationEnabled, enabled);
  }

  /// Hapus seluruh sesi aktif (saat logout)
  static Future<void> clearSession() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    _isGuestMode = false;
    await Future.wait([
      p.remove(_keyToken),
      p.setBool(_keyIsLoggedIn, false),
      p.setBool(_keyIsGuest, false),
      p.remove(_keyNamaPasien),
      p.remove(_keyNoRm),
      p.remove(_keyNik),
      p.remove(_keyEmail),
      p.remove(_keyUsername),
      p.remove(_keyPatientData),
      p.remove(_keyProfilePhotoPath),
      p.remove(_keyTglLahir),
      p.remove(_keyNoHp),
      p.remove(_keyFsKdAntrian),
      p.remove(_keyNoBooking),
      p.remove(_keyNoUrutAntrean),
    ]);
    profilePhotoNotifier.value = null;
  }
}
