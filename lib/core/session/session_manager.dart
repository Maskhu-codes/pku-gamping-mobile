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

  /// Inisialisasi SharedPreferences saat awal aplikasi berjalan
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
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
      p.setString(_keyNamaPasien, namaPasien),
      p.setString(_keyNoRm, noRm),
      if (nik != null) p.setString(_keyNik, nik),
      if (username != null) p.setString(_keyUsername, username),
    ]);
  }

  /// Hapus seluruh sesi aktif (saat logout)
  static Future<void> clearSession() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await Future.wait([
      p.remove(_keyToken),
      p.setBool(_keyIsLoggedIn, false),
      p.remove(_keyNamaPasien),
      p.remove(_keyNoRm),
      p.remove(_keyNik),
      p.remove(_keyUsername),
    ]);
  }
}
