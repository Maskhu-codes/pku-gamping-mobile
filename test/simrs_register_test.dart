@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() async {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
  });

  test('Validasi field wajib registrasi (email, password, nik)', () async {
    expect(
      SimrsService.registerPasien({
        'fs_email': '',
        'fs_password': '123',
        'fs_nik': '',
      }),
      throwsA(isA<Exception>()),
    );
  });

  test('Mencegah registrasi dengan email atau NIK yang sudah terdaftar', () async {
    // Akun dummy_pasien@gmail.com dan NIK 3404052710980002 sudah ada di database
    expect(
      SimrsService.registerPasien({
        'email': 'dummy_pasien@gmail.com',
        'password': 'password123',
        'nik': '3404052710980002',
      }),
      throwsA(isA<Exception>()),
    );
  });

  test('Registrasi end-to-end akun baru (camelCase remapped ke fs_ prefix) & auto-login', () async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueEmail = 'pasien_$timestamp@simrs-test.com';
    // Format NIK 16 digit unik: 98 + 14 digit timestamp
    final uniqueNik = '98${timestamp.toString().padRight(14, '0').substring(0, 14)}';
    final password = 'Password123';

    // Kirim menggunakan format camelCase untuk membuktikan remapping SimrsService
    final payload = {
      'email': uniqueEmail,
      'password': password,
      'nik': uniqueNik,
      'namaPasien': 'PASIEN TEST OTOMASI $timestamp',
      'noHp': '081234567890',
      'tempatLahir': 'SLEMAN',
      'tanggalLahir': '1998-05-15',
      'jenisKelamin': 'Laki-laki',
      'golDarah': 'O',
      'alamat': 'Jl. Wates KM 5.5, Gamping, Sleman',
      'agama': '1',
      'pekerjaan': '02',
      'pendidikan': '5',
      'statusKawin': '1',
      'namaIbu': 'IBU TEST OTOMASI',
      'wargaNegara': 'WNI',
      'kelurahan': '3404008001', // Kelurahan di Sleman
    };

    final result = await SimrsService.registerPasien(payload);

    // 1. Verifikasi response dari backend API
    expect(result['status'], isTrue);
    expect(result['token'], isNotNull);
    expect(result['token'].toString().isNotEmpty, isTrue);

    // 2. Verifikasi session tersimpan otomatis setelah registrasi
    expect(SessionManager.hasValidSession(), isTrue);
    expect(SessionManager.token, result['token']);
    expect(SessionManager.fsEmail, uniqueEmail);
    expect(SessionManager.fsNik, uniqueNik);

    // 3. Verifikasi akun baru dapat langsung digunakan untuk Login
    await SessionManager.clearSession();
    expect(SessionManager.hasValidSession(), isFalse);

    final loginResult = await SimrsService.login(
      email: uniqueEmail,
      password: password,
    );

    expect(loginResult['status'], isTrue);
    expect(SessionManager.hasValidSession(), isTrue);
    expect(SessionManager.fsEmail, uniqueEmail);
  });
}
