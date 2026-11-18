import 'package:flutter/foundation.dart';

/// Konfigurasi global aplikasi PKU Gamping Mobile.
class AppConfig {
  AppConfig._();

  /// URL untuk testing lokal di komputer (desktop / browser / unit test)
  static const String localhostUrl = 'http://localhost/pkug-onlineapi/index.php/api';

  /// URL untuk pengujian via Android Emulator (10.0.2.2 memetakan ke localhost host machine)
  static const String emulatorUrl = 'http://10.0.2.2/pkug-onlineapi/index.php/api';

  /// URL server RS jika backend dideploy di jaringan internal RS
  static const String serverUrl = 'http://192.168.20.1/pkug-onlineapi/index.php/api';

  /// Template URL untuk pengujian via HP Fisik (ganti dengan IP LAN Wi-Fi laptop Anda)
  static String lanUrl(String ipAddress) => 'http://$ipAddress/pkug-onlineapi/index.php/api';

  /// Override opsional via `--dart-define=API_BASE_URL=...` (mis. untuk HP fisik atau server RS)
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL aktif backend CodeIgniter 3 API PKU Gamping (otomatis mendeteksi platform).
  ///
  /// - Jika `--dart-define=API_BASE_URL=...` diberikan, nilai tersebut dipakai.
  /// - Web (Chrome/Edge) atau Desktop (Windows/macOS/Linux) -> [localhostUrl].
  /// - Android (Emulator) -> [emulatorUrl] (`10.0.2.2`).
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      return localhostUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return emulatorUrl;
    }
    return localhostUrl;
  }

  /// Timeout durasi request API (dalam detik)
  static const int connectTimeoutSeconds = 20;
  static const int receiveTimeoutSeconds = 20;
}


