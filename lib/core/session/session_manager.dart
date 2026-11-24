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
  static const String _keyNik = 'pku_nik';
  static const String _keyUsername = 'pku_username';
  static const String _keyPatientData = 'pku_patient_data';
  static const String _keyProfilePhotoPath = 'pku_profile_photo_path';
  static const String _keyNotificationEnabled = 'pku_notification_enabled';
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

  /// Atur status Mode Tamu
  static Future<void> setGuestMode(bool isGuest) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setBool(_keyIsGuest, isGuest);
  }

  /// Ambil JWT / Auth token
  static String? get token => _prefs?.getString(_keyToken);

  /// Ambil nama pasien (default: 'Dahlan Muda')
  static String get namaPasien =>
      _prefs?.getString(_keyNamaPasien) ?? 'Dahlan Muda';

  /// Ambil nomor rekam medis (default: '01-88-24-90')
  static String get noRm => _prefs?.getString(_keyNoRm) ?? '01-88-24-90';

  /// Ambil NIK pasien
  static String? get nik => _prefs?.getString(_keyNik);

  /// Ambil username
  static String? get username => _prefs?.getString(_keyUsername);

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
    required String namaPasien,
    required String noRm,
    String? nik,
    String? username,
  }) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await Future.wait([
      p.setString(_keyToken, token),
      p.setBool(_keyIsLoggedIn, true),
      p.setBool(_keyIsGuest, false),
      p.setString(_keyNamaPasien, namaPasien),
      p.setString(_keyNoRm, noRm),
      if (nik != null) p.setString(_keyNik, nik),
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
    await Future.wait([
      p.remove(_keyToken),
      p.setBool(_keyIsLoggedIn, false),
      p.setBool(_keyIsGuest, false),
      p.remove(_keyNamaPasien),
      p.remove(_keyNoRm),
      p.remove(_keyNik),
      p.remove(_keyUsername),
      p.remove(_keyPatientData),
      p.remove(_keyProfilePhotoPath),
    ]);
    profilePhotoNotifier.value = null;
  }
}
