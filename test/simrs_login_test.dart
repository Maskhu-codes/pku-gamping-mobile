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
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  test('POST /auth/login dengan akun valid menyimpan token dan data user ke SessionManager', () async {
    expect(SessionManager.hasValidSession(), isFalse);

    final result = await SimrsService.login(
      email: 'dummy_pasien@gmail.com',
      password: 'admin123',
    );

    // 1. Verifikasi response dari backend
    expect(result['status'], isTrue);
    expect(result['message'], 'Login berhasil');
    expect(result['token'], isNotNull);
    expect((result['token'] as String).isNotEmpty, isTrue);

    // 2. Verifikasi state pada SessionManager
    expect(SessionManager.hasValidSession(), isTrue);
    expect(SessionManager.token, isNotNull);
    expect(SessionManager.token, result['token']);
    expect(SessionManager.fsEmail, 'dummy_pasien@gmail.com');
    expect(SessionManager.fsMr, '347104100407039');
    expect(SessionManager.fsNmPasien, 'PASIEN DUMMY ONLINE');
    expect(SessionManager.fsNik, '3404052710980002');
  }, tags: ['live_db']);

  test('POST /auth/login dengan password salah melempar Exception', () async {
    expect(
      () => SimrsService.login(
        email: 'dummy_pasien@gmail.com',
        password: 'password_salah_123',
      ),
      throwsA(isA<Exception>()),
    );
  }, tags: ['live_db']);
}

